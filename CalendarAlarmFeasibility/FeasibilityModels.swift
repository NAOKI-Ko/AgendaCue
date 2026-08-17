import Foundation

struct FeasibilityCalendarEvent: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let eventIdentifier: String
    let calendarIdentifier: String
    let calendarTitle: String
    let sourceTitle: String
    let sourceType: String
}

enum CalendarAuthorizationStatus: String, Sendable {
    case notDetermined
    case denied
    case restricted
    case authorized
    case unknown
}

enum AlarmAuthorizationStatus: String, Sendable {
    case notDetermined
    case denied
    case authorized
}

struct ScheduledAlarmResult: Equatable, Sendable {
    let id: UUID
    let date: Date
}
