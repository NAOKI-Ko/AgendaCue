import SwiftData

@MainActor
struct AppDependencies {
    let modelContainer: ModelContainer
    let calendarPermission: any CalendarPermissionProviding
    let alarmPermission: any AlarmPermissionProviding
    let reconciliation: CalendarReconciliationCoordinator
    let eventOverrides: EventOverrideService

    static func live() -> AppDependencies {
        do {
            let container = try PersistenceContainer.make()
            let calendarPermission = EventKitPermissionProvider()
            let alarmPermission = AlarmKitPermissionProvider()
            let selections = CalendarSelectionStore(context: container.mainContext)
            let source = CalendarSourceCoordinator(source: EventKitCalendarSource(), selections: selections)
            let mappingStore = SwiftDataScheduledAlarmStore(container: container)
            let overrideStore = SwiftDataEventOverrideStore(container: container)
            let scheduler = AlarmSchedulingCoordinator(system: AlarmKitSystemScheduler(), store: mappingStore)
            let input = LiveReconciliationInput(permission: calendarPermission, calendarSource: source, context: container.mainContext, overrides: overrideStore)
            let reconciliation = CalendarReconciliationCoordinator(input: input, scheduler: scheduler, store: mappingStore)
            return AppDependencies(modelContainer: container, calendarPermission: calendarPermission, alarmPermission: alarmPermission,
                reconciliation: reconciliation, eventOverrides: EventOverrideService(store: overrideStore, reconciliation: reconciliation))
        } catch {
            preconditionFailure("Unable to create the local model container: \(error)")
        }
    }
}
