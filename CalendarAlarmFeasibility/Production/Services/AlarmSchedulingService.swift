import AlarmKit
import Foundation
import SwiftUI

protocol AlarmSystemScheduling: Sendable {
    func authorizationState() async -> PermissionState
    func scheduledAlarmIDs() async throws -> Set<UUID>
    func schedule(id: UUID, at date: Date, title: String) async throws
    func cancel(id: UUID) async throws
}

enum AlarmSystemError: Error, Equatable { case capacityReached }

enum AlarmScheduleOutcome: Equatable { case scheduled(UUID), alreadyScheduled(UUID), replaced(UUID) }
enum AlarmCancelOutcome: Equatable { case cancelled, notScheduled }
enum ProductionAlarmSchedulingError: Error, Equatable { case authorizationRequired(PermissionState), replacementRecoveryRequired }

actor AlarmSchedulingCoordinator {
    private let system: any AlarmSystemScheduling
    private let store: any ScheduledAlarmStoring
    private var activeIdentities: Set<String> = []

    init(system: any AlarmSystemScheduling, store: any ScheduledAlarmStoring) { self.system = system; self.store = store }

    func authorizationState() async -> PermissionState { await system.authorizationState() }
    func scheduledAlarmIDs() async throws -> Set<UUID> { try await system.scheduledAlarmIDs() }

    func schedule(_ candidate: AlarmCandidate) async throws -> AlarmScheduleOutcome {
        await acquire(candidate.id)
        defer { activeIdentities.remove(candidate.id) }
        return try await scheduleLocked(candidate)
    }

    private func scheduleLocked(_ candidate: AlarmCandidate) async throws -> AlarmScheduleOutcome {
        let authorization = await system.authorizationState()
        guard authorization == .authorized else { throw ProductionAlarmSchedulingError.authorizationRequired(authorization) }
        if let existing = try await store.mapping(for: candidate.id) {
            guard existing.alarmDate != candidate.alarmDate else { return .alreadyScheduled(existing.alarmIdentifier) }
            try await system.cancel(id: existing.alarmIdentifier)
            do { try await system.schedule(id: existing.alarmIdentifier, at: candidate.alarmDate, title: presentationTitle(candidate.eventTitle)) }
            catch { throw ProductionAlarmSchedulingError.replacementRecoveryRequired }
            try await store.save(.init(candidateIdentity: candidate.id, alarmIdentifier: existing.alarmIdentifier, alarmDate: candidate.alarmDate))
            return .replaced(existing.alarmIdentifier)
        }
        let id = UUID()
        try await system.schedule(id: id, at: candidate.alarmDate, title: presentationTitle(candidate.eventTitle))
        try await store.save(.init(candidateIdentity: candidate.id, alarmIdentifier: id, alarmDate: candidate.alarmDate))
        return .scheduled(id)
    }

    func cancel(candidateIdentity: String) async throws -> AlarmCancelOutcome {
        await acquire(candidateIdentity)
        defer { activeIdentities.remove(candidateIdentity) }
        guard let existing = try await store.mapping(for: candidateIdentity) else { return .notScheduled }
        try await system.cancel(id: existing.alarmIdentifier)
        try await store.remove(identity: candidateIdentity)
        return .cancelled
    }

    func recover(_ candidate: AlarmCandidate, mapping: ScheduledAlarmMapping) async throws {
        await acquire(candidate.id)
        defer { activeIdentities.remove(candidate.id) }
        let authorization = await system.authorizationState()
        guard authorization == .authorized else { throw ProductionAlarmSchedulingError.authorizationRequired(authorization) }
        try await system.schedule(id: mapping.alarmIdentifier, at: candidate.alarmDate, title: presentationTitle(candidate.eventTitle))
        try await store.save(.init(candidateIdentity: candidate.id, alarmIdentifier: mapping.alarmIdentifier, alarmDate: candidate.alarmDate))
    }

    func cancelOrphan(id: UUID) async throws { try await system.cancel(id: id) }

    private func acquire(_ identity: String) async {
        while activeIdentities.contains(identity) { await Task.yield() }
        activeIdentities.insert(identity)
    }

    private func presentationTitle(_ title: String) -> String { title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "予定" : title }
}

private struct ProductionAlarmMetadata: AlarmMetadata { let candidateIdentity: String }

actor AlarmKitSystemScheduler: AlarmSystemScheduling {
    private let manager = AlarmManager.shared
    func authorizationState() -> PermissionState { AlarmPermissionMapping.map(manager.authorizationState) }
    func scheduledAlarmIDs() throws -> Set<UUID> { Set(try manager.alarms.map(\.id)) }
    func schedule(id: UUID, at date: Date, title: String) async throws {
        let localized: LocalizedStringResource = "\(title)"
        let alert = AlarmPresentation.Alert(title: localized, stopButton: AlarmButton(text: "Stop", textColor: .white, systemImageName: "stop.fill"))
        let attributes = AlarmAttributes(presentation: AlarmPresentation(alert: alert), metadata: ProductionAlarmMetadata(candidateIdentity: id.uuidString), tintColor: .orange)
        let configuration = AlarmManager.AlarmConfiguration.alarm(schedule: .fixed(date), attributes: attributes)
        do { _ = try await manager.schedule(id: id, configuration: configuration) }
        catch AlarmManager.AlarmError.maximumLimitReached { throw AlarmSystemError.capacityReached }
    }
    func cancel(id: UUID) throws { try manager.cancel(id: id) }
}
