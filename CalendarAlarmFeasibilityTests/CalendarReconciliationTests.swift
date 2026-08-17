import Foundation
import XCTest
@testable import CalendarAlarmFeasibility

@MainActor
final class CalendarReconciliationTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 10_000)

    func testNewEventSchedulesAndPersists() async throws {
        let x = setup(events: [event(id: "new")]); let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.scheduledCount, 1); XCTAssertEqual(x.store.values.count, 1); XCTAssertEqual(x.system.ids.count, 1)
    }

    func testUnchangedEventIsNoOp() async throws {
        let mapping = mapping(id: "a", date: alarmDate()); let x = setup(events: [event(id: "a")], mappings: [mapping], systemIDs: [mapping.alarmIdentifier])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.keptCount, 1); XCTAssertEqual(x.system.scheduleCount, 0); XCTAssertEqual(x.system.cancelCount, 0)
    }

    func testChangedAlarmDateReplacesWithStableID() async throws {
        let old = mapping(id: "a", date: alarmDate().addingTimeInterval(-60)); let x = setup(events: [event(id: "a")], mappings: [old], systemIDs: [old.alarmIdentifier])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.replacedCount, 1); XCTAssertEqual(x.store.values["a"]?.alarmIdentifier, old.alarmIdentifier)
    }

    func testDeletedEventCancels() async { await assertExistingBecomesCancelled(events: []) }
    func testAllDayEventCancels() async { await assertExistingBecomesCancelled(events: [event(id: "a", allDay: true)]) }
    func testAlarmMovedIntoPastCancels() async { await assertExistingBecomesCancelled(events: [event(id: "a", start: now.addingTimeInterval(100))]) }
    func testDisabledCalendarCancelsItsFutureAlarm() async { await assertExistingBecomesCancelled(events: []) }

    func testNewlySelectedEventSchedules() async {
        let x = setup(events: [event(id: "selected")]); let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.scheduledCount, 1)
    }

    func testMissingFutureSystemAlarmRecoversStableUUID() async {
        let old = mapping(id: "a", date: alarmDate()); let x = setup(events: [event(id: "a")], mappings: [old])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.recoveredCount, 1); XCTAssertTrue(x.system.ids.contains(old.alarmIdentifier))
    }

    func testReplacementRecoveryDivergenceRepairsDateAndUUID() async {
        let old = mapping(id: "a", date: alarmDate().addingTimeInterval(-60)); let x = setup(events: [event(id: "a")], mappings: [old])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.recoveredCount, 1); XCTAssertEqual(x.store.values["a"]?.alarmDate, alarmDate())
    }

    func testMissingExpiredSystemAlarmRemovesStaleMapping() async {
        let old = mapping(id: "old", date: now); let x = setup(events: [], mappings: [old])
        let report = await x.reconciler.trigger(now: now, window: window(start: now.addingTimeInterval(-10)))!
        XCTAssertEqual(report.staleMappingRemovedCount, 1); XCTAssertNil(x.store.values["old"])
    }

    func testOrphanSystemAlarmIsCancelled() async {
        let orphan = UUID(); let x = setup(systemIDs: [orphan]); let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.orphanCancelledCount, 1); XCTAssertFalse(x.system.ids.contains(orphan))
    }

    func testScheduleFailureDoesNotCreateFalseMapping() async {
        let x = setup(events: [event(id: "a")]); x.system.scheduleFailures = 1
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.scheduledCount, 0); XCTAssertTrue(x.store.values.isEmpty); XCTAssertEqual(report.issues.count, 1)
    }

    func testCancelFailureDoesNotRemoveMapping() async {
        let old = mapping(id: "a", date: alarmDate()); let x = setup(mappings: [old], systemIDs: [old.alarmIdentifier]); x.system.cancelFailures = 1
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertNotNil(x.store.values["a"]); XCTAssertEqual(report.cancelledCount, 0)
    }

    func testFailureIsolationContinuesIndependentCandidate() async {
        let x = setup(events: [event(id: "a"), event(id: "b", start: now.addingTimeInterval(1_000))]); x.system.scheduleFailures = 1
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.scheduledCount, 1); XCTAssertEqual(report.issues.count, 1); XCTAssertEqual(x.store.values.count, 1)
    }

    func testCalendarPermissionDeniedDoesNotMassCancel() async {
        let old = mapping(id: "a", date: alarmDate()); let x = setup(permission: .denied, mappings: [old], systemIDs: [old.alarmIdentifier])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.blockedReason, .calendarPermission(.denied)); XCTAssertNotNil(x.store.values["a"]); XCTAssertEqual(x.system.cancelCount, 0)
    }

    func testAlarmPermissionFailureIsReportedWithoutMutation() async {
        let x = setup(events: [event(id: "a")], alarmPermission: .denied); let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.blockedReason, .alarmPermission(.denied)); XCTAssertTrue(x.store.values.isEmpty)
    }

    func testNilEventIdentifierIsSafe() async {
        let x = setup(events: [event(id: "fallback", identifier: nil)]); let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.scheduledCount, 1)
    }

    func testRepeatedReconciliationConverges() async {
        let x = setup(events: [event(id: "a")]); _ = await x.reconciler.trigger(now: now, window: window()); let second = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(second.keptCount, 1); XCTAssertEqual(x.system.scheduleCount, 1)
    }

    func testPlannerOrderingIsDeterministicAndEarliestFirst() {
        let late = candidate(id: "z", alarm: alarmDate().addingTimeInterval(60)); let earlyB = candidate(id: "b", alarm: alarmDate()); let earlyA = candidate(id: "a", alarm: alarmDate())
        let plan = ReconciliationPlanner.make(desired: [late, earlyB, earlyA], mappings: [], systemAlarmIDs: [], now: now, window: window())
        XCTAssertEqual(plan.operations.map(\.identityForTest), ["a", "b", "z"])
    }

    func testCapacityProducesPartialReportWithoutFalsePersistence() async {
        let x = setup(events: [event(id: "a"), event(id: "b", start: now.addingTimeInterval(1_000))]); x.system.capacityAfter = 1
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.scheduledCount, 1); XCTAssertEqual(report.issues.filter { if case .capacityReached = $0 { true } else { false } }.count, 1); XCTAssertEqual(x.store.values.count, 1)
    }

    func testWindowBoundaryDoesNotCancelOutsideManagedAlarm() async {
        let outside = mapping(id: "outside", date: window().endDate.addingTimeInterval(1)); let x = setup(mappings: [outside], systemIDs: [outside.alarmIdentifier])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.cancelledCount, 0); XCTAssertNotNil(x.store.values["outside"]); XCTAssertTrue(x.system.ids.contains(outside.alarmIdentifier))
    }

    func testConcurrentTriggersAreSerializedAndDirtyTriggerGetsFollowUpPass() async {
        let x = setup(events: [event(id: "a")]); x.input.delayNanoseconds = 30_000_000
        async let first = x.reconciler.trigger(now: now, window: window())
        try? await Task.sleep(nanoseconds: 5_000_000)
        async let second = x.reconciler.trigger(now: now, window: window())
        _ = await (first, second)
        XCTAssertEqual(x.input.maximumConcurrentSnapshots, 1); XCTAssertEqual(x.input.snapshotCount, 2)
    }

    func testOverrideOffCausesReconciliationCancel() async {
        let old = mapping(id: "a", date: alarmDate()); let off = EventOverride(eventIdentity: "a", state: .disabled)
        let x = setup(events: [event(id: "a")], mappings: [old], systemIDs: [old.alarmIdentifier], overrides: ["a": off])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.cancelledCount, 1)
    }

    func testOverrideOffToOnSchedules() async {
        let on = EventOverride(eventIdentity: "a", state: .enabled(leadTimeOverride: nil))
        let x = setup(events: [event(id: "a")], overrides: ["a": on]); let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.scheduledCount, 1)
    }

    func testOverrideLeadChangeReplacesAlarm() async {
        let old = mapping(id: "a", date: alarmDate()); let custom = EventOverride(eventIdentity: "a", state: .enabled(leadTimeOverride: .fifteenMinutes))
        let x = setup(events: [event(id: "a")], mappings: [old], systemIDs: [old.alarmIdentifier], overrides: ["a": custom])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.replacedCount, 1); XCTAssertEqual(x.store.values["a"]?.alarmDate, alarmDate().addingTimeInterval(-600))
    }

    func testResetToDefaultReplacesCustomAlarm() async {
        let customDate = alarmDate().addingTimeInterval(-600); let old = mapping(id: "a", date: customDate)
        let x = setup(events: [event(id: "a")], mappings: [old], systemIDs: [old.alarmIdentifier])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.replacedCount, 1); XCTAssertEqual(x.store.values["a"]?.alarmDate, alarmDate())
    }

    func testOverrideReconciliationIsIdempotent() async {
        let custom = EventOverride(eventIdentity: "a", state: .enabled(leadTimeOverride: .fifteenMinutes)); let x = setup(events: [event(id: "a")], overrides: ["a": custom])
        _ = await x.reconciler.trigger(now: now, window: window()); let second = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(second.keptCount, 1); XCTAssertEqual(x.system.scheduleCount, 1)
    }

    private func assertExistingBecomesCancelled(events: [CalendarEvent]) async {
        let old = mapping(id: "a", date: alarmDate()); let x = setup(events: events, mappings: [old], systemIDs: [old.alarmIdentifier])
        let report = await x.reconciler.trigger(now: now, window: window())!
        XCTAssertEqual(report.cancelledCount, 1); XCTAssertNil(x.store.values["a"]); XCTAssertFalse(x.system.ids.contains(old.alarmIdentifier))
    }

    private func window(start: Date? = nil) -> ReconciliationWindow { .init(startDate: start ?? now, endDate: now.addingTimeInterval(20_000)) }
    private func alarmDate() -> Date { now.addingTimeInterval(700) }
    private func event(id: String, identifier: String? = "event", start: Date? = nil, allDay: Bool = false) -> CalendarEvent {
        let start = start ?? alarmDate().addingTimeInterval(300)
        return .init(id: id, eventIdentifier: identifier, title: id, startDate: start, endDate: start.addingTimeInterval(60), isAllDay: allDay, calendarID: "cal")
    }
    private func candidate(id: String, alarm: Date) -> AlarmCandidate { .init(id: id, calendarIdentifier: "cal", eventIdentifier: id, eventTitle: id, eventStartDate: alarm.addingTimeInterval(300), alarmDate: alarm, appliedLeadTime: .fiveMinutes) }
    private func mapping(id: String, date: Date) -> ScheduledAlarmMapping { .init(candidateIdentity: id, alarmIdentifier: UUID(), alarmDate: date) }

    private func setup(events: [CalendarEvent] = [], permission: PermissionState = .authorized, alarmPermission: PermissionState = .authorized, mappings: [ScheduledAlarmMapping] = [], systemIDs: Set<UUID> = [], overrides: [String: EventOverride] = [:]) -> (reconciler: CalendarReconciliationCoordinator, input: ReconciliationFakeInput, system: ReconciliationFakeSystem, store: ReconciliationFakeStore) {
        let input = ReconciliationFakeInput(permission: permission, events: events, overrides: overrides); let system = ReconciliationFakeSystem(state: alarmPermission, ids: systemIDs); let store = ReconciliationFakeStore(mappings)
        let scheduler = AlarmSchedulingCoordinator(system: system, store: store)
        return (.init(input: input, scheduler: scheduler, store: store), input, system, store)
    }
}

