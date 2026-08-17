import Foundation
import SwiftData

@MainActor
final class CalendarSelectionStore {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func enabledIdentifiers(for available: Set<String>) throws -> Set<String> {
        let state = try stateRecord()
        if !state.isEstablished {
            available.forEach { context.insert(SelectedCalendarRecord(calendarIdentifier: $0)) }
            state.isEstablished = true
            try context.save()
        }
        let selected = try context.fetch(FetchDescriptor<SelectedCalendarRecord>())
        return Set(selected.map(\.calendarIdentifier)).intersection(available)
    }

    func setEnabled(_ enabled: Bool, calendarIdentifier: String) throws {
        let descriptor = FetchDescriptor<SelectedCalendarRecord>(
            predicate: #Predicate { $0.calendarIdentifier == calendarIdentifier }
        )
        let existing = try context.fetch(descriptor).first
        if enabled, existing == nil { context.insert(SelectedCalendarRecord(calendarIdentifier: calendarIdentifier)) }
        if !enabled, let existing { context.delete(existing) }
        let state = try stateRecord()
        state.isEstablished = true
        try context.save()
    }

    private func stateRecord() throws -> CalendarSelectionStateRecord {
        if let existing = try context.fetch(FetchDescriptor<CalendarSelectionStateRecord>()).first { return existing }
        let state = CalendarSelectionStateRecord()
        context.insert(state)
        return state
    }
}
