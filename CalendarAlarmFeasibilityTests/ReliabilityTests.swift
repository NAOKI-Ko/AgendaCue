import Foundation
import XCTest
@testable import CalendarAlarmFeasibility

@MainActor
final class ReliabilityTests: XCTestCase {
    func testBackgroundRegistrationOccursOnceWithCorrectIdentifier() {
        let x = setup(); XCTAssertTrue(x.coordinator.start()); XCTAssertTrue(x.coordinator.start())
        XCTAssertEqual(x.scheduler.registerCount, 1); XCTAssertEqual(x.scheduler.identifier, ReliabilityPolicy.backgroundTaskIdentifier)
    }

    func testBackgroundRegistrationSchedulesOneLogicalRequest() {
        let x = setup(now: 1_000); _ = x.coordinator.start()
        XCTAssertEqual(x.scheduler.replaceCount, 1); XCTAssertEqual(x.scheduler.earliest, Date(timeIntervalSince1970: 1_000 + ReliabilityPolicy.backgroundRefreshInterval))
    }

    func testRepeatedSchedulingReplacesRatherThanAccumulates() {
        let x = setup(); _ = x.coordinator.start(); x.coordinator.scheduleNext(); x.coordinator.scheduleNext()
        XCTAssertEqual(x.scheduler.replaceCount, 3)
    }

    func testBackgroundExecutionUsesExistingReconciliationAndReschedules() async {
        let x = setup(); _ = x.coordinator.start(); let result = await x.scheduler.handler?()
        XCTAssertEqual(result, true); XCTAssertEqual(x.trigger.count, 1); XCTAssertEqual(x.scheduler.replaceCount, 2)
    }

    func testBlockedBackgroundExecutionReportsFailureWithoutPrompt() async {
        let report = ReconciliationReport(blockedReason: .calendarPermission(.denied)); let x = setup(report: report); _ = x.coordinator.start()
        let result = await x.scheduler.handler?()
        XCTAssertEqual(result, false); XCTAssertEqual(x.trigger.count, 1)
    }

    func testBackgroundSchedulingFailureDoesNotPreventForegroundTrigger() async {
        let x = setup(); x.scheduler.failScheduling = true; XCTAssertTrue(x.coordinator.start())
        XCTAssertNotNil(x.coordinator.lastSchedulingErrorDescription)
        _ = await x.trigger.trigger(now: .now, window: .productionDefault(now: .now)); XCTAssertEqual(x.trigger.count, 1)
    }

    func testCancellationReturnsFailure() async {
        let x = setup(); x.trigger.delay = 100_000_000; _ = x.coordinator.start()
        let task = Task { await x.scheduler.handler?() }; task.cancel()
        let result = await task.value
        XCTAssertEqual(result, false)
    }

    func testSignificantTimeSignalsAreConfigured() {
        XCTAssertTrue(ReliabilityPolicy.timeChangeNotifications.contains(NSNotification.Name.NSCalendarDayChanged))
        XCTAssertTrue(ReliabilityPolicy.timeChangeNotifications.contains(NSNotification.Name.NSSystemTimeZoneDidChange))
        XCTAssertEqual(Set(ReliabilityPolicy.timeChangeNotifications).count, 3)
    }

    func testLongGapUsesFreshFourteenDayWindow() {
        let resumed = Date(timeIntervalSince1970: 900_000); let window = ReconciliationWindow.productionDefault(now: resumed)
        XCTAssertEqual(window.startDate, resumed); XCTAssertEqual(window.endDate.timeIntervalSince(window.startDate), 14 * 86_400)
    }

    func testDayChangeShiftsWindowWithoutManualTimezoneArithmetic() {
        let first = ReconciliationWindow.productionDefault(now: .init(timeIntervalSince1970: 0)); let second = ReconciliationWindow.productionDefault(now: .init(timeIntervalSince1970: 86_400))
        XCTAssertEqual(second.startDate.timeIntervalSince(first.startDate), 86_400); XCTAssertEqual(second.endDate.timeIntervalSince(first.endDate), 86_400)
    }

    func testNilIdentifierFallbackDoesNotFuzzyAttachOverrideAfterIdentityChange() {
        let old = CalendarDomainMapper.event(.init(identifier: nil, calendarID: "cal", title: "Old", start: .init(timeIntervalSinceReferenceDate: 1), end: .init(timeIntervalSinceReferenceDate: 2), isAllDay: false))
        let changed = CalendarDomainMapper.event(.init(identifier: nil, calendarID: "cal", title: "Changed", start: .init(timeIntervalSinceReferenceDate: 3), end: .init(timeIntervalSinceReferenceDate: 4), isAllDay: false))
        XCTAssertNotEqual(old.id, changed.id); XCTAssertNil([old.id: EventOverride(eventIdentity: old.id, state: .disabled)][changed.id])
    }

    func testStableIdentifierSurvivesTitleAndTimeEdit() {
        let a = CalendarDomainMapper.event(.init(identifier: "stable", calendarID: "cal", title: "Old", start: .init(timeIntervalSinceReferenceDate: 1), end: .init(timeIntervalSinceReferenceDate: 2), isAllDay: false))
        let b = CalendarDomainMapper.event(.init(identifier: "stable", calendarID: "cal", title: "New", start: .init(timeIntervalSinceReferenceDate: 10), end: .init(timeIntervalSinceReferenceDate: 11), isAllDay: false))
        XCTAssertEqual(a.id, b.id)
    }

    private func setup(now: TimeInterval = 1_000, report: ReconciliationReport = .init()) -> (coordinator: BackgroundRefreshCoordinator, scheduler: FakeBackgroundScheduler, trigger: FakeReliabilityTrigger) {
        let scheduler = FakeBackgroundScheduler(); let trigger = FakeReliabilityTrigger(report: report)
        return (.init(scheduler: scheduler, reconciliation: trigger, now: { Date(timeIntervalSince1970: now) }), scheduler, trigger)
    }
}

@MainActor private final class FakeBackgroundScheduler: BackgroundRefreshScheduling, @unchecked Sendable {
    var registerCount = 0; var replaceCount = 0; var identifier: String?; var earliest: Date?; var handler: (@Sendable () async -> Bool)?; var failScheduling = false
    func register(identifier: String, handler: @escaping @Sendable () async -> Bool) -> Bool { registerCount += 1; self.identifier = identifier; self.handler = handler; return true }
    func replacePending(identifier: String, earliestBeginDate: Date) throws { if failScheduling { throw ReliabilityTestError.failed }; replaceCount += 1; earliest = earliestBeginDate }
}

@MainActor private final class FakeReliabilityTrigger: ReconciliationTriggering, @unchecked Sendable {
    var count = 0; var delay: UInt64 = 0; let report: ReconciliationReport
    init(report: ReconciliationReport) { self.report = report }
    func trigger(now: Date, window: ReconciliationWindow) async -> ReconciliationReport? { count += 1; if delay > 0 { try? await Task.sleep(nanoseconds: delay) }; return report }
}
private enum ReliabilityTestError: Error { case failed }
