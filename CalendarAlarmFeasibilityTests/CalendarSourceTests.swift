import Foundation
import SwiftData
import XCTest
@testable import CalendarAlarmFeasibility

final class CalendarSourceTests: XCTestCase {
    func testCalendarSnapshotMapsToFrameworkIndependentDomain() {
        let value = CalendarDomainMapper.calendar(.init(id: "cal", title: "Work", sourceID: "src", sourceTitle: "iCloud", sourceType: "calDAV"))
        XCTAssertEqual(value, CalendarDescriptor(id: "cal", title: "Work", source: .init(id: "src", title: "iCloud", typeDescription: "calDAV")))
    }

    func testEventMappingPreservesAllDayAndOptionalIdentifier() {
        let start = Date(timeIntervalSinceReferenceDate: 100)
        let value = CalendarDomainMapper.event(.init(identifier: nil, calendarID: "cal", title: "Day", start: start, end: start.addingTimeInterval(60), isAllDay: true))
        XCTAssertNil(value.eventIdentifier)
        XCTAssertTrue(value.isAllDay)
        XCTAssertEqual(value.calendarID, "cal")
    }

    func testDeterministicEventSortingUsesIdentifierAsTieBreak() {
        let date = Date(timeIntervalSinceReferenceDate: 100)
        let a = event(id: "a", date: date)
        let b = event(id: "b", date: date)
        XCTAssertEqual(CalendarDomainMapper.sortedEvents([b, a]).map(\.id), ["a", "b"])
    }

    @MainActor
    func testInitialDiscoveryEnablesAllAvailableCalendars() async throws {
        let setup = try setup(calendars: [calendar("a"), calendar("b")])
        let result = try await setup.coordinator.discover()
        XCTAssertEqual(result.enabledIdentifiers, ["a", "b"])
    }

    @MainActor
    func testDisabledAndNewCalendarsRemainDisabled() async throws {
        let setup = try setup(calendars: [calendar("a"), calendar("b")])
        _ = try await setup.coordinator.discover()
        try setup.selections.setEnabled(false, calendarIdentifier: "b")
        setup.source.calendars = [calendar("a"), calendar("b"), calendar("new")]
        let result = try await setup.coordinator.discover()
        XCTAssertEqual(result.enabledIdentifiers, ["a"])
    }

    @MainActor
    func testMissingPersistedCalendarIsIgnoredAndRestoredIfItReturns() async throws {
        let setup = try setup(calendars: [calendar("a"), calendar("b")])
        _ = try await setup.coordinator.discover()
        setup.source.calendars = [calendar("a")]
        let missing = try await setup.coordinator.discover()
        XCTAssertEqual(missing.enabledIdentifiers, ["a"])
        setup.source.calendars = [calendar("a"), calendar("b")]
        let restored = try await setup.coordinator.discover()
        XCTAssertEqual(restored.enabledIdentifiers, ["a", "b"])
    }

    @MainActor
    func testFetchPassesOnlyEnabledCalendarIdentifiers() async throws {
        let setup = try setup(calendars: [calendar("a"), calendar("b")])
        _ = try await setup.coordinator.discover()
        try setup.selections.setEnabled(false, calendarIdentifier: "b")
        _ = try await setup.coordinator.fetch(in: .init(start: .now, end: .now.addingTimeInterval(60)))
        XCTAssertEqual(setup.source.lastEnabledIDs, ["a"])
    }

    @MainActor
    func testPermissionDeniedErrorPropagatesAndAbstractionIsMockable() async throws {
        let setup = try setup(calendars: [])
        setup.source.error = .permissionRequired
        do { _ = try await setup.coordinator.discover(); XCTFail("Expected denial") }
        catch { XCTAssertEqual(error as? CalendarSourceError, .permissionRequired) }
    }

    private func calendar(_ id: String) -> CalendarDescriptor { .init(id: id, title: id, source: .init(id: "source", title: "Source", typeDescription: "local")) }
    private func event(id: String, date: Date) -> CalendarEvent { .init(id: id, eventIdentifier: id, title: id, startDate: date, endDate: date, isAllDay: false, calendarID: "cal") }

    @MainActor
    private func setup(calendars: [CalendarDescriptor]) throws -> (coordinator: CalendarSourceCoordinator, selections: CalendarSelectionStore, source: FakeCalendarSource, container: ModelContainer) {
        let container = try PersistenceContainer.make(inMemory: true)
        let selections = CalendarSelectionStore(context: container.mainContext)
        let source = FakeCalendarSource(calendars: calendars)
        return (CalendarSourceCoordinator(source: source, selections: selections), selections, source, container)
    }
}

private final class FakeCalendarSource: CalendarSourceProviding, @unchecked Sendable {
    var calendars: [CalendarDescriptor]; var lastEnabledIDs: Set<String> = []; var error: CalendarSourceError?
    init(calendars: [CalendarDescriptor]) { self.calendars = calendars }
    func discoverCalendars() async throws -> [CalendarDescriptor] { if let error { throw error }; return calendars }
    func fetchEvents(in interval: CalendarInterval, enabledCalendarIDs: Set<String>) async throws -> [CalendarEvent] { if let error { throw error }; lastEnabledIDs = enabledCalendarIDs; return [] }
}
