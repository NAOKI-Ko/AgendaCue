import Foundation
import SwiftData

struct ScheduledAlarmMapping: Equatable, Sendable {
    let candidateIdentity: String
    let alarmIdentifier: UUID
    let alarmDate: Date
}

protocol ScheduledAlarmStoring: Sendable {
    func mapping(for identity: String) async throws -> ScheduledAlarmMapping?
    func allMappings() async throws -> [ScheduledAlarmMapping]
    func save(_ mapping: ScheduledAlarmMapping) async throws
    func remove(identity: String) async throws
}

actor SwiftDataScheduledAlarmStore: ScheduledAlarmStoring {
    private let container: ModelContainer
    init(container: ModelContainer) { self.container = container }

    func mapping(for identity: String) throws -> ScheduledAlarmMapping? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ScheduledAlarmRecord>(predicate: #Predicate { $0.candidateIdentity == identity })
        return try context.fetch(descriptor).first.map { .init(candidateIdentity: $0.candidateIdentity, alarmIdentifier: $0.alarmIdentifier, alarmDate: $0.alarmDate) }
    }

    func allMappings() throws -> [ScheduledAlarmMapping] {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<ScheduledAlarmRecord>()).map {
            .init(candidateIdentity: $0.candidateIdentity, alarmIdentifier: $0.alarmIdentifier, alarmDate: $0.alarmDate)
        }.sorted { ($0.alarmDate, $0.candidateIdentity) < ($1.alarmDate, $1.candidateIdentity) }
    }

    func save(_ mapping: ScheduledAlarmMapping) throws {
        let context = ModelContext(container)
        let identity = mapping.candidateIdentity
        let descriptor = FetchDescriptor<ScheduledAlarmRecord>(predicate: #Predicate { $0.candidateIdentity == identity })
        if let record = try context.fetch(descriptor).first {
            record.alarmIdentifier = mapping.alarmIdentifier; record.alarmDate = mapping.alarmDate
        } else {
            context.insert(ScheduledAlarmRecord(candidateIdentity: identity, alarmIdentifier: mapping.alarmIdentifier, alarmDate: mapping.alarmDate))
        }
        try context.save()
    }

    func remove(identity: String) throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ScheduledAlarmRecord>(predicate: #Predicate { $0.candidateIdentity == identity })
        if let record = try context.fetch(descriptor).first { context.delete(record); try context.save() }
    }
}
