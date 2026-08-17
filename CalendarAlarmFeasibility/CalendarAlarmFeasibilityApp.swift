import SwiftData
import SwiftUI

@main
struct CalendarAlarmApp: App {
    private let dependencies: AppDependencies

    init() {
        dependencies = AppDependencies.live()
        dependencies.backgroundRefresh.start()
    }

    var body: some Scene {
        WindowGroup {
            FoundationRootView(dependencies: dependencies)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
