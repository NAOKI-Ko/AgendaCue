import Foundation

enum PermissionState: String, Codable, Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case unavailable
}

enum AlarmLeadTime: Int, CaseIterable, Codable, Equatable, Sendable {
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60

    static let `default`: AlarmLeadTime = .fiveMinutes

    var duration: TimeInterval {
        TimeInterval(rawValue * 60)
    }
}

struct AppSettings: Equatable, Sendable {
    var defaultLeadTime: AlarmLeadTime = .default
}

struct CalendarSource: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let typeDescription: String
}

struct CalendarDescriptor: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let source: CalendarSource
}

struct CalendarEvent: Identifiable, Equatable, Sendable {
    let id: String
    let eventIdentifier: String?
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendarID: CalendarDescriptor.ID
}

struct CalendarInterval: Equatable, Sendable {
    let start: Date
    let end: Date
}

struct AlarmCandidate: Identifiable, Equatable, Sendable {
    let id: String
    let calendarIdentifier: CalendarDescriptor.ID
    let eventIdentifier: String?
    let eventTitle: String
    let eventStartDate: Date
    let alarmDate: Date
    let appliedLeadTime: AlarmLeadTime
}

enum EventAlarmOverride: Equatable, Sendable {
    case enabled(leadTimeOverride: AlarmLeadTime?)
    case disabled
}

struct EventOverride: Identifiable, Equatable, Sendable {
    var id: String { eventIdentity }
    let eventIdentity: String
    let state: EventAlarmOverride
}

enum EffectiveEventAlarmPolicy: Equatable, Sendable { case enabled(AlarmLeadTime), disabled }

struct EventOverrideResolver {
    func resolve(override: EventOverride?, settings: AppSettings) -> EffectiveEventAlarmPolicy {
        switch override?.state {
        case .disabled: .disabled
        case .enabled(let leadTime): .enabled(leadTime ?? settings.defaultLeadTime)
        case nil: .enabled(settings.defaultLeadTime)
        }
    }
}
