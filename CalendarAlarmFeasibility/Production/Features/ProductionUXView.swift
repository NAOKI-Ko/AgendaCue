import EventKit
import SwiftUI
import UIKit

@MainActor
final class ProductionUXViewModel: ObservableObject {
    @Published var calendarPermission: PermissionState; @Published var alarmPermission: PermissionState
    @Published var events: [CalendarEvent] = []; @Published var calendars: [CalendarDescriptor] = []
    @Published var enabledCalendarIDs: Set<String> = []; @Published var overrides: [String: EventOverride] = [:]
    @Published var settings = AppSettings(); @Published var loadState: UserFacingLoadState = .loading
    @Published var sampleScenario: String?
    let calendarPermissionProvider: any CalendarPermissionProviding; let alarmPermissionProvider: any AlarmPermissionProviding
    private let source: CalendarSourceCoordinator; private let selections: CalendarSelectionStore
    private let overrideStore: any EventOverrideStoring; let overrideService: EventOverrideService
    private let settingsService: AppSettingsService; private let reconciliation: CalendarReconciliationCoordinator

    init(dependencies: AppDependencies) {
        calendarPermissionProvider = dependencies.calendarPermission; alarmPermissionProvider = dependencies.alarmPermission
        calendarPermission = dependencies.calendarPermission.state; alarmPermission = dependencies.alarmPermission.state
        source = dependencies.calendarSource; selections = dependencies.calendarSelections; overrideStore = dependencies.overrideStore
        overrideService = dependencies.eventOverrides; settingsService = dependencies.settingsService; reconciliation = dependencies.reconciliation
        applySampleIfNeeded()
    }

    var route: ProductionRoute { ProductionPresentationPolicy.route(calendar: calendarPermission, alarm: alarmPermission) }
    var todayEvents: [CalendarEvent] { ProductionPresentationPolicy.sorted(events.filter { Calendar.current.isDateInToday($0.startDate) }) }
    var upcomingEvents: [CalendarEvent] { ProductionPresentationPolicy.sorted(events.filter { $0.startDate >= Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! }) }

    func refresh() async {
        guard ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-UIScenario=") }) == nil else { return }
        calendarPermission = calendarPermissionProvider.state; alarmPermission = alarmPermissionProvider.state
        guard calendarPermission == .authorized else { loadState = .permissionBlocked; return }
        loadState = .loading
        do {
            let discovery = try await source.discover(); calendars = discovery.calendars; enabledCalendarIDs = discovery.enabledIdentifiers
            let now = Date(); events = try await source.fetch(in: .init(start: Calendar.current.startOfDay(for: now), end: now.addingTimeInterval(14 * 86400)))
            overrides = try await overrideStore.allOverrides(); settings = try await settingsService.load()
            loadState = events.isEmpty ? .empty : .content
        } catch { loadState = .failed }
    }

    func requestCalendar() async { do { calendarPermission = try await calendarPermissionProvider.requestAccess() } catch { calendarPermission = .denied }; await refresh() }
    func requestAlarm() async { do { alarmPermission = try await alarmPermissionProvider.requestAccess() } catch { alarmPermission = .denied }; await refresh() }
    func setCalendar(_ enabled: Bool, id: String) async { do { try selections.setEnabled(enabled, calendarIdentifier: id); if enabled { enabledCalendarIDs.insert(id) } else { enabledCalendarIDs.remove(id) }; await reconcile() } catch { loadState = .failed } }
    func setDefault(_ lead: AlarmLeadTime) async { do { try await settingsService.setDefaultLeadTime(lead); settings.defaultLeadTime = lead; await refresh() } catch { loadState = .failed } }
    func applyOverride(_ state: EventAlarmOverride?, event: CalendarEvent) async { do { if let state { try await overrideService.set(state, for: event.id) } else { try await overrideService.reset(eventIdentity: event.id) }; overrides = try await overrideStore.allOverrides(); await refresh() } catch { loadState = .failed } }
    private func reconcile() async { let now = Date(); _ = await reconciliation.trigger(now: now, window: .productionDefault(now: now)) }

