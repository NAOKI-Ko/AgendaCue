import Foundation

@MainActor
final class FeasibilityViewModel: ObservableObject {
    @Published private(set) var events: [FeasibilityCalendarEvent] = []
    @Published var selectedEventID: FeasibilityCalendarEvent.ID?
    @Published private(set) var calendarAuthorization = CalendarAuthorizationStatus.notDetermined
    @Published private(set) var alarmAuthorization = AlarmAuthorizationStatus.notDetermined
    @Published private(set) var lastScheduled: ScheduledAlarmResult?
    @Published private(set) var statusMessage = "Ready for WU-00 feasibility checks."
    @Published private(set) var isWorking = false

    private let calendarProvider: any CalendarEventProviding
    private let alarmScheduler: any AlarmScheduling
    private let now: () -> Date

    init(
        calendarProvider: any CalendarEventProviding,
        alarmScheduler: any AlarmScheduling,
        now: @escaping () -> Date = Date.init
    ) {
        self.calendarProvider = calendarProvider
        self.alarmScheduler = alarmScheduler
        self.now = now
        calendarAuthorization = calendarProvider.authorizationStatus
        alarmAuthorization = alarmScheduler.authorizationStatus
    }

    var selectedEvent: FeasibilityCalendarEvent? {
        events.first { $0.id == selectedEventID }
    }

    func fetchEvents() async {
        await perform {
            events = try await calendarProvider.requestAccessAndFetchEvents(now: now())
            calendarAuthorization = calendarProvider.authorizationStatus
            if selectedEvent == nil {
                selectedEventID = events.first(where: { !$0.isAllDay })?.id
            }
            statusMessage = "Fetched \(events.count) event(s) from the next 24 hours."
        }
    }

    func scheduleTestAlarm() async {
        await perform {
            let date = now().addingTimeInterval(2 * 60)
            lastScheduled = try await alarmScheduler.scheduleOneShot(
                at: date,
                title: "WU-00 +2 minute test"
            )
            alarmAuthorization = alarmScheduler.authorizationStatus
            statusMessage = "Scheduled unique test alarm for \(date.formatted())."
        }
    }

    func scheduleSelectedEventAlarm() async {
        guard let event = selectedEvent else {
            statusMessage = "Select a future non-all-day event first."
            return
        }

        let currentNow = now()
        switch FeasibilityAlarmCandidate.evaluate(
            eventStart: event.startDate,
            isAllDay: event.isAllDay,
            leadTime: 5 * 60,
            now: currentNow
        ) {
        case .ineligible(.allDay):
            statusMessage = "All-day events are ineligible for WU-00 E2E."
        case .ineligible(.alarmDateNotInFuture):
            statusMessage = "The event's start - 5 minutes is not in the future."
        case .eligible(let alarmDate):
            await perform {
                lastScheduled = try await alarmScheduler.scheduleOneShot(
                    at: alarmDate,
                    title: event.title
                )
                alarmAuthorization = alarmScheduler.authorizationStatus
                statusMessage = "Scheduled \(event.title) for \(alarmDate.formatted())."
            }
        }
    }

    private func perform(_ operation: () async throws -> Void) async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await operation()
        } catch {
            calendarAuthorization = calendarProvider.authorizationStatus
            alarmAuthorization = alarmScheduler.authorizationStatus
            statusMessage = "Error: \(error.localizedDescription)"
            debugPrint("WU-00 error", error)
        }
    }
}
