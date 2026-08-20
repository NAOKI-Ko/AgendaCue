import EventKit
import Foundation

protocol CalendarSourceProviding: Sendable {
    func discoverCalendars() async throws -> [CalendarDescriptor]
    func fetchEvents(in interval: CalendarInterval, enabledCalendarIDs: Set<String>) async throws -> [CalendarEvent]
}

enum CalendarSourceError: Error, Equatable { case permissionRequired, invalidInterval }

struct CalendarSnapshot: Equatable, Sendable {
    let id: String; let title: String; let sourceID: String; let sourceTitle: String; let sourceType: String
}

struct EventSnapshot: Equatable, Sendable {
    let identifier: String?; let calendarID: String; let title: String; let start: Date; let end: Date; let isAllDay: Bool
}

enum CalendarDomainMapper {
    static func calendar(_ value: CalendarSnapshot) -> CalendarDescriptor {
        CalendarDescriptor(id: value.id, title: value.title,
            source: CalendarSource(id: value.sourceID, title: value.sourceTitle, typeDescription: value.sourceType))
    }

    static func event(_ value: EventSnapshot) -> CalendarEvent {
        let fallback = "missing|\(value.calendarID)|\(value.start.timeIntervalSinceReferenceDate)|\(value.title)"
        return CalendarEvent(id: value.identifier ?? fallback, eventIdentifier: value.identifier, title: value.title,
            startDate: value.start, endDate: value.end, isAllDay: value.isAllDay, calendarID: value.calendarID)
    }

    static func sortedEvents(_ events: [CalendarEvent]) -> [CalendarEvent] {
        events.sorted { ($0.startDate, $0.id) < ($1.startDate, $1.id) }
    }
}

struct CalendarDiscovery: Equatable, Sendable {
    let calendars: [CalendarDescriptor]
    let enabledIdentifiers: Set<String>
}

@MainActor
final class CalendarSourceCoordinator {
    private let source: any CalendarSourceProviding
    private let selections: CalendarSelectionStore

    init(source: any CalendarSourceProviding, selections: CalendarSelectionStore) {
        self.source = source; self.selections = selections
    }

    func discover() async throws -> CalendarDiscovery {
        let calendars = try await source.discoverCalendars()
        let available = Set(calendars.map(\.id))
        return CalendarDiscovery(calendars: calendars, enabledIdentifiers: try selections.enabledIdentifiers(for: available))
    }

    func fetch(in interval: CalendarInterval) async throws -> [CalendarEvent] {
        let discovery = try await discover()
        return try await source.fetchEvents(in: interval, enabledCalendarIDs: discovery.enabledIdentifiers)
    }
}

actor EventKitCalendarSource: CalendarSourceProviding {
    private let store: EKEventStore
    init(store: EKEventStore = EKEventStore()) { self.store = store }

    func discoverCalendars() throws -> [CalendarDescriptor] {
        try requireAccess()
        return store.calendars(for: .event).map { calendar in
            CalendarDomainMapper.calendar(CalendarSnapshot(id: calendar.calendarIdentifier, title: calendar.title,
                sourceID: calendar.source.sourceIdentifier, sourceTitle: calendar.source.title,
                sourceType: String(describing: calendar.source.sourceType)))
        }.sorted { ($0.title, $0.id) < ($1.title, $1.id) }
    }

    func fetchEvents(in interval: CalendarInterval, enabledCalendarIDs: Set<String>) throws -> [CalendarEvent] {
        try requireAccess()
        guard interval.start < interval.end else { throw CalendarSourceError.invalidInterval }
        let calendars = store.calendars(for: .event).filter { enabledCalendarIDs.contains($0.calendarIdentifier) }
        guard !calendars.isEmpty else { return [] }
        let predicate = store.predicateForEvents(withStart: interval.start, end: interval.end, calendars: calendars)
        return CalendarDomainMapper.sortedEvents(store.events(matching: predicate).map { event in
            CalendarDomainMapper.event(EventSnapshot(identifier: event.eventIdentifier,
                calendarID: event.calendar.calendarIdentifier, title: event.title ?? "予定",
                start: event.startDate, end: event.endDate, isAllDay: event.isAllDay))
        })
    }

    private func requireAccess() throws {
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else { throw CalendarSourceError.permissionRequired }
    }
}
