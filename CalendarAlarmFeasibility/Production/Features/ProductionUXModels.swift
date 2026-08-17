import Foundation

enum ProductionRoute: Equatable { case onboarding, main }
enum UserFacingLoadState: Equatable { case loading, content, empty, permissionBlocked, failed }

enum ProductionAccessibilityID {
    static let calendarPermissionAction = "onboarding.calendar.allow"
    static let alarmPermissionAction = "onboarding.alarm.allow"
    static let openSettingsAction = "permissions.open-settings"
    static let todayList = "today.list"
    static let upcomingList = "upcoming.list"
    static let eventAlarmToggle = "event.alarm.toggle"
    static let eventLeadTimePicker = "event.alarm.lead-picker"
    static let calendarList = "calendars.list"
    static let defaultLeadTimePicker = "settings.default-alarm-picker"
    static let retryAction = "content.retry"
}

enum SampleScenarioPolicy {
    static let supported: Set<String> = [
        "onboarding", "today", "today-long", "upcoming", "upcoming-empty",
        "detail-default", "detail-custom", "detail-off", "calendars",
        "calendars-long", "no-calendars", "settings", "denied", "alarm-denied",
        "empty", "error"
    ]

    static func scenario(arguments: [String]) -> String? {
#if DEBUG
        guard let value = arguments.first(where: { $0.hasPrefix("-UIScenario=") }) else { return nil }
        let scenario = String(value.dropFirst("-UIScenario=".count))
        return supported.contains(scenario) ? scenario : nil
#else
        return nil
#endif
    }
}

enum ProductionPresentationPolicy {
    static func route(calendar: PermissionState, alarm: PermissionState) -> ProductionRoute {
        calendar == .authorized && alarm == .authorized ? .main : .onboarding
    }

    static func shouldOfferSettings(calendar: PermissionState, alarm: PermissionState) -> Bool {
        calendar == .denied || alarm == .denied
    }

    static func sorted(_ events: [CalendarEvent]) -> [CalendarEvent] {
        events.sorted { ($0.startDate, $0.id) < ($1.startDate, $1.id) }
    }

    static func grouped(_ events: [CalendarEvent], calendar: Calendar = .current) -> [(Date, [CalendarEvent])] {
        Dictionary(grouping: sorted(events), by: { calendar.startOfDay(for: $0.startDate) }).sorted { $0.key < $1.key }
    }

    static func startTimeText(for event: CalendarEvent) -> String {
        event.startDate.formatted(date: .omitted, time: .shortened)
    }

    static func groupDateText(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    static func alarmText(event: CalendarEvent, override: EventOverride?, settings: AppSettings, now: Date) -> String {
        let policy = EventOverrideResolver().resolve(override: override, settings: settings)
        guard case .enabled(let lead) = policy else { return "Alarm off" }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else {
            return event.isAllDay ? "No alarm for all-day events" : "No upcoming alarm"
        }
        let alarmTime = candidate.alarmDate.formatted(date: .omitted, time: .shortened)
        return "Alarm \(lead.rawValue) minutes before, \(alarmTime)"
    }

    static func detailTimingText(lead: AlarmLeadTime?, settings: AppSettings) -> String {
        if let lead { return "Custom: \(lead.rawValue) minutes before" }
        return "Uses Default Alarm Time: \(settings.defaultLeadTime.rawValue) minutes before"
    }

    static func eventAccessibilityLabel(
        event: CalendarEvent,
        calendarTitle: String,
        override: EventOverride?,
        settings: AppSettings,
        now: Date
    ) -> String {
        "\(event.title). Starts \(startTimeText(for: event)). Calendar \(calendarTitle). \(alarmText(event: event, override: override, settings: settings, now: now))."
    }
}
