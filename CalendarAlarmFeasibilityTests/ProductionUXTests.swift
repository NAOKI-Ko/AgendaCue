import Foundation
import SwiftData
import XCTest
@testable import CalendarAlarmFeasibility

final class ProductionUXTests: XCTestCase {
    func testCalendarNotDeterminedRoutesToOnboarding() { XCTAssertEqual(ProductionPresentationPolicy.route(calendar: .notDetermined, alarm: .authorized), .onboarding) }
    func testAlarmNotDeterminedRoutesToOnboarding() { XCTAssertEqual(ProductionPresentationPolicy.route(calendar: .authorized, alarm: .notDetermined), .onboarding) }
    func testAuthorizedRoutesToMainApp() { XCTAssertEqual(ProductionPresentationPolicy.route(calendar: .authorized, alarm: .authorized), .main) }
    func testCalendarDeniedRoutesToGuidance() { XCTAssertEqual(ProductionPresentationPolicy.route(calendar: .denied, alarm: .authorized), .onboarding) }
    func testAlarmDeniedRoutesToGuidance() { XCTAssertEqual(ProductionPresentationPolicy.route(calendar: .authorized, alarm: .denied), .onboarding) }
    func testTodayEventsSortChronologically() { let a = event("a", 200); let b = event("b", 100); XCTAssertEqual(ProductionPresentationPolicy.sorted([a,b]).map(\.id), ["b","a"]) }
    func testUpcomingGroupingOrdersDatesAndEvents() { var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!; let values = ProductionPresentationPolicy.grouped([event("b", 90_000), event("a", 86_500)], calendar: cal); XCTAssertEqual(values.flatMap(\.1).map(\.id), ["a","b"]) }
    func testEffectiveLeadTextUsesCustomValue() { let e = event("a", 10_000); let value = EventOverride(eventIdentity: "a", state: .enabled(leadTimeOverride: .fifteenMinutes)); XCTAssertTrue(ProductionPresentationPolicy.alarmText(event: e, override: value, settings: .init(), now: .init(timeIntervalSince1970: 0)).contains("15 min")) }
    func testOffOverrideDisplaysOff() { XCTAssertEqual(ProductionPresentationPolicy.alarmText(event: event("a", 1000), override: .init(eventIdentity: "a", state: .disabled), settings: .init(), now: .init(timeIntervalSince1970: 0)), "Alarm off") }
    func testAllDayDoesNotClaimAlarm() { let e = CalendarEvent(id: "a", eventIdentifier: nil, title: "Day", startDate: .init(timeIntervalSince1970: 1000), endDate: .init(timeIntervalSince1970: 2000), isAllDay: true, calendarID: "c"); XCTAssertEqual(ProductionPresentationPolicy.alarmText(event: e, override: nil, settings: .init(), now: .init(timeIntervalSince1970: 0)), "No alarm for all-day events") }

    @MainActor func testDefaultLeadMutationPersistsAndTriggersReconciliation() async throws {
        let container = try PersistenceContainer.make(inMemory: true); let trigger = UXFakeTrigger(); let service = AppSettingsService(container: container, reconciliation: trigger)
        try await service.setDefaultLeadTime(.thirtyMinutes, now: .init(timeIntervalSince1970: 1000))
        let saved = try await service.load(); XCTAssertEqual(saved.defaultLeadTime, .thirtyMinutes); XCTAssertEqual(trigger.count, 1)
    }
    private func event(_ id: String, _ time: TimeInterval) -> CalendarEvent { .init(id: id, eventIdentifier: id, title: id, startDate: .init(timeIntervalSince1970: time), endDate: .init(timeIntervalSince1970: time + 60), isAllDay: false, calendarID: "c") }
}

@MainActor private final class UXFakeTrigger: ReconciliationTriggering, @unchecked Sendable { var count = 0; func trigger(now: Date, window: ReconciliationWindow) async -> ReconciliationReport? { count += 1; return nil } }
