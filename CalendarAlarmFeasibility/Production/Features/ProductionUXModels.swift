import Foundation

enum ProductionRoute: Equatable { case onboarding, main }
enum UserFacingLoadState: Equatable { case loading, content, empty, permissionBlocked, failed }
enum OnboardingStep: Equatable { case calendarRationale, alarmRationale }

enum OnboardingFlow {
    static let initialStep = OnboardingStep.calendarRationale
    static let stepAfterCalendar = OnboardingStep.alarmRationale
}

struct PermissionRefreshSnapshot: Equatable {
    let calendar: PermissionState
    let alarm: PermissionState

    static func current(
        calendar: () -> PermissionState,
        alarm: () -> PermissionState
    ) -> PermissionRefreshSnapshot {
        PermissionRefreshSnapshot(calendar: calendar(), alarm: alarm())
    }
}

@MainActor
enum OnboardingPermissionSequence {
    static func resolve(
        state: PermissionState,
        request: () async throws -> PermissionState,
        authoritativeState: () -> PermissionState
    ) async -> PermissionState {
        PermissionDiagnostics.log("onboarding.resolve.begin", "input=\(state)")
        guard state == .notDetermined else {
            PermissionDiagnostics.log("onboarding.resolve.skipped", "output=\(state)")
            return state
        }
        do {
            let requestResult = try await request()
            PermissionDiagnostics.log("onboarding.resolve.end", "request=\(requestResult) output=\(requestResult)")
            return requestResult
        } catch {
            let output = authoritativeState()
            PermissionDiagnostics.log("onboarding.resolve.end", "request=nil error=\(String(describing: error)) output=\(output)")
            return output
        }
    }
}

enum OnboardingPermissionInvariant {
    static func canAdvanceToAlarm(calendar: PermissionState) -> Bool {
        calendar == .authorized
    }

    static func canComplete(calendar: PermissionState, alarm: PermissionState) -> Bool {
        calendar == .authorized && alarm == .authorized
    }
}

protocol OnboardingCompletionStoring {
    var isCompleted: Bool { get }
    func markCompleted()
}

final class UserDefaultsOnboardingCompletionStore: OnboardingCompletionStoring {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "production.onboarding.completed") {
        self.defaults = defaults
        self.key = key
    }

    var isCompleted: Bool { defaults.bool(forKey: key) }
    func markCompleted() { defaults.set(true, forKey: key) }
}

enum ProductionAccessibilityID {
    static let alarmTimelineList = "alarm-timeline.list"
    static let alarmTimelineCurrent = "alarm-timeline.current"
    static let alarmTimelineReturnToCurrent = "alarm-timeline.return-current"
    static let alarmTimelineEventPrefix = "alarm-timeline.event."
    static let calendarPermissionAction = "onboarding.calendar.allow"
    static let alarmPermissionAction = "onboarding.alarm.allow"
    static let openSettingsAction = "permissions.open-settings"
    static let todayList = "today.list"
    static let todayCurrentMarker = "today.current-marker"
    static let todayEventRowPrefix = "today.event."
    static let timelineList = "timeline.list"
    static let upcomingList = timelineList
    static let timelineCurrentBoundary = "timeline.current-boundary"
    static let timelineReturnToCurrent = "timeline.return-current"
    static let eventAlarmToggle = "event.alarm.toggle"
    static let eventLeadTimePicker = "event.alarm.lead-picker"
    static let calendarList = "calendars.list"
    static let defaultLeadTimePicker = "settings.default-alarm-picker"
    static let retryAction = "content.retry"
}

enum ProductionLocalization {
    static func text(_ key: String, locale: Locale? = nil) -> String {
        let bundle: Bundle
        if let locale,
           let languageCode = locale.language.languageCode?.identifier,
           let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let localizedBundle = Bundle(path: path) {
            bundle = localizedBundle
        } else {
            bundle = .main
        }
        return bundle.localizedString(forKey: key, value: nil, table: "Localizable")
    }

    static func format(_ key: String, locale: Locale? = nil, _ arguments: CVarArg...) -> String {
        String(format: text(key, locale: locale), locale: locale ?? .current, arguments: arguments)
    }
}