    private func applySampleIfNeeded() {
        guard let raw = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-UIScenario=") }) else { return }
        let scenario = String(raw.dropFirst("-UIScenario=".count)); sampleScenario = scenario; let now = Date(); let cal = CalendarDescriptor(id: "sample", title: "Personal", source: .init(id: "icloud", title: "iCloud", typeDescription: "CalDAV"))
        calendars = [cal, .init(id: "work", title: "Work", source: .init(id: "google", title: "Google", typeDescription: "CalDAV"))]; enabledCalendarIDs = ["sample", "work"]
        calendarPermission = scenario == "onboarding" ? .notDetermined : scenario == "denied" ? .denied : .authorized; alarmPermission = scenario == "alarm-denied" ? .denied : .authorized
        let samples = [CalendarEvent(id: "standup", eventIdentifier: "standup", title: "Daily stand-up", startDate: now.addingTimeInterval(3600), endDate: now.addingTimeInterval(5400), isAllDay: false, calendarID: "work"), CalendarEvent(id: "dentist", eventIdentifier: "dentist", title: "Dentist appointment", startDate: now.addingTimeInterval(14400), endDate: now.addingTimeInterval(16200), isAllDay: false, calendarID: "sample"), CalendarEvent(id: "tomorrow", eventIdentifier: "tomorrow", title: "Project review", startDate: now.addingTimeInterval(90000), endDate: now.addingTimeInterval(93600), isAllDay: false, calendarID: "work")]
        events = scenario == "empty" ? [] : samples; if scenario == "detail-off" { overrides["standup"] = .init(eventIdentity: "standup", state: .disabled) }; if scenario == "detail-custom" { overrides["standup"] = .init(eventIdentity: "standup", state: .enabled(leadTimeOverride: .fifteenMinutes)) }; loadState = events.isEmpty ? .empty : .content
    }
}

struct ProductionRootView: View {
    @StateObject private var model: ProductionUXViewModel
    init(dependencies: AppDependencies) { _model = StateObject(wrappedValue: ProductionUXViewModel(dependencies: dependencies)) }
    var body: some View { Group { if model.route == .onboarding { OnboardingView(model: model) } else if let scenario = model.sampleScenario { sample(scenario) } else { MainTabsView(model: model) } }.task { await model.refresh() } }
    @ViewBuilder private func sample(_ scenario: String) -> some View { switch scenario { case "upcoming": EventListView(title: "Upcoming", events: model.upcomingEvents, empty: "No upcoming events", model: model, grouped: true); case "settings": SettingsView(model: model); case "calendars": NavigationStack { CalendarSelectionView(model: model) }; case "detail-default", "detail-custom", "detail-off": NavigationStack { if let event = model.events.first { EventDetailView(event: event, model: model) } }; default: EventListView(title: "Today", events: model.todayEvents, empty: "No events today", model: model) } }
}

struct OnboardingView: View {
    @ObservedObject var model: ProductionUXViewModel
    var body: some View { NavigationStack { VStack(spacing: 24) { Spacer(); Image(systemName: "calendar.badge.clock").font(.system(size: 64)).foregroundStyle(.orange); Text("Calendar Alarm").font(.largeTitle.bold()); Text("Real alarms for events in calendars available on this iPhone. Calendar Alarm reads events but never edits them.").multilineTextAlignment(.center).foregroundStyle(.secondary); VStack(spacing: 12) { permissionRow("Calendar Access", state: model.calendarPermission) { Task { await model.requestCalendar() } }; permissionRow("Alarm Access", state: model.alarmPermission) { Task { await model.requestAlarm() } } }; if model.calendarPermission == .denied || model.alarmPermission == .denied { Button("Open iOS Settings") { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }; Text("Access is required to keep alarms aligned with your calendar.").font(.footnote).foregroundStyle(.secondary) }; Spacer() }.padding(28).navigationTitle("Welcome") } }
    @ViewBuilder private func permissionRow(_ title: String, state: PermissionState, action: @escaping () -> Void) -> some View { HStack { Image(systemName: state == .authorized ? "checkmark.circle.fill" : "circle").foregroundStyle(state == .authorized ? .green : .secondary); VStack(alignment: .leading) { Text(title).font(.headline); Text(state == .authorized ? "Allowed" : state == .denied ? "Open Settings to allow access" : "Required to continue").font(.caption).foregroundStyle(.secondary) }; Spacer(); if state == .notDetermined { Button("Allow", action: action).buttonStyle(.borderedProminent) } }.padding().background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16)) }
}

struct MainTabsView: View { @ObservedObject var model: ProductionUXViewModel; var body: some View { TabView { EventListView(title: "Today", events: model.todayEvents, empty: "No events today", model: model).tabItem { Label("Today", systemImage: "sun.max") }; EventListView(title: "Upcoming", events: model.upcomingEvents, empty: "No upcoming events", model: model, grouped: true).tabItem { Label("Upcoming", systemImage: "calendar") }; SettingsView(model: model).tabItem { Label("Settings", systemImage: "gearshape") } } } }

