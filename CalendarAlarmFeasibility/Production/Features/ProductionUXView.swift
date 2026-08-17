import SwiftUI
import UIKit

@MainActor
final class ProductionUXViewModel: ObservableObject {
    @Published var calendarPermission: PermissionState
    @Published var alarmPermission: PermissionState
    @Published var events: [CalendarEvent] = []
    @Published var calendars: [CalendarDescriptor] = []
    @Published var enabledCalendarIDs: Set<String> = []
    @Published var overrides: [String: EventOverride] = [:]
    @Published var settings = AppSettings()
    @Published var loadState: UserFacingLoadState = .loading
    @Published var sampleScenario: String?

    let calendarPermissionProvider: any CalendarPermissionProviding
    let alarmPermissionProvider: any AlarmPermissionProviding
    private let source: CalendarSourceCoordinator
    private let selections: CalendarSelectionStore
    private let overrideStore: any EventOverrideStoring
    let overrideService: EventOverrideService
    private let settingsService: AppSettingsService
    private let reconciliation: CalendarReconciliationCoordinator

    init(dependencies: AppDependencies) {
        calendarPermissionProvider = dependencies.calendarPermission
        alarmPermissionProvider = dependencies.alarmPermission
        calendarPermission = dependencies.calendarPermission.state
        alarmPermission = dependencies.alarmPermission.state
        source = dependencies.calendarSource
        selections = dependencies.calendarSelections
        overrideStore = dependencies.overrideStore
        overrideService = dependencies.eventOverrides
        settingsService = dependencies.settingsService
        reconciliation = dependencies.reconciliation
        applySampleIfNeeded()
    }

    var route: ProductionRoute { ProductionPresentationPolicy.route(calendar: calendarPermission, alarm: alarmPermission) }
    var todayEvents: [CalendarEvent] { ProductionPresentationPolicy.sorted(events.filter { Calendar.current.isDateInToday($0.startDate) }) }
    var timelineEvents: [CalendarEvent] { ProductionPresentationPolicy.timelineEvents(events, now: Date()) }

    func refresh() async {
        guard sampleScenario == nil else { return }
        calendarPermission = calendarPermissionProvider.state
        alarmPermission = alarmPermissionProvider.state
        guard calendarPermission == .authorized else { loadState = .permissionBlocked; return }
        loadState = .loading
        do {
            let discovery = try await source.discover()
            calendars = discovery.calendars
            enabledCalendarIDs = discovery.enabledIdentifiers
            let now = Date()
            let displayWindow = ProductionPresentationPolicy.timelineWindow(now: now)
            events = try await source.fetch(in: .init(start: displayWindow.start, end: displayWindow.end))
            overrides = try await overrideStore.allOverrides()
            settings = try await settingsService.load()
            loadState = events.isEmpty ? .empty : .content
        } catch {
            loadState = .failed
        }
    }

    func requestCalendar() async {
        do { calendarPermission = try await calendarPermissionProvider.requestAccess() }
        catch { calendarPermission = .denied }
        await refresh()
    }

    func requestAlarm() async {
        do { alarmPermission = try await alarmPermissionProvider.requestAccess() }
        catch { alarmPermission = .denied }
        await refresh()
    }

    func setCalendar(_ enabled: Bool, id: String) async {
        do {
            try selections.setEnabled(enabled, calendarIdentifier: id)
            if enabled { enabledCalendarIDs.insert(id) } else { enabledCalendarIDs.remove(id) }
            await reconcile()
        } catch { loadState = .failed }
    }

    func setDefault(_ lead: AlarmLeadTime) async {
        do {
            try await settingsService.setDefaultLeadTime(lead)
            settings.defaultLeadTime = lead
            await refresh()
        } catch { loadState = .failed }
    }

    func applyOverride(_ state: EventAlarmOverride?, event: CalendarEvent) async {
        do {
            if let state { try await overrideService.set(state, for: event.id) }
            else { try await overrideService.reset(eventIdentity: event.id) }
            overrides = try await overrideStore.allOverrides()
            await refresh()
        } catch { loadState = .failed }
    }

    private func reconcile() async {
        let now = Date()
        _ = await reconciliation.trigger(now: now, window: .productionDefault(now: now))
    }