enum ProductionCopy {
    static var today: String { ProductionLocalization.text("timeline.today") }
    static var timeline: String { ProductionLocalization.text("timeline.events") }
    static var settings: String { ProductionLocalization.text("tab.settings") }
    static var calendars: String { ProductionLocalization.text("calendar.calendars") }
    static var calendarAccess: String { ProductionLocalization.text("permission.calendar_access") }
    static var alarmAccess: String { ProductionLocalization.text("permission.alarm_access") }
    static var defaultAlarmTime: String { ProductionLocalization.text("settings.default_alarm_time") }
    static var alarm: String { ProductionLocalization.text("tab.alarm") }
    static var retry: String { ProductionLocalization.text("action.retry") }
    static var openSettings: String { ProductionLocalization.text("action.open_settings") }
    static var returnToCurrent: String { ProductionLocalization.text("action.now") }
    static var emptyTodayTitle: String { ProductionLocalization.text("empty.today_title") }
    static var emptyTimelineTitle: String { ProductionLocalization.text("empty.timeline_title") }
    static var loadErrorTitle: String { ProductionLocalization.text("error.calendar_load_title") }
    static var permissionRecovery: String { ProductionLocalization.text("permission.recovery") }
    static var onboardingCalendarTitle: String { ProductionLocalization.text("onboarding.calendar_title") }
    static var onboardingAlarmTitle: String { ProductionLocalization.text("onboarding.alarm_title") }
    static var onboardingCalendarBody: String { ProductionLocalization.text("onboarding.calendar_body") }
    static var onboardingAlarmBody: String { ProductionLocalization.text("onboarding.alarm_body") }
    static var allowCalendar: String { ProductionLocalization.text("onboarding.allow_calendar") }
    static var allowAlarm: String { ProductionLocalization.text("onboarding.allow_alarm") }
    static var calendarRequiredTitle: String { ProductionLocalization.text("permission.calendar_required_title") }
    static var alarmRequiredTitle: String { ProductionLocalization.text("permission.alarm_required_title") }
    static var loadingEvents: String { ProductionLocalization.text("loading.events") }
    static var timelineDescription: String { ProductionLocalization.text("empty.timeline_description") }
    static var selectedCalendarDescription: String { ProductionLocalization.text("empty.selected_calendar_description") }
    static var returnToCurrentAccessibility: String { ProductionLocalization.text("accessibility.return_to_current_time") }
    static var returnToCurrentEventAccessibility: String { ProductionLocalization.text("accessibility.return_to_current_event") }
    static var current: String { ProductionLocalization.text("timeline.current") }
    static var currentTimeAccessibility: String { ProductionLocalization.text("accessibility.current_time") }
    static var retryDescription: String { ProductionLocalization.text("error.retry_description") }
    static var calendarFallback: String { ProductionLocalization.text("calendar.fallback") }
    static var endedEvent: String { ProductionLocalization.text("event.ended") }
    static var endedAlarmImmutable: String { ProductionLocalization.text("event.ended_alarm_immutable") }
    static var eventAlarmToggle: String { ProductionLocalization.text("event.alarm_toggle") }
    static var eventAlarmToggleHint: String { ProductionLocalization.text("event.alarm_toggle_hint") }
    static var timing: String { ProductionLocalization.text("event.timing") }
    static var useDefault: String { ProductionLocalization.text("event.use_default") }
    static var noAlarmForEvent: String { ProductionLocalization.text("event.no_alarm") }
    static var privacy: String { ProductionLocalization.text("event.privacy_title") }
    static var eventPrivacy: String { ProductionLocalization.text("event.privacy_body") }
    static var eventDetails: String { ProductionLocalization.text("event.details_title") }
    static var noCalendarsTitle: String { ProductionLocalization.text("calendar.none_title") }
    static var noCalendarsDescription: String { ProductionLocalization.text("calendar.none_description") }
    static var noSelectedCalendars: String { ProductionLocalization.text("calendar.none_selected_title") }
    static var noSelectedCalendarsDescription: String { ProductionLocalization.text("calendar.none_selected_description") }
    static var unnamedCalendar: String { ProductionLocalization.text("calendar.unnamed") }
    static var calendarToggleHint: String { ProductionLocalization.text("calendar.toggle_hint") }
    static var onDevice: String { ProductionLocalization.text("calendar.on_device") }
    static var defaultAlarmFooter: String { ProductionLocalization.text("settings.default_alarm_footer") }
    static var displayCalendars: String { ProductionLocalization.text("settings.display_calendars") }
    static var permissions: String { ProductionLocalization.text("settings.permissions") }
    static var about: String { ProductionLocalization.text("settings.about") }
    static var aboutBody: String { ProductionLocalization.text("settings.about_body") }
    static var phaseCompleted: String { ProductionLocalization.text("phase.completed") }
    static var phaseInProgress: String { ProductionLocalization.text("phase.in_progress") }
    static var phaseStarted: String { ProductionLocalization.text("phase.started") }
    static var phasePast: String { ProductionLocalization.text("phase.past") }
    static var phaseFuture: String { ProductionLocalization.text("phase.future") }
    static var allDay: String { ProductionLocalization.text("event.all_day") }
    static var noAlarm: String { ProductionLocalization.text("alarm.none") }
    static var noAlarmForAllDay: String { ProductionLocalization.text("alarm.none_all_day") }
    static var alarmTimePassed: String { ProductionLocalization.text("alarm.time_passed") }
    static var permissionAuthorized: String { ProductionLocalization.text("permission.authorized") }
    static var permissionDenied: String { ProductionLocalization.text("permission.denied") }
    static var permissionNotDetermined: String { ProductionLocalization.text("permission.not_determined") }
    static var permissionRestricted: String { ProductionLocalization.text("permission.restricted") }
    static var permissionUnavailable: String { ProductionLocalization.text("permission.unavailable") }
    static var tomorrow: String { ProductionLocalization.text("date.tomorrow") }
    static var yesterday: String { ProductionLocalization.text("date.yesterday") }
    static var fallbackEventTitle: String { ProductionLocalization.text("event.fallback_title") }

