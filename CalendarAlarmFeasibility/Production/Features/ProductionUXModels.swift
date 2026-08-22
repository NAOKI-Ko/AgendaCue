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
        guard state == .notDetermined else { return state }
        do { _ = try await request() } catch { }
        return authoritativeState()
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

enum ProductionCopy {
    static let today = "今日"
    static let timeline = "予定"
    static let settings = "設定"
    static let calendars = "カレンダー"
    static let calendarAccess = "カレンダーへのアクセス"
    static let alarmAccess = "アラームへのアクセス"
    static let defaultAlarmTime = "デフォルトのアラーム時間"
    static let alarm = "アラーム"
    static let retry = "再試行"
    static let openSettings = "設定を開く"
    static let returnToCurrent = "現在へ"
    static let emptyTodayTitle = "今日の予定はありません"
    static let emptyTimelineTitle = "表示できる予定がありません"
    static let loadErrorTitle = "カレンダーを読み込めません"
    static let permissionRecovery = "設定でアクセスを許可したあと、このアプリに戻ってください。"

    static func minutesBefore(_ lead: AlarmLeadTime) -> String { "\(lead.rawValue)分前" }
    static func todaySummary(count: Int) -> String { "今日の予定は\(count)件です" }

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
    static let supported: Set<String> = [
        "onboarding", "onboarding-calendar", "onboarding-alarm", "calendar-denied", "main", "today", "today-long", "today-off", "timeline", "timeline-future", "timeline-no-future",
        "upcoming", "upcoming-empty", "detail-default", "detail-custom",
        "detail-off", "detail-past", "calendars", "calendars-long",
        "no-calendars", "settings", "denied", "alarm-denied", "empty", "error"
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
        case .completed: "終了済み"
        case .inProgress: "開催中"
        case .future: nil
        }
    }

    static func startTimeText(for event: CalendarEvent) -> String {
        event.isAllDay ? "終日" : event.startDate.formatted(date: .omitted, time: .shortened)
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
        guard case .enabled(let lead) = policy else { return "アラームなし" }
        if event.isAllDay { return "終日予定にはアラームなし" }
        switch eventPhase(event, now: now) {
        case .completed: return "\(ProductionCopy.minutesBefore(lead))・終了済み"
        case .inProgress: return "\(ProductionCopy.minutesBefore(lead))・開催中"
        case .future: break
        }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else {
            return "アラーム時刻を経過"
        }
        return candidate.alarmDate.formatted(date: .omitted, time: .shortened)
    }

    static func alarmTimelineText(event: CalendarEvent, override: EventOverride?, settings: AppSettings, now: Date) -> String {
        let policy = EventOverrideResolver().resolve(override: override, settings: settings)
        guard case .enabled(let lead) = policy else { return "アラームなし" }
        if event.isAllDay { return "終日予定にはアラームなし" }
        if event.startDate < now { return "終了済み" }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else {
            return "アラーム時刻を経過"
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
        let phase = alarmTimelinePhase(event, now: now) == .completed ? "過去" : "未来"
        return "\(event.title)、開始 \(startTimeText(for: event))、\(phase)、カレンダー \(calendarTitle)、アラーム \(alarmTimelineText(event: event, override: override, settings: settings, now: now))"
    }

    static func currentTimeAccessibilityLabel(_ now: Date) -> String {
        "現在、\(currentTimeText(now))"
    }

    static func todayDateText(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide).day().weekday(.wide))
    }

    static func dayTitle(_ date: Date, now: Date, calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: now) { return "今日" }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now), calendar.isDate(date, inSameDayAs: tomorrow) { return "明日" }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: yesterday) { return "昨日" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    static func daySubtitle(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day().weekday(.wide))
    }

    static func alarmText(event: CalendarEvent, override: EventOverride?, settings: AppSettings, now: Date) -> String {
        let policy = EventOverrideResolver().resolve(override: override, settings: settings)
        guard case .enabled(let lead) = policy else { return "アラームなし" }
        if event.isAllDay { return "終日予定にはアラームなし" }
        let timing = ProductionCopy.minutesBefore(lead)
        if event.endDate <= now { return "\(timing)・終了済み" }
        if event.startDate <= now { return "\(timing)・開始済み" }
        guard case .candidate(let candidate) = AlarmRuleEngine().evaluate(event: event, leadTime: lead, now: now) else {
            return "\(timing)・アラーム時刻を経過"
        }
        let alarmTime = candidate.alarmDate.formatted(date: .omitted, time: .shortened)
        return "\(timing)・\(alarmTime)"
    }

    static func detailTimingText(lead: AlarmLeadTime?, settings: AppSettings) -> String {
        if let lead { return "この予定のみ \(ProductionCopy.minutesBefore(lead))" }
        return "デフォルト設定（\(ProductionCopy.minutesBefore(settings.defaultLeadTime))）を使用"
    }

    static func permissionStatusText(_ state: PermissionState) -> String {
        switch state {
        case .authorized: "許可済み"
        case .denied: "設定から許可してください"
        case .notDetermined: "許可が必要です"
        case .restricted: "このiPhoneでは制限されています"
        case .unavailable: "このiPhoneでは利用できません"
        }
    }

    static func eventAccessibilityLabel(
        event: CalendarEvent,
        calendarTitle: String,
        override: EventOverride?,
        settings: AppSettings,
        now: Date
    ) -> String {
        let phase = phaseText(eventPhase(event, now: now)).map { "、\($0)" } ?? ""
        return "\(event.title)、開始 \(startTimeText(for: event))、カレンダー \(calendarTitle)\(phase)、アラーム \(alarmText(event: event, override: override, settings: settings, now: now))"
    }
}
