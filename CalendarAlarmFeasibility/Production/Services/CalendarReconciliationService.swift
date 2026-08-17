import Foundation

struct ReconciliationWindow: Equatable, Sendable {
    let startDate: Date
    let endDate: Date

    static func productionDefault(now: Date) -> Self {
        .init(startDate: now, endDate: now.addingTimeInterval(14 * 24 * 60 * 60))
    }

    func owns(alarmDate: Date) -> Bool { alarmDate >= startDate && alarmDate < endDate }
}

struct ReconciliationSnapshot: Equatable, Sendable {
    let events: [CalendarEvent]
    let settings: AppSettings
    let overridesByEventIdentity: [String: EventOverride]
}

protocol ReconciliationInputProviding: Sendable {
    func calendarPermissionState() async -> PermissionState
    func snapshot(window: ReconciliationWindow) async throws -> ReconciliationSnapshot
}

enum ReconciliationOperation: Equatable, Sendable {
    case keep(AlarmCandidate)
    case schedule(AlarmCandidate)
    case replace(AlarmCandidate)
    case cancel(ScheduledAlarmMapping)
    case removeStaleMapping(ScheduledAlarmMapping)
    case recoverMissingSystemAlarm(AlarmCandidate, ScheduledAlarmMapping)
    case cancelOrphanSystemAlarm(UUID)
}

struct ReconciliationPlan: Equatable, Sendable { let operations: [ReconciliationOperation] }

enum ReconciliationPlanner {
    static func make(
        desired: [AlarmCandidate], mappings: [ScheduledAlarmMapping], systemAlarmIDs: Set<UUID>,
        now: Date, window: ReconciliationWindow
    ) -> ReconciliationPlan {
        let orderedDesired = desired.sorted { ($0.alarmDate, $0.id) < ($1.alarmDate, $1.id) }
        let mappingByIdentity = Dictionary(uniqueKeysWithValues: mappings.map { ($0.candidateIdentity, $0) })
        let desiredIDs = Set(orderedDesired.map(\.id))
        var operations: [ReconciliationOperation] = []

        for candidate in orderedDesired {
            guard let mapping = mappingByIdentity[candidate.id] else {
                operations.append(.schedule(candidate)); continue
            }
            guard systemAlarmIDs.contains(mapping.alarmIdentifier) else {
                if mapping.alarmDate <= now && candidate.alarmDate <= now { operations.append(.removeStaleMapping(mapping)) }
                else { operations.append(.recoverMissingSystemAlarm(candidate, mapping)) }
                continue
            }
            operations.append(mapping.alarmDate == candidate.alarmDate ? .keep(candidate) : .replace(candidate))
        }

        for mapping in mappings.sorted(by: { ($0.alarmDate, $0.candidateIdentity) < ($1.alarmDate, $1.candidateIdentity) })
        where !desiredIDs.contains(mapping.candidateIdentity) && window.owns(alarmDate: mapping.alarmDate) {
            operations.append(systemAlarmIDs.contains(mapping.alarmIdentifier) ? .cancel(mapping) : .removeStaleMapping(mapping))
        }

        let mappedIDs = Set(mappings.map(\.alarmIdentifier))
        for id in systemAlarmIDs.subtracting(mappedIDs).sorted(by: { $0.uuidString < $1.uuidString }) {
            operations.append(.cancelOrphanSystemAlarm(id))
        }
        return .init(operations: operations)
    }
}

enum ReconciliationBlockedReason: Equatable, Sendable { case calendarPermission(PermissionState), alarmPermission(PermissionState), calendarReadFailed }
enum ReconciliationIssue: Equatable, Sendable { case operationFailed(String), capacityReached(String) }

struct ReconciliationReport: Equatable, Sendable {
    var fetchedEventCount = 0; var desiredCandidateCount = 0; var keptCount = 0
    var scheduledCount = 0; var replacedCount = 0; var cancelledCount = 0
    var staleMappingRemovedCount = 0; var recoveredCount = 0; var orphanCancelledCount = 0
    var issues: [ReconciliationIssue] = []; var blockedReason: ReconciliationBlockedReason?
}

