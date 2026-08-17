import SwiftData

@MainActor
struct AppDependencies {
    let modelContainer: ModelContainer
    let calendarPermission: any CalendarPermissionProviding
    let alarmPermission: any AlarmPermissionProviding
    let reconciliation: CalendarReconciliationCoordinator

    static func live() -> AppDependencies {
        do {
            let container = try PersistenceContainer.make()
            let calendarPermission = EventKitPermissionProvider()
            let alarmPermission = AlarmKitPermissionProvider()
            let selections = CalendarSelectionStore(context: container.mainContext)
            let source = CalendarSourceCoordinator(source: EventKitCalendarSource(), selections: selections)
            let mappingStore = SwiftDataScheduledAlarmStore(container: container)
            let scheduler = AlarmSchedulingCoordinator(system: AlarmKitSystemScheduler(), store: mappingStore)
            let input = LiveReconciliationInput(permission: calendarPermission, calendarSource: source, context: container.mainContext)
            return AppDependencies(modelContainer: container, calendarPermission: calendarPermission, alarmPermission: alarmPermission,
                reconciliation: CalendarReconciliationCoordinator(input: input, scheduler: scheduler, store: mappingStore))
        } catch {
            preconditionFailure("Unable to create the local model container: \(error)")
        }
    }
}
