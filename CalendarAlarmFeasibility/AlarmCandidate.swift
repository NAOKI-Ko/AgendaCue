import Foundation

enum FeasibilityAlarmCandidate: Equatable, Sendable {
    case eligible(Date)
    case ineligible(Reason)

    enum Reason: Equatable, Sendable {
        case allDay
        case alarmDateNotInFuture
    }

    static func evaluate(
        eventStart: Date,
        isAllDay: Bool,
        leadTime: TimeInterval,
        now: Date
    ) -> FeasibilityAlarmCandidate {
        guard !isAllDay else {
            return .ineligible(.allDay)
        }

        let alarmDate = eventStart.addingTimeInterval(-leadTime)
        guard alarmDate > now else {
            return .ineligible(.alarmDateNotInFuture)
        }

        return .eligible(alarmDate)
    }
}
