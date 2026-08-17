import EventKit
import Foundation

@MainActor
final class EventKitCalendarEventProvider: CalendarEventProviding {
    private let eventStore: EKEventStore

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    var authorizationStatus: CalendarAuthorizationStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .fullAccess:
            return .authorized
        case .writeOnly:
            return .denied
        @unknown default:
            return .unknown
        }
    }

    func requestAccessAndFetchEvents(now: Date) async throws -> [FeasibilityCalendarEvent] {
        if EKEventStore.authorizationStatus(for: .event) == .notDetermined {
            _ = try await eventStore.requestFullAccessToEvents()
        }

        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else {
            return []
        }

        let end = now.addingTimeInterval(24 * 60 * 60)
        let predicate = eventStore.predicateForEvents(withStart: now, end: end, calendars: nil)
        return eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
            .map(Self.mapEvent)
    }

    private static func mapEvent(_ event: EKEvent) -> FeasibilityCalendarEvent {
        let eventIdentifier = event.eventIdentifier ?? "missing-event-identifier"
        return FeasibilityCalendarEvent(
            id: "\(eventIdentifier)|\(event.startDate.timeIntervalSinceReferenceDate)",
            title: event.title ?? "(Untitled)",
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            eventIdentifier: eventIdentifier,
            calendarIdentifier: event.calendar.calendarIdentifier,
            calendarTitle: event.calendar.title,
            sourceTitle: event.calendar.source.title,
            sourceType: String(describing: event.calendar.source.sourceType)
        )
    }
}
