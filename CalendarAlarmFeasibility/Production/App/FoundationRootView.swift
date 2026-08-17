import EventKit
import SwiftUI

struct FoundationRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    let dependencies: AppDependencies

    var body: some View {
        ProductionRootView(dependencies: dependencies)
        .task { await reconcile() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await reconcile() } } }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in Task { await reconcile() } }
    }

    private func reconcile() async {
        let now = Date()
        await dependencies.reconciliation.trigger(now: now, window: .productionDefault(now: now))
    }
}
