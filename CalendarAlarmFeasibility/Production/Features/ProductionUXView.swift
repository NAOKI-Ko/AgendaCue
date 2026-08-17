import EventKit
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
    var upcomingEvents: [CalendarEvent] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        return ProductionPresentationPolicy.sorted(events.filter { $0.startDate >= tomorrow })
    }

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
            events = try await source.fetch(in: .init(start: Calendar.current.startOfDay(for: now), end: now.addingTimeInterval(14 * 86_400)))
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
        let personal = CalendarDescriptor(id: "sample", title: "Personal", source: .init(id: "icloud", title: "iCloud", typeDescription: "CalDAV"))
        let work = CalendarDescriptor(id: "work", title: "Work", source: .init(id: "google", title: "Google", typeDescription: "CalDAV"))
        calendars = [personal, work]
        enabledCalendarIDs = ["sample", "work"]
        calendarPermission = scenario == "onboarding" ? .notDetermined : scenario == "denied" ? .denied : .authorized
        alarmPermission = scenario == "alarm-denied" ? .denied : .authorized

        let long = scenario == "today-long" || scenario == "calendars-long"
        if long {
            calendars = [
                .init(id: "sample", title: "Family appointments and important shared celebrations", source: .init(id: "icloud", title: "Personal calendars stored on this iPhone", typeDescription: "CalDAV")),
                .init(id: "work", title: "International product planning and customer meetings", source: .init(id: "google", title: "Work and organization calendars", typeDescription: "CalDAV"))
            ]
        }

        let samples = [
            CalendarEvent(id: "standup", eventIdentifier: "standup", title: long ? "Daily product design stand-up with the international accessibility working group" : "Daily stand-up", startDate: now.addingTimeInterval(3_600), endDate: now.addingTimeInterval(5_400), isAllDay: false, calendarID: "work"),
            CalendarEvent(id: "dentist", eventIdentifier: "dentist", title: "Dentist appointment", startDate: now.addingTimeInterval(14_400), endDate: now.addingTimeInterval(16_200), isAllDay: false, calendarID: "sample"),
            CalendarEvent(id: "tomorrow", eventIdentifier: "tomorrow", title: "Project review", startDate: now.addingTimeInterval(90_000), endDate: now.addingTimeInterval(93_600), isAllDay: false, calendarID: "work"),
            CalendarEvent(id: "planning", eventIdentifier: "planning", title: "Release planning", startDate: now.addingTimeInterval(176_400), endDate: now.addingTimeInterval(180_000), isAllDay: false, calendarID: "sample")
        ]
        events = samples
        if scenario == "empty" || scenario == "upcoming-empty" { events = [] }
        if scenario == "no-calendars" { calendars = []; enabledCalendarIDs = [] }
        if scenario == "detail-off" { overrides["standup"] = .init(eventIdentity: "standup", state: .disabled) }
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
        case "upcoming", "upcoming-empty":
            EventListView(title: "Upcoming", events: model.upcomingEvents, emptyTitle: "No upcoming events", emptyDescription: "Events in the next 14 days will appear here.", model: model, grouped: true, listAccessibilityID: ProductionAccessibilityID.upcomingList)
        case "settings": SettingsView(model: model)
        case "calendars", "calendars-long", "no-calendars": NavigationStack { CalendarSelectionView(model: model) }
        case "detail-default", "detail-custom", "detail-off": NavigationStack { if let event = model.events.first { EventDetailView(event: event, model: model) } }
        default:
            EventListView(title: "Today", events: model.todayEvents, emptyTitle: "No events today", emptyDescription: "Events from selected calendars will appear here.", model: model, listAccessibilityID: ProductionAccessibilityID.todayList)
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 64))
                        .foregroundStyle(.orange)
                        .accessibilityHidden(true)
                    Text("Calendar Alarm").font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text("Calendar Alarm reads calendar events to create alarms. It never edits calendar events, and its settings stay on this device.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    VStack(spacing: 12) {
                        PermissionCard(title: "Calendar Access", state: model.calendarPermission, actionTitle: "Allow Calendar Access", identifier: ProductionAccessibilityID.calendarPermissionAction) { Task { await model.requestCalendar() } }
                        PermissionCard(title: "Alarm Access", state: model.alarmPermission, actionTitle: "Allow Alarm Access", identifier: ProductionAccessibilityID.alarmPermissionAction) { Task { await model.requestAlarm() } }
                    }
                    if ProductionPresentationPolicy.shouldOfferSettings(calendar: model.calendarPermission, alarm: model.alarmPermission) {
                        Text("Access is needed to keep alarms aligned with your calendar. You can allow access in iOS Settings.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        OpenSettingsButton()
                    }
                }
                .frame(maxWidth: 560)
                .padding(28)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Welcome")
        }
    }
}

