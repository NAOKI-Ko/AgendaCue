import Foundation
import SwiftData

actor AppSettingsService {
    private let container: ModelContainer
    private let reconciliation: any ReconciliationTriggering
    init(container: ModelContainer, reconciliation: any ReconciliationTriggering) { self.container = container; self.reconciliation = reconciliation }

    func load() throws -> AppSettings {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<AppSettingsRecord>()).first?.settings ?? AppSettings()
    }

    func setDefaultLeadTime(_ lead: AlarmLeadTime, now: Date = Date()) async throws {
        let context = ModelContext(container)
        let record = try context.fetch(FetchDescriptor<AppSettingsRecord>()).first ?? AppSettingsRecord()
        if record.modelContext == nil { context.insert(record) }
        record.settings = .init(defaultLeadTime: lead); try context.save()
        _ = await reconciliation.trigger(now: now, window: .productionDefault(now: now))
    }
}