actor CalendarReconciliationCoordinator {
    private let input: any ReconciliationInputProviding
    private let rules: any AlarmRuleEvaluating
    private let overrideResolver = EventOverrideResolver()
    private let scheduler: AlarmSchedulingCoordinator
    private let store: any ScheduledAlarmStoring
    private var running = false; private var dirty = false
    private var latestRequest: (Date, ReconciliationWindow)?

    init(input: any ReconciliationInputProviding, rules: any AlarmRuleEvaluating = AlarmRuleEngine(), scheduler: AlarmSchedulingCoordinator, store: any ScheduledAlarmStoring) {
        self.input = input; self.rules = rules; self.scheduler = scheduler; self.store = store
    }

    @discardableResult
    func trigger(now: Date, window: ReconciliationWindow) async -> ReconciliationReport? {
        latestRequest = (now, window)
        if running { dirty = true; return nil }
        running = true
        var report: ReconciliationReport?
        repeat {
            dirty = false
            guard let request = latestRequest else { break }
            report = await run(now: request.0, window: request.1)
        } while dirty
        running = false
        return report
    }

    private func run(now: Date, window: ReconciliationWindow) async -> ReconciliationReport {
        var report = ReconciliationReport()
        let calendarPermission = await input.calendarPermissionState()
        guard calendarPermission == .authorized else { report.blockedReason = .calendarPermission(calendarPermission); return report }
        let alarmPermission = await scheduler.authorizationState()
        guard alarmPermission == .authorized else { report.blockedReason = .alarmPermission(alarmPermission); return report }
        let snapshot: ReconciliationSnapshot
        do { snapshot = try await input.snapshot(window: window) }
        catch { report.blockedReason = .calendarReadFailed; return report }
        report.fetchedEventCount = snapshot.events.count
        let desired = snapshot.events.compactMap { event -> AlarmCandidate? in
            guard case .enabled(let leadTime) = overrideResolver.resolve(override: snapshot.overridesByEventIdentity[event.id], settings: snapshot.settings) else { return nil }
            if case .candidate(let candidate) = rules.evaluate(event: event, leadTime: leadTime, now: now) { return candidate }
            return nil
        }.sorted { ($0.alarmDate, $0.id) < ($1.alarmDate, $1.id) }
        report.desiredCandidateCount = desired.count
        do {
            let plan = ReconciliationPlanner.make(desired: desired, mappings: try await store.allMappings(), systemAlarmIDs: try await scheduler.scheduledAlarmIDs(), now: now, window: window)
            for operation in plan.operations { await execute(operation, report: &report) }
        } catch { report.issues.append(.operationFailed("source-state")) }
        return report
    }

    private func execute(_ operation: ReconciliationOperation, report: inout ReconciliationReport) async {
        do {
            switch operation {
            case .keep: report.keptCount += 1
            case .schedule(let candidate):
                _ = try await scheduler.schedule(candidate); report.scheduledCount += 1
            case .replace(let candidate):
                _ = try await scheduler.schedule(candidate); report.replacedCount += 1
            case .cancel(let mapping):
                _ = try await scheduler.cancel(candidateIdentity: mapping.candidateIdentity); report.cancelledCount += 1
            case .removeStaleMapping(let mapping):
                try await store.remove(identity: mapping.candidateIdentity); report.staleMappingRemovedCount += 1
            case .recoverMissingSystemAlarm(let candidate, let mapping):
                try await scheduler.recover(candidate, mapping: mapping); report.recoveredCount += 1
            case .cancelOrphanSystemAlarm(let id):
                try await scheduler.cancelOrphan(id: id); report.orphanCancelledCount += 1
            }
        } catch AlarmSystemError.capacityReached {
            report.issues.append(.capacityReached(operation.identity))
        } catch {
            report.issues.append(.operationFailed(operation.identity))
        }
    }
}

private extension ReconciliationOperation {
    var identity: String {
        switch self {
        case .keep(let value), .schedule(let value), .replace(let value): value.id
        case .cancel(let value), .removeStaleMapping(let value): value.candidateIdentity
        case .recoverMissingSystemAlarm(let value, _): value.id
        case .cancelOrphanSystemAlarm(let id): id.uuidString
        }
    }
}