    static func minutesBefore(_ lead: AlarmLeadTime) -> String {
        if lead.rawValue == 60 { return ProductionLocalization.text("lead.one_hour_before") }
        return ProductionLocalization.format("lead.minutes_before", Int64(lead.rawValue))
    }

    static func todaySummary(count: Int) -> String {
        let key = count == 1 ? "timeline.today_summary_one" : "timeline.today_summary_other"
        return ProductionLocalization.format(key, Int64(count))
    }

    static func joinedStatus(_ timing: String, _ status: String) -> String {
        ProductionLocalization.format("alarm.joined_status", timing, status)
    }

    static func customTiming(_ timing: String) -> String {
        ProductionLocalization.format("event.custom_timing", timing)
    }

    static func defaultTiming(_ timing: String) -> String {
        ProductionLocalization.format("event.default_timing", timing)
    }

    static let primaryAuditStrings = [
        today, timeline, settings, calendars, calendarAccess, alarmAccess,
        defaultAlarmTime, alarm, retry, openSettings, returnToCurrent,
        emptyTodayTitle, emptyTimelineTitle, loadErrorTitle, permissionRecovery
    ]
}

/// A presentation-only clock. It owns no calendar, reconciliation, persistence,
/// or alarm-scheduling dependency, so a minute tick can only update rendered time.
@MainActor
final class ProductionPresentationClock: ObservableObject {
    @Published private(set) var now: Date
    private let nowProvider: () -> Date
    private let interval: TimeInterval
    private var timer: Timer?

    init(nowProvider: @escaping () -> Date = Date.init, interval: TimeInterval = 60) {
        self.nowProvider = nowProvider
        self.interval = interval
        now = nowProvider()
    }

    var isRunning: Bool { timer != nil }

    func activate() {
        refresh()
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func deactivate() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() { now = nowProvider() }

    deinit { timer?.invalidate() }
}

enum SampleScenarioPolicy {
#if DEBUG
    static let supported: Set<String> = [
        "onboarding", "onboarding-calendar", "onboarding-alarm", "calendar-denied", "main", "today", "today-long", "today-off", "timeline", "timeline-future", "timeline-no-future",
        "upcoming", "upcoming-empty", "detail-default", "detail-custom",
        "detail-off", "detail-past", "calendars", "calendars-long",
        "no-calendars", "settings", "denied", "alarm-denied", "empty", "error"
    ]

    static func scenario(arguments: [String]) -> String? {
        guard let value = arguments.first(where: { $0.hasPrefix("-UIScenario=") }) else { return nil }
        let scenario = String(value.dropFirst("-UIScenario=".count))
        return supported.contains(scenario) ? scenario : nil
    }
#else
    static func scenario(arguments: [String]) -> String? { nil }
#endif
}

struct TimelinePresentationWindow: Equatable {
    let start: Date
    let end: Date

    func contains(_ date: Date) -> Bool { start <= date && date < end }
}

struct TimelineDaySection: Identifiable, Equatable {
    let day: Date
    let events: [CalendarEvent]
    var id: Date { day }
}

enum TimelineAnchor: Equatable {
    case current
    case event(String)

    var id: String {
        switch self {
        case .current: ProductionAccessibilityID.timelineCurrentBoundary
        case .event(let id): "timeline.event.\(id)"
        }
    }
}

enum TimelineEventPhase: Equatable {
    case completed
    case inProgress
    case future
}

enum TodayPresentationItem: Identifiable, Equatable {
    case event(CalendarEvent)
    case current(Date)

