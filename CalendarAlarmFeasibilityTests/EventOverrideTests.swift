import Foundation
import SwiftData
import XCTest
@testable import CalendarAlarmFeasibility

@MainActor
final class EventOverrideTests: XCTestCase {
    private let resolver = EventOverrideResolver()

    func testNoOverrideUsesAppDefault() { XCTAssertEqual(resolver.resolve(override: nil, settings: settings(.tenMinutes)), .enabled(.tenMinutes)) }
    func testExplicitOnWithoutCustomUsesAppDefault() { XCTAssertEqual(resolver.resolve(override: value(.enabled(leadTimeOverride: nil)), settings: settings(.thirtyMinutes)), .enabled(.thirtyMinutes)) }
    func testExplicitOnWithCustomUsesCustomLead() { XCTAssertEqual(resolver.resolve(override: value(.enabled(leadTimeOverride: .fifteenMinutes)), settings: settings(.fiveMinutes)), .enabled(.fifteenMinutes)) }
    func testExplicitOffDisables() { XCTAssertEqual(resolver.resolve(override: value(.disabled), settings: settings(.fiveMinutes)), .disabled) }
    func testCustomLeadIgnoresChangedDefault() { XCTAssertEqual(resolver.resolve(override: value(.enabled(leadTimeOverride: .fifteenMinutes)), settings: settings(.oneHour)), .enabled(.fifteenMinutes)) }
    func testNoCustomLeadFollowsChangedDefault() { XCTAssertEqual(resolver.resolve(override: value(.enabled(leadTimeOverride: nil)), settings: settings(.oneHour)), .enabled(.oneHour)) }

    func testExplicitOnCannotBypassAllDayEligibility() {
        let event = calendarEvent(allDay: true); guard case .enabled(let lead) = resolver.resolve(override: value(.enabled(leadTimeOverride: nil)), settings: settings(.fiveMinutes)) else { return XCTFail() }
        XCTAssertEqual(AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: .init(timeIntervalSince1970: 100)), .excluded(.allDay))
    }

    func testExplicitOnCannotBypassPastAlarmEligibility() {
        let event = calendarEvent(start: .init(timeIntervalSince1970: 300)); guard case .enabled(let lead) = resolver.resolve(override: value(.enabled(leadTimeOverride: nil)), settings: settings(.fiveMinutes)) else { return XCTFail() }
        XCTAssertEqual(AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: .init(timeIntervalSince1970: 100)), .excluded(.alarmDateNotInFuture))
    }

    func testNilEventKitIdentifierUsesDomainIdentitySafely() async throws {
        let store = try makeStore(); try await store.upsert(.init(eventIdentity: "fallback-domain-id", state: .disabled))
        let saved = try await store.override(for: "fallback-domain-id"); XCTAssertEqual(saved?.state, .disabled)
    }

    func testOverridePersistsRoundTrip() async throws {
        let store = try makeStore(); let expected = value(.enabled(leadTimeOverride: .fifteenMinutes)); try await store.upsert(expected)
        let saved = try await store.override(for: "event"); XCTAssertEqual(saved, expected)
    }

    func testResetRemovesRecordAndRestoresDefault() async throws {
        let store = try makeStore(); try await store.upsert(value(.disabled)); try await store.remove(eventIdentity: "event")
        let saved = try await store.override(for: "event"); XCTAssertNil(saved); XCTAssertEqual(resolver.resolve(override: nil, settings: settings(.tenMinutes)), .enabled(.tenMinutes))
    }

    func testUnrelatedOverrideDoesNotAffectEvent() async throws {
        let store = try makeStore(); try await store.upsert(.init(eventIdentity: "other", state: .disabled))
        let saved = try await store.override(for: "event"); XCTAssertNil(saved)
    }

    func testServiceMutationTriggersReconciliationAfterPersistence() async throws {
        let store = OverrideFakeStore(); let trigger = OverrideFakeTrigger(); let service = EventOverrideService(store: store, reconciliation: trigger, now: { .init(timeIntervalSince1970: 1_000) })
        try await service.set(.disabled, for: "event")
        XCTAssertEqual(store.values["event"]?.state, .disabled); XCTAssertEqual(trigger.count, 1)
    }

    func testResetTriggersAndRemovesPersistence() async throws {
        let store = OverrideFakeStore(); store.values["event"] = value(.disabled); let trigger = OverrideFakeTrigger(); let service = EventOverrideService(store: store, reconciliation: trigger)
        try await service.reset(eventIdentity: "event")
        XCTAssertNil(store.values["event"]); XCTAssertEqual(trigger.count, 1)
    }

    func testSaveFailureDoesNotTriggerFalseSuccess() async {
        let store = OverrideFakeStore(); store.failSave = true; let trigger = OverrideFakeTrigger(); let service = EventOverrideService(store: store, reconciliation: trigger)
        do { try await service.set(.disabled, for: "event"); XCTFail() } catch { XCTAssertEqual(trigger.count, 0); XCTAssertTrue(store.values.isEmpty) }
    }

    func testAlarmPermissionDoesNotPreventSavingUserIntent() async throws {
        let store = OverrideFakeStore(); let trigger = OverrideFakeTrigger(report: .init(blockedReason: .alarmPermission(.denied))); let service = EventOverrideService(store: store, reconciliation: trigger)
        try await service.set(.disabled, for: "event")
        XCTAssertEqual(store.values["event"]?.state, .disabled); XCTAssertEqual(trigger.count, 1)
    }

    func testOutOfWindowAbsenceDoesNotDeleteOverride() async throws {
        let store = try makeStore(); try await store.upsert(value(.disabled)); _ = try await store.allOverrides()
        let saved = try await store.override(for: "event"); XCTAssertNotNil(saved)
    }

    private func settings(_ lead: AlarmLeadTime) -> AppSettings { .init(defaultLeadTime: lead) }
    private func value(_ state: EventAlarmOverride) -> EventOverride { .init(eventIdentity: "event", state: state) }
    private func calendarEvent(start: Date = .init(timeIntervalSince1970: 1_000), allDay: Bool = false) -> CalendarEvent { .init(id: "event", eventIdentifier: nil, title: "Event", startDate: start, endDate: start.addingTimeInterval(60), isAllDay: allDay, calendarID: "cal") }
    private func makeStore() throws -> SwiftDataEventOverrideStore { .init(container: try PersistenceContainer.make(inMemory: true)) }
}

@MainActor private final class OverrideFakeStore: EventOverrideStoring, @unchecked Sendable {
    var values: [String: EventOverride] = [:]; var failSave = false
    func override(for eventIdentity: String) async -> EventOverride? { values[eventIdentity] }
    func allOverrides() async -> [String: EventOverride] { values }
    func upsert(_ value: EventOverride) async throws { if failSave { throw OverrideTestError.failed }; values[value.eventIdentity] = value }
    func remove(eventIdentity: String) async { values.removeValue(forKey: eventIdentity) }
}

@MainActor private final class OverrideFakeTrigger: ReconciliationTriggering, @unchecked Sendable {
    var count = 0; let report: ReconciliationReport?
    init(report: ReconciliationReport? = nil) { self.report = report }
    func trigger(now: Date, window: ReconciliationWindow) async -> ReconciliationReport? { count += 1; return report }
}

private enum OverrideTestError: Error { case failed }
