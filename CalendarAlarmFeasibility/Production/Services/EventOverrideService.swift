import Foundation

protocol ReconciliationTriggering: Sendable {
    func trigger(now: Date, window: ReconciliationWindow) async -> ReconciliationReport?
}

extension CalendarReconciliationCoordinator: ReconciliationTriggering {}

actor EventOverrideService {
    private let store: any EventOverrideStoring
    private let reconciliation: any ReconciliationTriggering
    private let now: @Sendable () -> Date

    init(store: any EventOverrideStoring, reconciliation: any ReconciliationTriggering, now: @escaping @Sendable () -> Date = Date.init) {
        self.store = store; self.reconciliation = reconciliation; self.now = now
    }

    func set(_ state: EventAlarmOverride, for eventIdentity: String) async throws {
        try await store.upsert(.init(eventIdentity: eventIdentity, state: state))
        await reconcile()
    }

    func reset(eventIdentity: String) async throws {
        try await store.remove(eventIdentity: eventIdentity)
        await reconcile()
    }

    private func reconcile() async {
        let instant = now()
        _ = await reconciliation.trigger(now: instant, window: .productionDefault(now: instant))
    }
}
