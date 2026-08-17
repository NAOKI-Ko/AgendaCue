import SwiftUI

struct FeasibilityView: View {
    @StateObject private var viewModel: FeasibilityViewModel

    init(viewModel: FeasibilityViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Authorization") {
                    LabeledContent("AlarmKit", value: viewModel.alarmAuthorization.rawValue)
                    LabeledContent("EventKit", value: viewModel.calendarAuthorization.rawValue)
                }

                Section("AlarmKit") {
                    Button("Schedule Test Alarm +2 min") {
                        Task { await viewModel.scheduleTestAlarm() }
                    }
                    .disabled(viewModel.isWorking)

                    if let scheduled = viewModel.lastScheduled {
                        LabeledContent("Last scheduled", value: scheduled.date.formatted())
                        Text("UUID: \(scheduled.id.uuidString)")
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                }

                Section("EventKit — next 24 hours") {
                    Button("Request Access and Fetch Events") {
                        Task { await viewModel.fetchEvents() }
                    }
                    .disabled(viewModel.isWorking)

                    if viewModel.events.isEmpty {
                        Text("No fetched events. Calendar data is read-only.")
                    } else {
                        Picker("E2E event", selection: $viewModel.selectedEventID) {
                            Text("None").tag(FeasibilityCalendarEvent.ID?.none)
                            ForEach(viewModel.events) { event in
                                Text("\(event.title) — \(event.startDate.formatted())")
                                    .tag(Optional(event.id))
                            }
                        }

                        ForEach(viewModel.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title).font(.headline)
                                Text("start: \(event.startDate.formatted())")
                                Text("end: \(event.endDate.formatted())")
                                Text(verbatim: "all-day: \(event.isAllDay)")
                                Text("eventIdentifier: \(event.eventIdentifier)")
                                Text("calendar: \(event.calendarTitle) [\(event.calendarIdentifier)]")
                                Text("source: \(event.sourceTitle) (\(event.sourceType))")
                            }
                            .font(.caption)
                            .textSelection(.enabled)
                        }
                    }
                }

                Section("Event → AlarmKit feasibility") {
                    Text("Selected event start − fixed 5 minutes")
                    Button("Schedule Selected Event −5 min") {
                        Task { await viewModel.scheduleSelectedEventAlarm() }
                    }
                    .disabled(viewModel.isWorking || viewModel.selectedEventID == nil)
                }

                Section("Status") {
                    Text(viewModel.statusMessage)
                    if viewModel.alarmAuthorization == .denied {
                        Text("Alarm authorization is denied. Enable it in Settings before retrying.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("WU-00 Feasibility")
        }
    }
}
