import Foundation
import XCTest
@testable import CalendarAlarmFeasibility

@MainActor
final class ServiceBoundaryTests: XCTestCase {
    func testPlatformServicesCanBeReplacedByMocks() async {
        let now = Date(timeIntervalSinceReferenceDate: 2_000_000)
        let calendar = MockCalendarProvider()
        let alarm = MockAlarmScheduler()
        let viewModel = FeasibilityViewModel(
            calendarProvider: calendar,
            alarmScheduler: alarm,
            now: { now }
        )

        await viewModel.fetchEvents()
        await viewModel.scheduleTestAlarm()

        XCTAssertEqual(calendar.fetchCount, 1)
        XCTAssertEqual(alarm.scheduledDates, [now.addingTimeInterval(2 * 60)])
    }
}

@MainActor
private final class MockCalendarProvider: CalendarEventProviding {
    var authorizationStatus = CalendarAuthorizationStatus.authorized
    var fetchCount = 0

    func requestAccessAndFetchEvents(now: Date) async throws -> [FeasibilityCalendarEvent] {
        fetchCount += 1
        return []
    }
}

@MainActor
private final class MockAlarmScheduler: AlarmScheduling {
    var authorizationStatus = AlarmAuthorizationStatus.authorized
    var scheduledDates: [Date] = []

    func requestAuthorizationIfNeeded() async throws -> AlarmAuthorizationStatus {
        authorizationStatus
    }

    func scheduleOneShot(at date: Date, title: String) async throws -> ScheduledAlarmResult {
        scheduledDates.append(date)
        return ScheduledAlarmResult(id: UUID(), date: date)
    }
}
