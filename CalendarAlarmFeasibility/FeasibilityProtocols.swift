import Foundation

@MainActor
protocol CalendarEventProviding {
    var authorizationStatus: CalendarAuthorizationStatus { get }
    func requestAccessAndFetchEvents(now: Date) async throws -> [FeasibilityCalendarEvent]
}

@MainActor
protocol AlarmScheduling {
    var authorizationStatus: AlarmAuthorizationStatus { get }
    func requestAuthorizationIfNeeded() async throws -> AlarmAuthorizationStatus
    func scheduleOneShot(at date: Date, title: String) async throws -> ScheduledAlarmResult
}
