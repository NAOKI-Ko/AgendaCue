import EventKit
import SwiftUI

struct FoundationRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var refreshGeneration = 0
    let dependencies: AppDependencies

    var body: some View {
        ProductionRootView(dependencies: dependencies, refreshGeneration: refreshGeneration)
        .task { await reconcileAndRefresh() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await reconcileAndRefresh() } } }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in Task { await reconcileAndRefresh() } }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSCalendarDayChanged)) { _ in Task { await reconcileAndRefresh() } }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSSystemTimeZoneDidChange)) { _ in Task { await reconcileAndRefresh() } }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in Task { await reconcileAndRefresh() } }
        .onChange(of: scenePhase) { _, phase in if phase == .background { dependencies.backgroundRefresh.scheduleNext() } }
    }

    private func reconcileAndRefresh() async {
        let now = Date()
        await dependencies.reconciliation.trigger(now: now, window: .productionDefault(now: now))
        refreshGeneration &+= 1
    }
}