    private func applySampleIfNeeded() {
        guard let scenario = SampleScenarioPolicy.scenario(arguments: ProcessInfo.processInfo.arguments) else { return }
        sampleScenario = scenario
        let now = Date()
        let personal = CalendarDescriptor(id: "sample", title: "プライベート", source: .init(id: "icloud", title: "iCloud", typeDescription: "CalDAV"))
        let work = CalendarDescriptor(id: "work", title: "仕事", source: .init(id: "google", title: "Google", typeDescription: "CalDAV"))
        calendars = [personal, work]
        enabledCalendarIDs = ["sample", "work"]
        calendarPermission = scenario == "onboarding" ? .notDetermined : scenario == "denied" ? .denied : .authorized
        alarmPermission = scenario == "alarm-denied" ? .denied : .authorized

        let long = scenario == "today-long" || scenario == "calendars-long"
        if long {
            calendars = [
                .init(id: "sample", title: "家族の予定と大切な記念日を共有するカレンダー", source: .init(id: "icloud", title: "このiPhoneに保存されている個人用カレンダー", typeDescription: "CalDAV")),
                .init(id: "work", title: "プロダクト企画とお客さまとの打ち合わせ", source: .init(id: "google", title: "勤務先と組織のカレンダー", typeDescription: "CalDAV"))
            ]
        }

        let samples = [
            CalendarEvent(id: "two-days-ago", eventIdentifier: "two-days-ago", title: "プロジェクト振り返り", startDate: now.addingTimeInterval(-176_400), endDate: now.addingTimeInterval(-172_800), isAllDay: false, calendarID: "work"),
            CalendarEvent(id: "yesterday", eventIdentifier: "yesterday", title: "資料レビュー", startDate: now.addingTimeInterval(-90_000), endDate: now.addingTimeInterval(-86_400), isAllDay: false, calendarID: "work"),
            CalendarEvent(id: "completed-today", eventIdentifier: "completed-today", title: "朝の打ち合わせ", startDate: now.addingTimeInterval(-14_400), endDate: now.addingTimeInterval(-12_600), isAllDay: false, calendarID: "work"),
            CalendarEvent(id: "standup", eventIdentifier: "standup", title: long ? "アクセシビリティ改善についてプロダクトチーム全員で確認する定例ミーティング" : "チーム定例", startDate: now.addingTimeInterval(3_600), endDate: now.addingTimeInterval(5_400), isAllDay: false, calendarID: "work"),
            CalendarEvent(id: "dentist", eventIdentifier: "dentist", title: "歯科検診", startDate: now.addingTimeInterval(14_400), endDate: now.addingTimeInterval(16_200), isAllDay: false, calendarID: "sample"),
            CalendarEvent(id: "tomorrow", eventIdentifier: "tomorrow", title: "企画レビュー", startDate: now.addingTimeInterval(90_000), endDate: now.addingTimeInterval(93_600), isAllDay: false, calendarID: "work"),
            CalendarEvent(id: "planning", eventIdentifier: "planning", title: "リリース計画", startDate: now.addingTimeInterval(262_800), endDate: now.addingTimeInterval(266_400), isAllDay: false, calendarID: "sample")
        ]
        events = samples
        if scenario == "empty" || scenario == "upcoming-empty" { events = [] }
        if scenario == "timeline-no-future" { events = samples.filter { $0.startDate < now } }
        if scenario == "no-calendars" { calendars = []; enabledCalendarIDs = [] }
        if scenario == "detail-off" || scenario == "today-off" { overrides["standup"] = .init(eventIdentity: "standup", state: .disabled) }
        if scenario == "detail-custom" { overrides["standup"] = .init(eventIdentity: "standup", state: .enabled(leadTimeOverride: .fifteenMinutes)) }
        loadState = scenario == "error" ? .failed : events.isEmpty ? .empty : .content
    }
}

struct ProductionRootView: View {
    @StateObject private var model: ProductionUXViewModel
    let refreshGeneration: Int

    init(dependencies: AppDependencies, refreshGeneration: Int = 0) {
        self.refreshGeneration = refreshGeneration
        _model = StateObject(wrappedValue: ProductionUXViewModel(dependencies: dependencies))
    }

    var body: some View {
        Group {
            if model.route == .onboarding { OnboardingView(model: model) }
            else if let scenario = model.sampleScenario { sample(scenario) }
            else { MainTabsView(model: model) }
        }
        .task { await model.refresh() }
        .onChange(of: refreshGeneration) { _, _ in Task { await model.refresh() } }
    }

