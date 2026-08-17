import AlarmKit
import EventKit
import SwiftData
import XCTest
@testable import CalendarAlarmFeasibility

final class ProductFoundationTests: XCTestCase {
    func testDefaultSettingsUseFiveMinuteLeadTime() {
        XCTAssertEqual(AppSettings().defaultLeadTime, .fiveMinutes)
        XCTAssertEqual(AppSettings().defaultLeadTime.duration, 300)
    }

    func testSupportedLeadTimesHaveStableMinuteValues() {
        XCTAssertEqual(AlarmLeadTime.allCases.map(\.rawValue), [5, 10, 15, 30, 60])
        XCTAssertNil(AlarmLeadTime(rawValue: 7))
    }

    func testCalendarPermissionMapping() {
        XCTAssertEqual(CalendarPermissionMapping.map(.notDetermined), .notDetermined)
        XCTAssertEqual(CalendarPermissionMapping.map(.restricted), .restricted)
        XCTAssertEqual(CalendarPermissionMapping.map(.denied), .denied)
        XCTAssertEqual(CalendarPermissionMapping.map(.writeOnly), .denied)
        XCTAssertEqual(CalendarPermissionMapping.map(.fullAccess), .authorized)
    }

    func testAlarmPermissionMapping() {
        XCTAssertEqual(AlarmPermissionMapping.map(.notDetermined), .notDetermined)
        XCTAssertEqual(AlarmPermissionMapping.map(.denied), .denied)
        XCTAssertEqual(AlarmPermissionMapping.map(.authorized), .authorized)
    }

    @MainActor
    func testProductionPermissionBoundariesAcceptMocks() async throws {
        let calendar = MockCalendarPermission()
        let alarm = MockAlarmPermission()

        let calendarResult = try await calendar.requestAccess()
        let alarmResult = try await alarm.requestAccess()

        XCTAssertEqual(calendarResult, .authorized)
        XCTAssertEqual(alarmResult, .denied)
        XCTAssertEqual(calendar.requestCount, 1)
        XCTAssertEqual(alarm.requestCount, 1)
    }

    @MainActor
    func testAppOwnedPersistenceRoundTrip() throws {
        let container = try PersistenceContainer.make(inMemory: true)
        let context = container.mainContext
        let settings = AppSettingsRecord()
        settings.settings = AppSettings(defaultLeadTime: .thirtyMinutes)
        context.insert(settings)
        context.insert(SelectedCalendarRecord(calendarIdentifier: "calendar-id"))
        context.insert(EventOverrideRecord(
            eventIdentity: "event-id",
            state: .disabled
        ))
        try context.save()

        let savedSettings = try XCTUnwrap(context.fetch(FetchDescriptor<AppSettingsRecord>()).first)
        let savedCalendar = try XCTUnwrap(context.fetch(FetchDescriptor<SelectedCalendarRecord>()).first)
        let savedOverride = try XCTUnwrap(context.fetch(FetchDescriptor<EventOverrideRecord>()).first)

        XCTAssertEqual(savedSettings.settings.defaultLeadTime, .thirtyMinutes)
        XCTAssertEqual(savedCalendar.calendarIdentifier, "calendar-id")
        XCTAssertEqual(savedOverride.eventIdentity, "event-id")
        XCTAssertFalse(savedOverride.isEnabled)
        XCTAssertNil(savedOverride.leadTimeMinutes)
    }
}

@MainActor
private final class MockCalendarPermission: CalendarPermissionProviding {
    var state: PermissionState = .notDetermined
    var requestCount = 0

    func requestAccess() async throws -> PermissionState {
        requestCount += 1
        state = .authorized
        return state
    }
}

@MainActor
private final class MockAlarmPermission: AlarmPermissionProviding {
    var state: PermissionState = .notDetermined
    var requestCount = 0

    func requestAccess() async throws -> PermissionState {
        requestCount += 1
        state = .denied
        return state
    }
}