struct EventListView: View { let title: String; let events: [CalendarEvent]; let empty: String; @ObservedObject var model: ProductionUXViewModel; var grouped = false; var body: some View { NavigationStack { Group { if model.loadState == .failed { ContentUnavailableView("Calendar unavailable", systemImage: "exclamationmark.triangle", description: Text("Try again in a moment.")); Button("Try Again") { Task { await model.refresh() } } } else if events.isEmpty { ContentUnavailableView(empty, systemImage: "calendar") } else { List { ForEach(events) { event in NavigationLink { EventDetailView(event: event, model: model) } label: { EventRow(event: event, model: model) } } } } }.navigationTitle(title).refreshable { await model.refresh() } } } }

struct EventRow: View { let event: CalendarEvent; @ObservedObject var model: ProductionUXViewModel; var body: some View { VStack(alignment: .leading, spacing: 5) { Text(event.startDate.formatted(date: .omitted, time: .shortened)).font(.caption).foregroundStyle(.secondary); Text(event.title).font(.headline); Text(calendarName).font(.subheadline).foregroundStyle(.secondary); Label(ProductionPresentationPolicy.alarmText(event: event, override: model.overrides[event.id], settings: model.settings, now: Date()), systemImage: model.overrides[event.id]?.state == .disabled ? "alarm.waves.left.and.right.slash" : "alarm").font(.subheadline) }.padding(.vertical, 4) } ; private var calendarName: String { model.calendars.first(where: { $0.id == event.calendarID })?.title ?? "Calendar" } }

struct EventDetailView: View { let event: CalendarEvent; @ObservedObject var model: ProductionUXViewModel; @State private var enabled = true; @State private var lead: AlarmLeadTime?; var body: some View { Form { Section("Event") { LabeledContent("Starts", value: event.startDate.formatted(date: .abbreviated, time: .shortened)); LabeledContent("Calendar", value: model.calendars.first(where: { $0.id == event.calendarID })?.title ?? "Calendar") }; Section("Alarm") { Toggle("Alarm", isOn: $enabled); if enabled { Picker("Timing", selection: $lead) { Text("Default").tag(AlarmLeadTime?.none); ForEach(AlarmLeadTime.allCases, id: \.self) { Text("\($0.rawValue) minutes before").tag(Optional($0)) } } } }; Section { Text("Calendar Alarm never edits this calendar event.").font(.footnote).foregroundStyle(.secondary) } }.navigationTitle(event.title).navigationBarTitleDisplayMode(.inline).onAppear { if let value = model.overrides[event.id] { switch value.state { case .disabled: enabled = false; lead = nil; case .enabled(let custom): enabled = true; lead = custom } } }.onChange(of: enabled) { _, value in Task { await model.applyOverride(value ? .enabled(leadTimeOverride: lead) : .disabled, event: event) } }.onChange(of: lead) { _, value in if enabled { Task { await model.applyOverride(value == nil ? nil : .enabled(leadTimeOverride: value), event: event) } } } } }

struct CalendarSelectionView: View { @ObservedObject var model: ProductionUXViewModel; var body: some View { Form { ForEach(Dictionary(grouping: model.calendars, by: { $0.source.title }).keys.sorted(), id: \.self) { source in Section { ForEach(model.calendars.filter { $0.source.title == source }) { calendar in Toggle(calendar.title, isOn: Binding(get: { model.enabledCalendarIDs.contains(calendar.id) }, set: { value in Task { await model.setCalendar(value, id: calendar.id) } })) } } header: { Text(source) } } }.navigationTitle("Calendars") } }

struct SettingsView: View { @ObservedObject var model: ProductionUXViewModel; var body: some View { NavigationStack { Form { Section("Default Alarm Time") { Picker("Default timing", selection: Binding(get: { model.settings.defaultLeadTime }, set: { value in Task { await model.setDefault(value) } })) { ForEach(AlarmLeadTime.allCases, id: \.self) { Text("\($0.rawValue) minutes before").tag($0) } } }; Section { NavigationLink("Calendars") { CalendarSelectionView(model: model) } }; Section("Permissions") { status("Calendar access", model.calendarPermission); status("Alarm access", model.alarmPermission); if model.calendarPermission == .denied || model.alarmPermission == .denied { Button("Open iOS Settings") { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) } } }; Section("Privacy") { Text("Calendar Alarm reads events but never modifies them. There is no account or backend; app data stays on this device.") } }.navigationTitle("Settings") } }; private func status(_ title: String, _ state: PermissionState) -> some View { LabeledContent(title, value: state == .authorized ? "Allowed" : "Needs attention") } }