    @ViewBuilder
    private func sample(_ scenario: String) -> some View {
        switch scenario {
        case "main": MainTabsView(model: model)
        case "timeline", "timeline-no-future", "upcoming", "upcoming-empty":
            TimelineView(model: model)
        case "timeline-past": TimelineView(model: model, sampleInitialAnchor: .event("two-days-ago"))
        case "timeline-future": TimelineView(model: model, sampleInitialAnchor: .event("planning"))
        case "settings": SettingsView(model: model)
        case "calendars", "calendars-long", "no-calendars": NavigationStack { CalendarSelectionView(model: model) }
        case "detail-default", "detail-custom", "detail-off":
            NavigationStack { if let event = model.events.first(where: { $0.id == "standup" }) { EventDetailView(event: event, model: model) } }
        case "detail-past":
            NavigationStack { if let event = model.events.first(where: { $0.id == "completed-today" }) { EventDetailView(event: event, model: model) } }
        default: TodayView(model: model)
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 14) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundStyle(.orange)
                            .accessibilityHidden(true)
                        Text("予定を、アラームに")
                            .font(.title.bold())
                            .fixedSize(horizontal: false, vertical: true)
                        Text("iPhoneのカレンダーにある予定を読み取り、予定前にアラームを設定します。")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        OnboardingFeature(symbol: "calendar", title: "予定はそのまま", detail: "カレンダーの予定を変更することはありません。")
                        OnboardingFeature(symbol: "alarm", title: "本物のアラームでお知らせ", detail: "通知ではなく、時刻を指定したアラームを設定します。")
                        OnboardingFeature(symbol: "iphone", title: "このiPhoneの中で完結", detail: "アカウントやサーバーは必要ありません。")
                    }

                    VStack(spacing: 0) {
                        PermissionRow(title: ProductionCopy.calendarAccess, state: model.calendarPermission, actionTitle: "カレンダーへのアクセスを許可", identifier: ProductionAccessibilityID.calendarPermissionAction) {
                            Task { await model.requestCalendar() }
                        }
                        Divider().padding(.leading, 52)
                        PermissionRow(title: ProductionCopy.alarmAccess, state: model.alarmPermission, actionTitle: "アラームへのアクセスを許可", identifier: ProductionAccessibilityID.alarmPermissionAction) {
                            Task { await model.requestAlarm() }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))

                    if ProductionPresentationPolicy.shouldOfferSettings(calendar: model.calendarPermission, alarm: model.alarmPermission) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(ProductionCopy.permissionRecovery)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            OpenSettingsButton()
                        }
                    }
                }
                .frame(maxWidth: 620)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("はじめに")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct OnboardingFeature: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct PermissionRow: View {
    let title: String
    let state: PermissionState
    let actionTitle: String
    let identifier: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: state == .authorized ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(state == .authorized ? .green : .secondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    Text(ProductionPresentationPolicy.permissionStatusText(state)).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            if state == .notDetermined {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier(identifier)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
    }
}

private struct OpenSettingsButton: View {
    var body: some View {
        Button(ProductionCopy.openSettings) { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(minHeight: 44)
            .accessibilityIdentifier(ProductionAccessibilityID.openSettingsAction)
    }
}

struct MainTabsView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        TabView {
            TodayView(model: model)
                .tabItem { Label(ProductionCopy.today, systemImage: "sun.max") }
            TimelineView(model: model)
                .tabItem { Label(ProductionCopy.timeline, systemImage: "calendar") }
            SettingsView(model: model)
                .tabItem { Label(ProductionCopy.settings, systemImage: "gearshape") }
        }
    }
}

struct TodayView: View {
    @ObservedObject var model: ProductionUXViewModel
    @State private var now = Date()