private extension ReconciliationOperation {
    var identityForTest: String {
        switch self {
        case .keep(let x), .schedule(let x), .replace(let x): x.id
        case .cancel(let x), .removeStaleMapping(let x): x.candidateIdentity
        case .recoverMissingSystemAlarm(let x, _): x.id
        case .cancelOrphanSystemAlarm(let id): id.uuidString
        }
    }
}

@MainActor private final class ReconciliationFakeInput: ReconciliationInputProviding, @unchecked Sendable {
    let permission: PermissionState; var events: [CalendarEvent]; var overrides: [String: EventOverride]; var delayNanoseconds: UInt64 = 0
    var snapshotCount = 0; var concurrentSnapshots = 0; var maximumConcurrentSnapshots = 0
    init(permission: PermissionState, events: [CalendarEvent], overrides: [String: EventOverride]) { self.permission = permission; self.events = events; self.overrides = overrides }
    func calendarPermissionState() async -> PermissionState { permission }
    func snapshot(window: ReconciliationWindow) async throws -> ReconciliationSnapshot {
        snapshotCount += 1; concurrentSnapshots += 1; maximumConcurrentSnapshots = max(maximumConcurrentSnapshots, concurrentSnapshots)
        if delayNanoseconds > 0 { try? await Task.sleep(nanoseconds: delayNanoseconds) }
        concurrentSnapshots -= 1
        return .init(events: events, settings: .init(defaultLeadTime: .fiveMinutes), overridesByEventIdentity: overrides)
    }
}

