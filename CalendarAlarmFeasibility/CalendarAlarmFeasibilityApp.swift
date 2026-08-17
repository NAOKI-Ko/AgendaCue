import SwiftData
import SwiftUI

@main
struct CalendarAlarmApp: App {
    private let dependencies: AppDependencies

    init() {
        dependencies = AppDependencies.live()
    }

    var body: some Scene {
        WindowGroup {
            FoundationRootView()
        }
        .modelContainer(dependencies.modelContainer)
    }
}