    var body: some View {
        NavigationStack {
            Group {
                switch model.loadState {
                case .loading: ProgressView("予定を読み込んでいます")
                case .failed: LoadFailureView(model: model)
                default:
                    if model.todayEvents.isEmpty { empty }
                    else { list }
                }
            }
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(ProductionCopy.today)
                        .font(.largeTitle.bold())
                    Text(ProductionPresentationPolicy.todayDateText(now))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(ProductionCopy.todaySummary(count: model.todayEvents.count))
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 12)

                let items = ProductionPresentationPolicy.todayItems(events: model.todayEvents, now: now)
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    switch item {
                    case .event(let event):
                        NavigationLink { EventDetailView(event: event, model: model) } label: {
                            TodayTimelineEventRow(
                                event: event,
                                model: model,
                                now: now,
                                connectsAbove: index > 0,
                                connectsBelow: index < items.count - 1
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(ProductionAccessibilityID.todayEventRowPrefix + event.id)
                    case .current(let instant):
                        TodayCurrentTimeRow(
                            now: instant,
                            connectsAbove: index > 0,
                            connectsBelow: index < items.count - 1
                        )
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .accessibilityIdentifier(ProductionAccessibilityID.todayList)
        .refreshable { await model.refresh() }
    }

    private var empty: some View {
        ContentUnavailableView(ProductionCopy.emptyTodayTitle, systemImage: "calendar", description: Text("選択したカレンダーの予定がここに表示されます。"))
            .navigationTitle(ProductionCopy.today)
    }
}

private struct TodayTimelineEventRow: View {
    let event: CalendarEvent
    @ObservedObject var model: ProductionUXViewModel
    let now: Date
    let connectsAbove: Bool
    let connectsBelow: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize { accessibilityLayout }
            else { standardLayout }
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var standardLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            timeAndState
                .frame(width: 70, alignment: .leading)
                .padding(.top, 16)
            TodayTimelineRail(phase: phase, connectsAbove: connectsAbove, connectsBelow: connectsBelow)
                .frame(width: 32)
            details
                .padding(.vertical, 14)
        }
        .frame(minHeight: 82)
    }

    private var accessibilityLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            timeAndState.padding(.top, 14)
            HStack(alignment: .top, spacing: 8) {
                TodayTimelineRail(phase: phase, connectsAbove: connectsAbove, connectsBelow: connectsBelow)
                    .frame(width: 30)
                details.padding(.bottom, 14)
            }
        }
    }

    private var timeAndState: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(ProductionPresentationPolicy.startTimeText(for: event))
                .font(.title3.monospacedDigit().weight(.semibold))
                .fixedSize(horizontal: true, vertical: false)
            if let stateText {
                Text(stateText)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(isPast ? Color.secondary : Color.primary)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(isPast ? Color.secondary : Color.primary)
                .fixedSize(horizontal: false, vertical: true)
            Label(alarmText, systemImage: alarmIcon)
                .font(.subheadline.monospacedDigit().weight(.medium))
                .foregroundStyle(alarmColor)
                .fixedSize(horizontal: false, vertical: true)
            if connectsBelow { Divider().padding(.top, 5) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var phase: TimelineEventPhase { ProductionPresentationPolicy.eventPhase(event, now: now) }
    private var isPast: Bool { phase == .completed }
    private var stateText: String? { ProductionPresentationPolicy.phaseText(phase) }
    private var isOff: Bool { model.overrides[event.id]?.state == .disabled }
    private var alarmIcon: String { isOff ? "bell.slash" : "bell" }
    private var alarmColor: Color { isPast || isOff ? .secondary : .accentColor }
    private var alarmText: String {
        ProductionPresentationPolicy.todayAlarmText(event: event, override: model.overrides[event.id], settings: model.settings, now: now)
    }
    private var calendarName: String { model.calendars.first(where: { $0.id == event.calendarID })?.title ?? "カレンダー" }
    private var accessibilityLabel: String {
        ProductionPresentationPolicy.eventAccessibilityLabel(event: event, calendarTitle: calendarName, override: model.overrides[event.id], settings: model.settings, now: now)
    }
}

private struct TodayCurrentTimeRow: View {
    let now: Date
    let connectsAbove: Bool
    let connectsBelow: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(ProductionPresentationPolicy.currentTimeText(now))
                .font(.title3.monospacedDigit().weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 70, alignment: .leading)
            TodayTimelineRail(phase: nil, connectsAbove: connectsAbove, connectsBelow: connectsBelow)
                .frame(width: 32)
            HStack(spacing: 10) {
                Text("現在")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
                    .fixedSize()
                DashedCurrentRule()
            }
        }
        .frame(minHeight: 58)
        .padding(.horizontal, 20)
        .id(ProductionAccessibilityID.todayCurrentMarker)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ProductionPresentationPolicy.currentTimeAccessibilityLabel(now))
    }

}