    var id: String {
        switch self {
        case .event(let event): "today.event.\(event.id)"
        case .current: ProductionAccessibilityID.todayCurrentMarker
        }
    }
}

enum ProductionPresentationPolicy {
    static let calendarFetchPastDays = 14
    static let futureDisplayDays = 14

    static func route(onboardingCompleted: Bool) -> ProductionRoute {
        onboardingCompleted ? .main : .onboarding
    }

    static func shouldOfferSettings(calendar: PermissionState, alarm: PermissionState) -> Bool {
        calendar == .denied || alarm == .denied
    }

    static func sorted(_ events: [CalendarEvent]) -> [CalendarEvent] {
        events.sorted { ($0.startDate, $0.id) < ($1.startDate, $1.id) }
    }

    static func timelineWindow(now: Date, calendar: Calendar = .current) -> TimelinePresentationWindow {
        let today = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: futureDisplayDays, to: now) ?? now
        return .init(start: today, end: end)
    }

    static func calendarFetchWindow(now: Date, calendar: Calendar = .current) -> TimelinePresentationWindow {
        let today = calendar.startOfDay(for: now)
        let start = calendar.date(byAdding: .day, value: -calendarFetchPastDays, to: today) ?? today
        let end = calendar.date(byAdding: .day, value: futureDisplayDays, to: now) ?? now
        return .init(start: start, end: end)
    }

    static func timelineEvents(_ events: [CalendarEvent], now: Date, calendar: Calendar = .current) -> [CalendarEvent] {
        let window = timelineWindow(now: now, calendar: calendar)
        return sorted(events.filter { window.contains($0.startDate) })
    }

    static func timelineSections(_ events: [CalendarEvent], now: Date, calendar: Calendar = .current) -> [TimelineDaySection] {
        var grouped = Dictionary(grouping: timelineEvents(events, now: now, calendar: calendar)) {
            calendar.startOfDay(for: $0.startDate)
        }
        let today = calendar.startOfDay(for: now)
        grouped[today, default: []] = sorted(grouped[today, default: []])
        return grouped.keys.sorted().map { TimelineDaySection(day: $0, events: sorted(grouped[$0] ?? [])) }
    }

    static func initialTimelineAnchor(events: [CalendarEvent], now: Date, calendar: Calendar = .current) -> TimelineAnchor {
        let future = timelineEvents(events, now: now, calendar: calendar).first { $0.startDate >= now }
        guard let future else { return .current }
        return calendar.isDate(future.startDate, inSameDayAs: now) ? .current : .event(future.id)
    }

    static func returnToCurrentAnchor(events: [CalendarEvent], now: Date, calendar: Calendar = .current) -> TimelineAnchor {
        initialTimelineAnchor(events: events, now: now, calendar: calendar)
    }

    static func eventPhase(_ event: CalendarEvent, now: Date) -> TimelineEventPhase {
        if event.endDate <= now { return .completed }
        if event.startDate <= now { return .inProgress }
        return .future
    }

    /// Unified timeline classification intentionally crosses at startDate.
    static func alarmTimelinePhase(_ event: CalendarEvent, now: Date) -> TimelineEventPhase {
        event.startDate < now ? .completed : .future
    }

    static func phaseText(_ phase: TimelineEventPhase) -> String? {
        switch phase {
        case .completed: ProductionCopy.phaseCompleted
        case .inProgress: ProductionCopy.phaseInProgress
        case .future: nil
        }
    }

    static func startTimeText(for event: CalendarEvent) -> String {
        event.isAllDay ? ProductionCopy.allDay : event.startDate.formatted(date: .omitted, time: .shortened)
    }

    static func currentTimeText(_ now: Date) -> String {
        now.formatted(date: .omitted, time: .shortened)
    }

    static func todayItems(events: [CalendarEvent], now: Date) -> [TodayPresentationItem] {
        let ordered = sorted(events)
        let insertion = ordered.firstIndex { $0.startDate >= now } ?? ordered.endIndex
        var items = ordered.map(TodayPresentationItem.event)
        items.insert(.current(now), at: insertion)
        return items
    }