private struct PermissionCard: View {
    let title: String
    let state: PermissionState
    let actionTitle: String
    let identifier: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: state == .authorized ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(state == .authorized ? .green : .secondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    Text(statusText).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            if state == .notDetermined {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier(identifier)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    private var statusText: String {
        switch state {
        case .authorized: "Allowed"
        case .denied: "Allow access in iOS Settings"
        case .notDetermined: "Required to continue"
        case .restricted: "Restricted on this iPhone"
        case .unavailable: "Unavailable on this iPhone"
        }
    }
}

private struct OpenSettingsButton: View {
    var body: some View {
        Button("Open iOS Settings") { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
            .buttonStyle(.borderedProminent)
            .frame(minHeight: 44)
            .accessibilityIdentifier(ProductionAccessibilityID.openSettingsAction)
    }
}

struct MainTabsView: View {
    @ObservedObject var model: ProductionUXViewModel
    var body: some View {
        TabView {
            EventListView(title: "Today", events: model.todayEvents, emptyTitle: "No events today", emptyDescription: "Events from selected calendars will appear here.", model: model, listAccessibilityID: ProductionAccessibilityID.todayList)
                .tabItem { Label("Today", systemImage: "sun.max") }
            EventListView(title: "Upcoming", events: model.upcomingEvents, emptyTitle: "No upcoming events", emptyDescription: "Events in the next 14 days will appear here.", model: model, grouped: true, listAccessibilityID: ProductionAccessibilityID.upcomingList)
                .tabItem { Label("Upcoming", systemImage: "calendar") }
            SettingsView(model: model).tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

struct EventListView: View {
    let title: String
    let events: [CalendarEvent]
    let emptyTitle: String
    let emptyDescription: String
    @ObservedObject var model: ProductionUXViewModel
    var grouped = false
    let listAccessibilityID: String

    var body: some View {
        NavigationStack {
            Group {
                switch model.loadState {
                case .loading: ProgressView("Loading calendar events")
                case .failed: failure
                default:
                    if events.isEmpty { empty } else { eventList }
                }
            }
            .navigationTitle(title)
        }
    }

    private var failure: some View {
        VStack(spacing: 16) {
            ContentUnavailableView("Calendar unavailable", systemImage: "exclamationmark.triangle", description: Text("Calendar events could not be loaded. Try again in a moment."))
            Button("Try Again") { Task { await model.refresh() } }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 44)
                .accessibilityIdentifier(ProductionAccessibilityID.retryAction)
        }
        .padding()
    }

    private var empty: some View {
        ContentUnavailableView(emptyTitle, systemImage: "calendar", description: Text(emptyDescription))
    }

    private var eventList: some View {
        List {
            if grouped {
                ForEach(ProductionPresentationPolicy.grouped(events), id: \.0) { date, values in
                    Section(ProductionPresentationPolicy.groupDateText(date)) { rows(values) }
                }
            } else { rows(events) }
        }
        .accessibilityIdentifier(listAccessibilityID)
        .refreshable { await model.refresh() }
    }

    @ViewBuilder
    private func rows(_ values: [CalendarEvent]) -> some View {
        ForEach(values) { event in
            NavigationLink { EventDetailView(event: event, model: model) } label: { EventRow(event: event, model: model) }
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ProductionPresentationPolicy.startTimeText(for: event)).font(.subheadline).foregroundStyle(.secondary)
            Text(event.title).font(.headline).fixedSize(horizontal: false, vertical: true)
            Text(calendarName).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            Label(alarmText, systemImage: isOff ? "alarm.waves.left.and.right.slash" : "alarm")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var calendarName: String { model.calendars.first(where: { $0.id == event.calendarID })?.title ?? "Calendar" }
    private var isOff: Bool { model.overrides[event.id]?.state == .disabled }
    private var alarmText: String { ProductionPresentationPolicy.alarmText(event: event, override: model.overrides[event.id], settings: model.settings, now: Date()) }
    private var accessibilityLabel: String { ProductionPresentationPolicy.eventAccessibilityLabel(event: event, calendarTitle: calendarName, override: model.overrides[event.id], settings: model.settings, now: Date()) }
}

struct EventDetailView: View {
    let event: CalendarEvent
    @ObservedObject var model: ProductionUXViewModel
    @State private var enabled = true
    @State private var lead: AlarmLeadTime?

    var body: some View {
        Form {
            Section("Event") {
                adaptiveValue("Starts", event.startDate.formatted(date: .abbreviated, time: .shortened))
                adaptiveValue("Calendar", model.calendars.first(where: { $0.id == event.calendarID })?.title ?? "Calendar")
            }
            Section("Alarm") {
                Toggle("Alarm", isOn: $enabled)
                    .accessibilityIdentifier(ProductionAccessibilityID.eventAlarmToggle)
                    .accessibilityHint("Turns the alarm for this event on or off")
                if enabled {
                    Picker("Alarm Time", selection: $lead) {
                        Text("Default Alarm Time").tag(AlarmLeadTime?.none)
                        ForEach(AlarmLeadTime.allCases, id: \.self) { Text("\($0.rawValue) minutes before").tag(Optional($0)) }
                    }
                    .accessibilityIdentifier(ProductionAccessibilityID.eventLeadTimePicker)
                    Text(ProductionPresentationPolicy.detailTimingText(lead: lead, settings: model.settings))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No alarm will be created for this event.").font(.footnote).foregroundStyle(.secondary)
                }
            }
            Section("Privacy") {
                Text("Calendar Alarm reads this event to create an alarm. It never edits the calendar event.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let value = model.overrides[event.id] {
                switch value.state {
                case .disabled: enabled = false; lead = nil
                case .enabled(let custom): enabled = true; lead = custom
                }
            }
        }
        .onChange(of: enabled) { _, value in Task { await model.applyOverride(value ? .enabled(leadTimeOverride: lead) : .disabled, event: event) } }
        .onChange(of: lead) { _, value in if enabled { Task { await model.applyOverride(value == nil ? nil : .enabled(leadTimeOverride: value), event: event) } } }
    }

    private func adaptiveValue(_ label: String, _ value: String) -> some View {
        LabeledContent(label) { Text(value).multilineTextAlignment(.trailing).fixedSize(horizontal: false, vertical: true) }
    }
}

struct CalendarSelectionView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        Group {
            if model.calendars.isEmpty {
                ContentUnavailableView("No calendars available", systemImage: "calendar.badge.exclamationmark", description: Text("Calendars available on this iPhone will appear here."))
            } else {
                Form {
                    if model.enabledCalendarIDs.isEmpty {
                        Section { Text("No calendars selected. Turn on a calendar to include its events.").foregroundStyle(.secondary) }
                    }
                    ForEach(Dictionary(grouping: model.calendars, by: { $0.source.title.isEmpty ? "On This iPhone" : $0.source.title }).keys.sorted(), id: \.self) { source in
                        Section(source) {
                            ForEach(model.calendars.filter { ($0.source.title.isEmpty ? "On This iPhone" : $0.source.title) == source }) { calendar in
                                Toggle(isOn: Binding(get: { model.enabledCalendarIDs.contains(calendar.id) }, set: { value in Task { await model.setCalendar(value, id: calendar.id) } })) {
                                    Text(calendar.title.isEmpty ? "Untitled Calendar" : calendar.title).fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .accessibilityIdentifier(ProductionAccessibilityID.calendarList)
            }
        }
        .navigationTitle("Calendars")
    }
}

struct SettingsView: View {
    @ObservedObject var model: ProductionUXViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Default Alarm Time") {
                    Picker("Default Alarm Time", selection: Binding(get: { model.settings.defaultLeadTime }, set: { value in Task { await model.setDefault(value) } })) {
                        ForEach(AlarmLeadTime.allCases, id: \.self) { Text("\($0.rawValue) minutes before").tag($0) }
                    }
                    .accessibilityIdentifier(ProductionAccessibilityID.defaultLeadTimePicker)
                }
                Section("Calendars") { NavigationLink("Choose Calendars") { CalendarSelectionView(model: model) } }
                Section("Permissions") {
                    permissionStatus("Calendar Access", model.calendarPermission)
                    permissionStatus("Alarm Access", model.alarmPermission)
                    if ProductionPresentationPolicy.shouldOfferSettings(calendar: model.calendarPermission, alarm: model.alarmPermission) {
                        Text("Allow access in iOS Settings, then return to Calendar Alarm.").font(.footnote).foregroundStyle(.secondary)
                        OpenSettingsButton()
                    }
                }
                Section("Privacy") {
                    Text("Calendar Alarm reads calendar events to create alarms. It never edits calendar events. Your settings and app data stay on this device.")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func permissionStatus(_ title: String, _ state: PermissionState) -> some View {
        LabeledContent(title, value: state == .authorized ? "Allowed" : "Needs attention")
    }
}
