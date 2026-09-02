import EventKit
import SwiftUI

struct FoundationRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var refreshGeneration = 0
    let dependencies: AppDependencies

    var body: some View {
        ProductionRootView(dependencies: dependencies, refreshGeneration: refreshGeneration)
        .task {
            PermissionDiagnostics.log("foundation.task", "scene=\(scenePhase) generation=\(refreshGeneration) raw=\(PermissionDiagnostics.calendarAuthorizationStatus())")
            await reconcileAndRefresh()
        }
        .onChange(of: scenePhase) { _, phase in
            PermissionDiagnostics.log("foundation.scenePhase", "scene=\(phase) generation=\(refreshGeneration) raw=\(PermissionDiagnostics.calendarAuthorizationStatus())")
            if phase == .active { Task { await reconcileAndRefresh() } }
        }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in Task { await reconcileAndRefresh() } }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSCalendarDayChanged)) { _ in Task { await reconcileAndRefresh() } }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSSystemTimeZoneDidChange)) { _ in Task { await reconcileAndRefresh() } }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in Task { await reconcileAndRefresh() } }
        .onChange(of: scenePhase) { _, phase in if phase == .background { dependencies.backgroundRefresh.scheduleNext() } }
    }

    private func reconcileAndRefresh() async {
        PermissionDiagnostics.log("foundation.reconcile.begin", "scene=\(scenePhase) generation=\(refreshGeneration) raw=\(PermissionDiagnostics.calendarAuthorizationStatus())")
        // Publish a UI permission refresh before reconciliation performs any EventKit or AlarmKit work.
        refreshGeneration &+= 1
        let now = Date()
        await dependencies.reconciliation.trigger(now: now, window: .productionDefault(now: now))
        refreshGeneration &+= 1
        PermissionDiagnostics.log("foundation.reconcile.end", "scene=\(scenePhase) generation=\(refreshGeneration) raw=\(PermissionDiagnostics.calendarAuthorizationStatus())")
    }
}