    static func todayAlarmText(event: CalendarEvent, override: EventOverride?, settings: AppSettings, now: Date) -> String {
        let policy = EventOverrideResolver().resolve(override: override, settings: settings)
        guard case .enabled(let lead) = policy else { return ProductionCopy.noAlarm }
        if event.isAllDay { return ProductionCopy.noAlarmForAllDay }
        switch eventPhase(event, now: now) {
        case .completed: return ProductionCopy.joinedStatus(ProductionCopy.minutesBefore(lead), ProductionCopy.phaseCompleted)
        case .inProgress: return ProductionCopy.joinedStatus(ProductionCopy.minutesBefore(lead), ProductionCopy.phaseInProgress)
        case .future: break
        }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else {
            return ProductionCopy.alarmTimePassed
        }
        return candidate.alarmDate.formatted(date: .omitted, time: .shortened)
    }

    static func alarmTimelineText(event: CalendarEvent, override: EventOverride?, settings: AppSettings, now: Date) -> String {
        let policy = EventOverrideResolver().resolve(override: override, settings: settings)
        guard case .enabled(let lead) = policy else { return ProductionCopy.noAlarm }
        if event.isAllDay { return ProductionCopy.noAlarmForAllDay }
        if event.startDate < now { return ProductionCopy.phaseCompleted }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else {
            return ProductionCopy.alarmTimePassed
        }
        return candidate.alarmDate.formatted(date: .omitted, time: .shortened)
    }

    static func alarmTimelineAccessibilityLabel(
        event: CalendarEvent,
        calendarTitle: String,
        override: EventOverride?,
        settings: AppSettings,
        now: Date
    ) -> String {
        let phase = alarmTimelinePhase(event, now: now) == .completed ? ProductionCopy.phasePast : ProductionCopy.phaseFuture
        return ProductionLocalization.format(
            "accessibility.timeline_event_format",
            event.title,
            startTimeText(for: event),
            phase,
            calendarTitle,
            alarmTimelineText(event: event, override: override, settings: settings, now: now)
        )
    }

    static func currentTimeAccessibilityLabel(_ now: Date) -> String {
        ProductionLocalization.format("accessibility.current_time_format", currentTimeText(now))
    }

    static func todayDateText(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide).day().weekday(.wide))
    }

    static func dayTitle(_ date: Date, now: Date, calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: now) { return ProductionCopy.today }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now), calendar.isDate(date, inSameDayAs: tomorrow) { return ProductionCopy.tomorrow }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: yesterday) { return ProductionCopy.yesterday }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    static func daySubtitle(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day().weekday(.wide))
    }

    static func alarmText(event: CalendarEvent, override: EventOverride?, settings: AppSettings, now: Date) -> String {
        let policy = EventOverrideResolver().resolve(override: override, settings: settings)
        guard case .enabled(let lead) = policy else { return ProductionCopy.noAlarm }
        if event.isAllDay { return ProductionCopy.noAlarmForAllDay }
        let timing = ProductionCopy.minutesBefore(lead)
        if event.endDate <= now { return ProductionCopy.joinedStatus(timing, ProductionCopy.phaseCompleted) }
        if event.startDate <= now { return ProductionCopy.joinedStatus(timing, ProductionCopy.phaseStarted) }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else {
            return ProductionCopy.joinedStatus(timing, ProductionCopy.alarmTimePassed)
        }
        let alarmTime = candidate.alarmDate.formatted(date: .omitted, time: .shortened)
        return ProductionCopy.joinedStatus(timing, alarmTime)
    }

    static func detailTimingText(lead: AlarmLeadTime?, settings: AppSettings) -> String {
        if let lead { return ProductionCopy.customTiming(ProductionCopy.minutesBefore(lead)) }
        return ProductionCopy.defaultTiming(ProductionCopy.minutesBefore(settings.defaultLeadTime))
    }

    static func permissionStatusText(_ state: PermissionState) -> String {
        switch state {
        case .authorized: ProductionCopy.permissionAuthorized
        case .denied: ProductionCopy.permissionDenied
        case .notDetermined: ProductionCopy.permissionNotDetermined
        case .restricted: ProductionCopy.permissionRestricted
        case .unavailable: ProductionCopy.permissionUnavailable
        }
    }

    static func eventAccessibilityLabel(
        event: CalendarEvent,
        calendarTitle: String,
        override: EventOverride?,
        settings: AppSettings,
        now: Date
    ) -> String {
        let alarm = alarmText(event: event, override: override, settings: settings, now: now)
        guard let phase = phaseText(eventPhase(event, now: now)) else {
            return ProductionLocalization.format(
                "accessibility.event_format_no_phase",
                event.title, startTimeText(for: event), calendarTitle, alarm
            )
        }
        return ProductionLocalization.format(
            "accessibility.event_format",
            event.title, startTimeText(for: event), calendarTitle, phase, alarm
        )
    }
}
