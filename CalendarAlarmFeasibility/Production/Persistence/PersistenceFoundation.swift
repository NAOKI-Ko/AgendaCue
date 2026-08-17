import Foundation
import SwiftData

@Model
final class AppSettingsRecord {
    @Attribute(.unique) var key: String
    var defaultLeadTimeMinutes: Int

    init(key: String = "app-settings", defaultLeadTimeMinutes: Int = AlarmLeadTime.default.rawValue) {
        self.key = key
        self.defaultLeadTimeMinutes = defaultLeadTimeMinutes
    }

    var settings: AppSettings {
        get {
            AppSettings(defaultLeadTime: AlarmLeadTime(rawValue: defaultLeadTimeMinutes) ?? .default)
        }
        set {
            defaultLeadTimeMinutes = newValue.defaultLeadTime.rawValue
        }
    }
}

@Model
final class SelectedCalendarRecord {
    @Attribute(.unique) var calendarIdentifier: String

    init(calendarIdentifier: String) {
        self.calendarIdentifier = calendarIdentifier
    }
}

@Model
final class CalendarSelectionStateRecord {
    @Attribute(.unique) var key: String
    var isEstablished: Bool

    init(key: String = "calendar-selection", isEstablished: Bool = false) {
        self.key = key
        self.isEstablished = isEstablished
    }
}

@Model
final class EventOverrideRecord {
    @Attribute(.unique) var id: UUID
    var eventIdentifier: String
    var isEnabled: Bool
    var leadTimeMinutes: Int?

    init(
        id: UUID = UUID(),
        eventIdentifier: String,
        isEnabled: Bool,
        leadTimeMinutes: Int? = nil
    ) {
        self.id = id
        self.eventIdentifier = eventIdentifier
        self.isEnabled = isEnabled
        self.leadTimeMinutes = leadTimeMinutes
    }
}

@Model
final class ScheduledAlarmRecord {
    @Attribute(.unique) var candidateIdentity: String
    var alarmIdentifier: UUID
    var alarmDate: Date

    init(candidateIdentity: String, alarmIdentifier: UUID, alarmDate: Date) {
        self.candidateIdentity = candidateIdentity
        self.alarmIdentifier = alarmIdentifier
        self.alarmDate = alarmDate
    }
}

enum PersistenceContainer {
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            AppSettingsRecord.self,
            SelectedCalendarRecord.self,
            CalendarSelectionStateRecord.self,
            EventOverrideRecord.self,
            ScheduledAlarmRecord.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
