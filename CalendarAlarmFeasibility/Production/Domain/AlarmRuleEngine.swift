import Foundation

protocol AlarmRuleEvaluating: Sendable {
    func evaluate(event: CalendarEvent, leadTime: AlarmLeadTime, now: Date) -> AlarmRuleResult
}

enum AlarmRuleResult: Equatable, Sendable {
    case candidate(AlarmCandidate)
    case excluded(AlarmExclusionReason)
}

enum AlarmExclusionReason: Equatable, Sendable {
    case allDay
    case alarmDateNotInFuture
}

struct AlarmRuleEngine: AlarmRuleEvaluating {
    func evaluate(event: CalendarEvent, leadTime: AlarmLeadTime, now: Date) -> AlarmRuleResult {
        guard !event.isAllDay else { return .excluded(.allDay) }
        let alarmDate = event.startDate.addingTimeInterval(-leadTime.duration)
        guard alarmDate > now else { return .excluded(.alarmDateNotInFuture) }
        return .candidate(AlarmCandidate(
            id: event.id,
            calendarIdentifier: event.calendarID,
            eventIdentifier: event.eventIdentifier,
            eventTitle: event.title,
            eventStartDate: event.startDate,
            alarmDate: alarmDate,
            appliedLeadTime: leadTime
        ))
    }
}
