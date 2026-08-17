import Foundation

enum ProductionRoute: Equatable { case onboarding, main }
enum UserFacingLoadState: Equatable { case loading, content, empty, permissionBlocked, failed }

enum ProductionPresentationPolicy {
    static func route(calendar: PermissionState, alarm: PermissionState) -> ProductionRoute {
        calendar == .authorized && alarm == .authorized ? .main : .onboarding
    }
    static func sorted(_ events: [CalendarEvent]) -> [CalendarEvent] { events.sorted { ($0.startDate, $0.id) < ($1.startDate, $1.id) } }
    static func grouped(_ events: [CalendarEvent], calendar: Calendar = .current) -> [(Date, [CalendarEvent])] {
        Dictionary(grouping: sorted(events), by: { calendar.startOfDay(for: $0.startDate) }).sorted { $0.key < $1.key }
    }
    static func alarmText(event: CalendarEvent, override: EventOverride?, settings: AppSettings, now: Date) -> String {
        let policy = EventOverrideResolver().resolve(override: override, settings: settings)
        guard case .enabled(let lead) = policy else { return "Alarm off" }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else { return event.isAllDay ? "No alarm for all-day events" : "No upcoming alarm" }
        return "Alarm \(lead.rawValue) min before · \(candidate.alarmDate.formatted(date: .omitted, time: .shortened))"
    }
}
