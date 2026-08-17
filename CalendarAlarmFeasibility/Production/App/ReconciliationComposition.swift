import Foundation
import SwiftData

@MainActor
final class LiveReconciliationInput: ReconciliationInputProviding, @unchecked Sendable {
    private let permission: any CalendarPermissionProviding
    private let calendarSource: CalendarSourceCoordinator
    private let context: ModelContext

    init(permission: any CalendarPermissionProviding, calendarSource: CalendarSourceCoordinator, context: ModelContext) {
        self.permission = permission; self.calendarSource = calendarSource; self.context = context
    }

    func calendarPermissionState() async -> PermissionState { permission.state }

    func snapshot(window: ReconciliationWindow) async throws -> ReconciliationSnapshot {
        let events = try await calendarSource.fetch(in: .init(start: window.startDate, end: window.endDate))
        let record = try context.fetch(FetchDescriptor<AppSettingsRecord>()).first
        return .init(events: events, defaultLeadTime: record?.settings.defaultLeadTime ?? .default)
    }
}
