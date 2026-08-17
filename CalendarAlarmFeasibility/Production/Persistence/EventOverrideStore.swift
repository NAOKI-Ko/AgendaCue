import Foundation
import SwiftData

protocol EventOverrideStoring: Sendable {
    func override(for eventIdentity: String) async throws -> EventOverride?
    func allOverrides() async throws -> [String: EventOverride]
    func upsert(_ value: EventOverride) async throws
    func remove(eventIdentity: String) async throws
}

actor SwiftDataEventOverrideStore: EventOverrideStoring {
    private let container: ModelContainer
    init(container: ModelContainer) { self.container = container }

    func override(for eventIdentity: String) throws -> EventOverride? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<EventOverrideRecord>(predicate: #Predicate { $0.eventIdentity == eventIdentity })
        return try context.fetch(descriptor).first.flatMap(Self.map)
    }

    func allOverrides() throws -> [String: EventOverride] {
        let context = ModelContext(container)
        return Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<EventOverrideRecord>()).compactMap(Self.map).map { ($0.eventIdentity, $0) })
    }

    func upsert(_ value: EventOverride) throws {
        let context = ModelContext(container); let identity = value.eventIdentity
        let descriptor = FetchDescriptor<EventOverrideRecord>(predicate: #Predicate { $0.eventIdentity == identity })
        let record = try context.fetch(descriptor).first ?? EventOverrideRecord(eventIdentity: identity, state: value.state)
        if record.modelContext == nil { context.insert(record) }
        switch value.state {
        case .disabled: record.isEnabled = false; record.leadTimeMinutes = nil
        case .enabled(let lead): record.isEnabled = true; record.leadTimeMinutes = lead?.rawValue
        }
        try context.save()
    }

    func remove(eventIdentity: String) throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<EventOverrideRecord>(predicate: #Predicate { $0.eventIdentity == eventIdentity })
        if let record = try context.fetch(descriptor).first { context.delete(record); try context.save() }
    }

    private static func map(_ record: EventOverrideRecord) -> EventOverride? {
        if !record.isEnabled { return .init(eventIdentity: record.eventIdentity, state: .disabled) }
        if let minutes = record.leadTimeMinutes, let lead = AlarmLeadTime(rawValue: minutes) {
            return .init(eventIdentity: record.eventIdentity, state: .enabled(leadTimeOverride: lead))
        }
        guard record.leadTimeMinutes == nil else { return nil }
        return .init(eventIdentity: record.eventIdentity, state: .enabled(leadTimeOverride: nil))
    }
}