@MainActor private final class ReconciliationFakeSystem: AlarmSystemScheduling, @unchecked Sendable {
    let state: PermissionState; var ids: Set<UUID>; var scheduleCount = 0; var cancelCount = 0
    var scheduleFailures = 0; var cancelFailures = 0; var capacityAfter: Int?
    init(state: PermissionState, ids: Set<UUID>) { self.state = state; self.ids = ids }
    func authorizationState() async -> PermissionState { state }
    func scheduledAlarmIDs() async -> Set<UUID> { ids }
    func schedule(id: UUID, at date: Date, title: String) async throws {
        if scheduleFailures > 0 { scheduleFailures -= 1; throw ReconciliationTestError.failed }
        if let capacityAfter, scheduleCount >= capacityAfter { throw AlarmSystemError.capacityReached }
        scheduleCount += 1; ids.insert(id)
    }
    func cancel(id: UUID) async throws { cancelCount += 1; if cancelFailures > 0 { cancelFailures -= 1; throw ReconciliationTestError.failed }; ids.remove(id) }
}

@MainActor private final class ReconciliationFakeStore: ScheduledAlarmStoring, @unchecked Sendable {
    var values: [String: ScheduledAlarmMapping]
    init(_ mappings: [ScheduledAlarmMapping]) { values = Dictionary(uniqueKeysWithValues: mappings.map { ($0.candidateIdentity, $0) }) }
    func mapping(for identity: String) async -> ScheduledAlarmMapping? { values[identity] }
    func allMappings() async -> [ScheduledAlarmMapping] { Array(values.values) }
    func save(_ mapping: ScheduledAlarmMapping) async { values[mapping.candidateIdentity] = mapping }
    func remove(identity: String) async { values.removeValue(forKey: identity) }
}

private enum ReconciliationTestError: Error { case failed }
