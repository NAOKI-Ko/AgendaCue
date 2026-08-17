import SwiftData

@MainActor
struct AppDependencies {
    let modelContainer: ModelContainer
    let calendarPermission: any CalendarPermissionProviding
    let alarmPermission: any AlarmPermissionProviding

    static func live() -> AppDependencies {
        do {
            return AppDependencies(
                modelContainer: try PersistenceContainer.make(),
                calendarPermission: EventKitPermissionProvider(),
                alarmPermission: AlarmKitPermissionProvider()
            )
        } catch {
            preconditionFailure("Unable to create the local model container: \(error)")
        }
    }
}
