import EventKit
import SwiftUI

struct FoundationRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    let reconciliation: CalendarReconciliationCoordinator

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.largeTitle)
            Text("Calendar Alarm")
                .font(.title)
            Text("Product foundation ready")
                .foregroundStyle(.secondary)
        }
        .padding()
        .task { await reconcile() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await reconcile() } } }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in Task { await reconcile() } }
    }

    private func reconcile() async {
        let now = Date()
        await reconciliation.trigger(now: now, window: .productionDefault(now: now))
    }
}