private struct TodayTimelineRail: View {
    let phase: TimelineEventPhase?
    let connectsAbove: Bool
    let connectsBelow: Bool

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Rectangle().fill(connectsAbove ? Color.secondary.opacity(0.18) : Color.clear)
                Rectangle().fill(connectsBelow ? Color.secondary.opacity(0.18) : Color.clear)
            }
            .frame(width: 1)
            marker.padding(.top, 22)
        }
        .frame(maxHeight: .infinity)
        .accessibilityHidden(true)
    }

    @ViewBuilder private var marker: some View {
        if phase == nil {
            Circle().fill(Color.accentColor).frame(width: 12, height: 12)
        } else if phase == .completed {
            ZStack {
                Circle().fill(Color.secondary)
                Image(systemName: "checkmark")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(Color(uiColor: .systemBackground))
            }
            .frame(width: 18, height: 18)
        } else {
            Circle()
                .fill(Color(uiColor: .systemBackground))
                .overlay { Circle().stroke(Color.accentColor, lineWidth: 2) }
                .frame(width: 16, height: 16)
        }
    }
}

private struct DashedCurrentRule: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .init(x: 0, y: geometry.size.height / 2))
                path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height / 2))
            }
            .stroke(Color.accentColor.opacity(0.42), style: .init(lineWidth: 1, dash: [4, 5]))
        }
        .frame(height: 1)
        .accessibilityHidden(true)
    }
}

struct TimelineView: View {
    @ObservedObject var model: ProductionUXViewModel
    var sampleInitialAnchor: TimelineAnchor?
    @State private var now = Date()
    @State private var hasPositioned = false

    init(model: ProductionUXViewModel, sampleInitialAnchor: TimelineAnchor? = nil) {
        self.model = model
        self.sampleInitialAnchor = sampleInitialAnchor
    }

    var body: some View {
        NavigationStack {
            Group {
                switch model.loadState {
                case .loading: ProgressView("予定を読み込んでいます")
                case .failed: LoadFailureView(model: model)
                default:
                    if model.timelineEvents.isEmpty { empty }
                    else { timeline }
                }
            }
            .navigationTitle(ProductionCopy.timeline)
        }
    }

    private var timeline: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(ProductionPresentationPolicy.timelineSections(model.timelineEvents, now: now)) { section in
                    Section {
                        let before = section.events.filter { $0.startDate < now }
                        let after = section.events.filter { $0.startDate >= now }
                        ForEach(before) { event in timelineLink(event) }
                        if Calendar.current.isDate(section.day, inSameDayAs: now) { CurrentBoundaryView() }
                        ForEach(after) { event in timelineLink(event) }
                    } header: {
                        TimelineDateHeader(day: section.day, now: now)
                    }
                }
            }
            .listStyle(.plain)
            .accessibilityIdentifier(ProductionAccessibilityID.timelineList)
            .refreshable { await model.refresh() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(ProductionCopy.returnToCurrent) { scrollToCurrent(proxy) }
                        .accessibilityLabel("現在の予定へ戻る")
                        .accessibilityIdentifier(ProductionAccessibilityID.timelineReturnToCurrent)
                }
            }
            .onAppear {
                guard !hasPositioned else { return }
                hasPositioned = true
                DispatchQueue.main.async {
                    if let sampleInitialAnchor { proxy.scrollTo(sampleInitialAnchor.id, anchor: .top) }
                    else { scrollToCurrent(proxy) }
                }
            }
        }
    }

    private var empty: some View {
        ContentUnavailableView(ProductionCopy.emptyTimelineTitle, systemImage: "calendar.badge.exclamationmark", description: Text("過去14日から今後14日までの予定がここに表示されます。"))
    }

    private func timelineLink(_ event: CalendarEvent) -> some View {
        NavigationLink { EventDetailView(event: event, model: model) } label: {
            EventRow(event: event, model: model, now: now)
        }
        .id(TimelineAnchor.event(event.id).id)
    }

    private func scrollToCurrent(_ proxy: ScrollViewProxy) {
        let anchor = ProductionPresentationPolicy.returnToCurrentAnchor(events: model.timelineEvents, now: now)
        proxy.scrollTo(anchor.id, anchor: .top)
    }
}

