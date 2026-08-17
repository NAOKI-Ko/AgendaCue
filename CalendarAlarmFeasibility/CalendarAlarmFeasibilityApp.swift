import SwiftUI

@main
struct CalendarAlarmFeasibilityApp: App {
    var body: some Scene {
        WindowGroup {
            FeasibilityView(
                viewModel: FeasibilityViewModel(
                    calendarProvider: EventKitCalendarEventProvider(),
                    alarmScheduler: AlarmKitScheduler()
                )
            )
        }
    }
}
