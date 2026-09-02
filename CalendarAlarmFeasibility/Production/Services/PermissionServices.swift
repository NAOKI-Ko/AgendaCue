import AlarmKit
import EventKit
import OSLog

enum PermissionDiagnostics {
    private static let logger = Logger(subsystem: "com.naoki-ko.agendacue", category: "PermissionState")

    static func log(_ event: String, _ fields: @autoclosure () -> String = "") {
#if DEBUG
        let detail = fields()
        let message = "AgendaCuePermission event=\(event) \(detail)"
        logger.notice("\(message, privacy: .public)")
        print(message)
#endif
    }

    static func calendarAuthorizationStatus() -> String {
        String(describing: EKEventStore.authorizationStatus(for: .event))
    }
}

@MainActor
protocol CalendarPermissionProviding {
    var state: PermissionState { get }
    func requestAccess() async throws -> PermissionState
}

@MainActor
protocol AlarmPermissionProviding {
    var state: PermissionState { get }
    func requestAccess() async throws -> PermissionState
}

enum CalendarPermissionMapping {
    static func map(_ status: EKAuthorizationStatus) -> PermissionState {
        switch status {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied, .writeOnly: .denied
        case .fullAccess: .authorized
        @unknown default: .unavailable
        }
    }
}

enum AlarmPermissionMapping {
    static func map(_ status: AlarmManager.AuthorizationState) -> PermissionState {
        switch status {
        case .notDetermined: .notDetermined
        case .denied: .denied
        case .authorized: .authorized
        @unknown default: .unavailable
        }
    }
}

enum CalendarPermissionConvergence {
    static let defaultMaximumAuthoritativeReads = 3

    static func resolvedState(
        requestResult: PermissionState?,
        authoritativeState: PermissionState
    ) -> PermissionState {
        guard authoritativeState == .notDetermined else { return authoritativeState }
        return requestResult ?? authoritativeState
    }

    @MainActor
    static func resolve(
        requestResult: PermissionState,
        maximumAuthoritativeReads: Int = defaultMaximumAuthoritativeReads,
        authoritativeState: () -> PermissionState,
        waitForNextRead: () async -> Void = { await Task.yield() }
    ) async -> PermissionState {
        let readCount = max(1, maximumAuthoritativeReads)
        for attempt in 0..<readCount {
            let authoritative = authoritativeState()
            let resolved = resolvedState(requestResult: requestResult, authoritativeState: authoritative)
            PermissionDiagnostics.log("calendar.convergence.read", "attempt=\(attempt + 1) request=\(requestResult) authoritative=\(authoritative) resolved=\(resolved)")
            if authoritative != .notDetermined || attempt == readCount - 1 { return resolved }
            await waitForNextRead()
        }
        return requestResult
    }
}

@MainActor
final class EventKitPermissionProvider: CalendarPermissionProviding {
    private let eventStore: EKEventStore
    private var currentRequestResult: PermissionState?

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    var state: PermissionState {
        let raw = EKEventStore.authorizationStatus(for: .event)
        let authoritative = CalendarPermissionMapping.map(raw)
        let resolved = CalendarPermissionConvergence.resolvedState(
            requestResult: currentRequestResult,
            authoritativeState: authoritative
        )
        if authoritative != .notDetermined { currentRequestResult = nil }
        PermissionDiagnostics.log("calendar.provider.state", "raw=\(raw) authoritative=\(authoritative) request=\(String(describing: currentRequestResult)) resolved=\(resolved)")
        return resolved
    }

    func requestAccess() async throws -> PermissionState {
        let initial = state
        PermissionDiagnostics.log("calendar.request.begin", "raw=\(PermissionDiagnostics.calendarAuthorizationStatus()) mapped=\(initial)")
        guard initial == .notDetermined else {
            PermissionDiagnostics.log("calendar.request.skipped", "mapped=\(initial)")
            return initial
        }
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            let requestResult: PermissionState = granted ? .authorized : .denied
            currentRequestResult = requestResult
            let converged = await CalendarPermissionConvergence.resolve(
                requestResult: requestResult,
                authoritativeState: { CalendarPermissionMapping.map(EKEventStore.authorizationStatus(for: .event)) }
            )
            PermissionDiagnostics.log("calendar.request.completed", "granted=\(granted) error=nil raw=\(PermissionDiagnostics.calendarAuthorizationStatus()) resolved=\(converged)")
            return converged
        } catch {
            PermissionDiagnostics.log("calendar.request.completed", "granted=nil error=\(String(describing: error)) raw=\(PermissionDiagnostics.calendarAuthorizationStatus())")
            throw error
        }
    }
}

@MainActor
final class AlarmKitPermissionProvider: AlarmPermissionProviding {
    private let manager: AlarmManager

    init(manager: AlarmManager = .shared) {
        self.manager = manager
    }

    var state: PermissionState {
        AlarmPermissionMapping.map(manager.authorizationState)
    }

    func requestAccess() async throws -> PermissionState {
        guard state == .notDetermined else { return state }
        return AlarmPermissionMapping.map(try await manager.requestAuthorization())
    }
}
