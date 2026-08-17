import Foundation
import XCTest
@testable import CalendarAlarmFeasibility

final class AlarmRuleEngineTests: XCTestCase {
    private let engine = AlarmRuleEngine()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testFutureTimedEventProducesFiveMinuteCandidate() { assertCandidate(startOffset: 1800, lead: .fiveMinutes, expectedAlarmOffset: 1500) }
    func testAllDayEventIsExcluded() { XCTAssertEqual(evaluate(event(startOffset: 3600, allDay: true)), .excluded(.allDay)) }
    func testAlarmDateEqualToNowIsExcluded() { XCTAssertEqual(evaluate(event(startOffset: 300)), .excluded(.alarmDateNotInFuture)) }
    func testAlarmDateBeforeNowIsExcluded() { XCTAssertEqual(evaluate(event(startOffset: 299)), .excluded(.alarmDateNotInFuture)) }
    func testFutureEventWhoseLeadTimePushesAlarmPastIsExcluded() { XCTAssertEqual(evaluate(event(startOffset: 600), lead: .fifteenMinutes), .excluded(.alarmDateNotInFuture)) }
    func testThirtyMinuteLeadTimeSubtractsExactDuration() { assertCandidate(startOffset: 7200, lead: .thirtyMinutes, expectedAlarmOffset: 5400) }

    func testAlarmCanCrossMidnightIntoPreviousDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = calendar.date(from: DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: 2026, month: 1, day: 2, hour: 0, minute: 3))!
        let referenceNow = start.addingTimeInterval(-3600)
        guard case .candidate(let candidate) = engine.evaluate(event: event(at: start), leadTime: .fiveMinutes, now: referenceNow) else { return XCTFail("Expected candidate") }
        XCTAssertEqual(candidate.alarmDate, start.addingTimeInterval(-300))
        XCTAssertEqual(calendar.component(.day, from: candidate.alarmDate), 1)
    }

    func testNilEventIdentifierIsSafeAndMetadataMapsExactly() {
        guard case .candidate(let candidate) = evaluate(event(startOffset: 1800, identifier: nil)) else { return XCTFail("Expected candidate") }
        XCTAssertNil(candidate.eventIdentifier)
        XCTAssertEqual(candidate.id, "domain-id")
        XCTAssertEqual(candidate.calendarIdentifier, "calendar-id")
        XCTAssertEqual(candidate.eventTitle, "Meeting")
        XCTAssertEqual(candidate.appliedLeadTime, .fiveMinutes)
    }

    func testIdenticalInputsAreDeterministic() {
        let input = event(startOffset: 1800)
        XCTAssertEqual(evaluate(input), evaluate(input))
    }

    func testElapsedSubtractionAcrossDSTBoundaryUsesAbsoluteDate() {
        let start = Date(timeIntervalSince1970: 1_741_506_600)
        guard case .candidate(let candidate) = engine.evaluate(event: event(at: start), leadTime: .oneHour, now: start.addingTimeInterval(-7200)) else { return XCTFail("Expected candidate") }
        XCTAssertEqual(start.timeIntervalSince(candidate.alarmDate), 3600)
    }

    private func evaluate(_ event: CalendarEvent, lead: AlarmLeadTime = .fiveMinutes) -> AlarmRuleResult { engine.evaluate(event: event, leadTime: lead, now: now) }
    private func event(startOffset: TimeInterval, allDay: Bool = false, identifier: String? = "event-id") -> CalendarEvent { event(at: now.addingTimeInterval(startOffset), allDay: allDay, identifier: identifier) }
    private func event(at date: Date, allDay: Bool = false, identifier: String? = "event-id") -> CalendarEvent { .init(id: "domain-id", eventIdentifier: identifier, title: "Meeting", startDate: date, endDate: date.addingTimeInterval(1800), isAllDay: allDay, calendarID: "calendar-id") }
    private func assertCandidate(startOffset: TimeInterval, lead: AlarmLeadTime, expectedAlarmOffset: TimeInterval) {
        guard case .candidate(let candidate) = evaluate(event(startOffset: startOffset), lead: lead) else { return XCTFail("Expected candidate") }
        XCTAssertEqual(candidate.alarmDate, now.addingTimeInterval(expectedAlarmOffset))
        XCTAssertEqual(candidate.eventStartDate, now.addingTimeInterval(startOffset))
    }
}