private struct TimelineDateHeader: View {
    let day: Date
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ProductionPresentationPolicy.dayTitle(day, now: now))
                .font(.headline)
                .foregroundStyle(.primary)
            Text(ProductionPresentationPolicy.daySubtitle(day))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .textCase(nil)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }
}

private struct CurrentBoundaryView: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle().frame(height: 1).foregroundStyle(.orange.opacity(0.55))
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                Text("現在")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.orange)
            .fixedSize()
            Rectangle().frame(height: 1).foregroundStyle(.orange.opacity(0.55))
        }
        .padding(.vertical, 6)
        .listRowSeparator(.hidden)
        .id(ProductionAccessibilityID.timelineCurrentBoundary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("現在の時刻")
    }
}

private struct LoadFailureView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(ProductionCopy.loadErrorTitle, systemImage: "exclamationmark.triangle", description: Text("しばらくしてからもう一度お試しください。"))
            Button(ProductionCopy.retry) { Task { await model.refresh() } }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(minHeight: 44)
                .accessibilityIdentifier(ProductionAccessibilityID.retryAction)
        }
        .padding()
    }
}

struct EventRow: View {
    let event: CalendarEvent
    @ObservedObject var model: ProductionUXViewModel
    let now: Date
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    timeAndPhase
                    details
                }
            } else {
                HStack(alignment: .top, spacing: 14) {
                    timeAndPhase.frame(width: 64, alignment: .leading)
                    details
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var timeAndPhase: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(ProductionPresentationPolicy.startTimeText(for: event))
                .font(.subheadline.monospacedDigit().weight(.semibold))
            if let phaseText {
                Text(phaseText).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(event.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
            Text(calendarName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Label(alarmText, systemImage: isOff ? "bell.slash" : "alarm")
                .font(.subheadline)
                .foregroundStyle(isOff || isPast ? Color.secondary : Color.accentColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var calendarName: String { model.calendars.first(where: { $0.id == event.calendarID })?.title ?? "カレンダー" }
    private var phaseText: String? { ProductionPresentationPolicy.phaseText(ProductionPresentationPolicy.eventPhase(event, now: now)) }
    private var isPast: Bool { ProductionPresentationPolicy.eventPhase(event, now: now) == .completed }
    private var isOff: Bool { model.overrides[event.id]?.state == .disabled }
    private var alarmText: String { ProductionPresentationPolicy.alarmText(event: event, override: model.overrides[event.id], settings: model.settings, now: now) }
    private var accessibilityLabel: String { ProductionPresentationPolicy.eventAccessibilityLabel(event: event, calendarTitle: calendarName, override: model.overrides[event.id], settings: model.settings, now: now) }
}

struct EventDetailView: View {
    let event: CalendarEvent
    @ObservedObject var model: ProductionUXViewModel
    @State private var enabled = true
    @State private var lead: AlarmLeadTime?
    @State private var now = Date()
    @State private var initialized = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.title)
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)
                    Label(event.startDate.formatted(date: .complete, time: .shortened), systemImage: "calendar")
                        .fixedSize(horizontal: false, vertical: true)
                    Label(calendarName, systemImage: "rectangle.stack")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if isPast {
                        Label("終了した予定", systemImage: "checkmark.circle")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 14) {
                    Text(ProductionCopy.alarm).font(.title2.bold())
                    if isPast {
                        Label("終了した予定のアラームは変更できません", systemImage: "clock.badge.xmark")
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        VStack(spacing: 0) {
                            Toggle("この予定でアラームを使う", isOn: $enabled)
                                .padding(16)
                                .accessibilityIdentifier(ProductionAccessibilityID.eventAlarmToggle)
                                .accessibilityHint("この予定のアラームをオンまたはオフにします")
                            if enabled {
                                Divider().padding(.leading, 16)
                                Picker("タイミング", selection: $lead) {
                                    Text("デフォルト設定を使用").tag(AlarmLeadTime?.none)
                                    ForEach(AlarmLeadTime.allCases, id: \.self) { Text(ProductionCopy.minutesBefore($0)).tag(Optional($0)) }
                                }
                                .padding(16)
                                .accessibilityIdentifier(ProductionAccessibilityID.eventLeadTimePicker)
                            }
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))

                        Text(enabled ? ProductionPresentationPolicy.detailTimingText(lead: lead, settings: model.settings) : "この予定にはアラームを設定しません")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("プライバシー").font(.headline)
                    Text("この予定はアラームの設定にだけ使用します。カレンダーの内容を変更することはありません。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: 620, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("予定の詳細")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let value = model.overrides[event.id] {
                switch value.state {
                case .disabled: enabled = false; lead = nil
                case .enabled(let custom): enabled = true; lead = custom
                }
            }
            initialized = true
        }
        .onChange(of: enabled) { _, value in
            guard initialized, !isPast else { return }
            Task { await model.applyOverride(value ? .enabled(leadTimeOverride: lead) : .disabled, event: event) }
        }
        .onChange(of: lead) { _, value in
            guard initialized, enabled, !isPast else { return }
            Task { await model.applyOverride(value == nil ? nil : .enabled(leadTimeOverride: value), event: event) }
        }
    }

    private var calendarName: String { model.calendars.first(where: { $0.id == event.calendarID })?.title ?? "カレンダー" }
    private var isPast: Bool { event.startDate <= now }
}

struct CalendarSelectionView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        Group {
            if model.calendars.isEmpty {
                ContentUnavailableView("カレンダーがありません", systemImage: "calendar.badge.exclamationmark", description: Text("このiPhoneで利用できるカレンダーがここに表示されます。"))
            } else {
                Form {
                    if model.enabledCalendarIDs.isEmpty {
                        Section {
                            Label("選択中のカレンダーはありません", systemImage: "exclamationmark.circle")
                            Text("予定を表示するカレンダーをオンにしてください。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    ForEach(sourceTitles, id: \.self) { source in
                        Section(source) {
                            ForEach(calendars(for: source)) { calendar in
                                Toggle(isOn: Binding(get: { model.enabledCalendarIDs.contains(calendar.id) }, set: { value in Task { await model.setCalendar(value, id: calendar.id) } })) {
                                    Text(calendar.title.isEmpty ? "名称未設定のカレンダー" : calendar.title)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .accessibilityHint("このカレンダーの予定を表示するか選択します")
                            }
                        }
                    }
                }
                .accessibilityIdentifier(ProductionAccessibilityID.calendarList)
            }
        }
        .navigationTitle(ProductionCopy.calendars)
    }

    private var sourceTitles: [String] { Set(model.calendars.map(sourceTitle)).sorted() }
    private func sourceTitle(_ calendar: CalendarDescriptor) -> String { calendar.source.title.isEmpty ? "このiPhone内" : calendar.source.title }
    private func calendars(for source: String) -> [CalendarDescriptor] { model.calendars.filter { sourceTitle($0) == source } }
}

struct SettingsView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(ProductionCopy.defaultAlarmTime, selection: Binding(get: { model.settings.defaultLeadTime }, set: { value in Task { await model.setDefault(value) } })) {
                        ForEach(AlarmLeadTime.allCases, id: \.self) { Text(ProductionCopy.minutesBefore($0)).tag($0) }
                    }
                    .accessibilityIdentifier(ProductionAccessibilityID.defaultLeadTimePicker)
                } header: { Text(ProductionCopy.defaultAlarmTime) }
                  footer: { Text("予定ごとに変更しない場合、この時間が使われます。") }

                Section(ProductionCopy.calendars) {
                    NavigationLink { CalendarSelectionView(model: model) } label: {
                        Label("表示するカレンダー", systemImage: "calendar")
                    }
                }

                Section("アクセス権") {
                    permissionStatus(ProductionCopy.calendarAccess, model.calendarPermission)
                    permissionStatus(ProductionCopy.alarmAccess, model.alarmPermission)
                    if ProductionPresentationPolicy.shouldOfferSettings(calendar: model.calendarPermission, alarm: model.alarmPermission) {
                        Text(ProductionCopy.permissionRecovery)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        OpenSettingsButton()
                    }
                }

                Section("このアプリについて") {
                    Text("カレンダーの予定を読み取り、アラームを作成します。カレンダー自体は変更しません。アプリの設定は端末内に保存され、アカウントやサーバーは必要ありません。")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle(ProductionCopy.settings)
        }
    }

    private func permissionStatus(_ title: String, _ state: PermissionState) -> some View {
        LabeledContent(title, value: ProductionPresentationPolicy.permissionStatusText(state))
    }
}
