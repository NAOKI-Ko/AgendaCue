import AlarmKit
import EventKit

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

@MainActor
final class EventKitPermissionProvider: CalendarPermissionProviding {
    private let eventStore: EKEventStore

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    var state: PermissionState {
        CalendarPermissionMapping.map(EKEventStore.authorizationStatus(for: .event))
    }

    func requestAccess() async throws -> PermissionState {
        guard state == .notDetermined else { return state }
        _ = try await eventStore.requestFullAccessToEvents()
        return state
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
