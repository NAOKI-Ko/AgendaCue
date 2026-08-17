import Foundation
import XCTest
@testable import CalendarAlarmFeasibility

final class AlarmCandidateTests: XCTestCase {
    private let now = Date(timeIntervalSinceReferenceDate: 1_000_000)

    func testFutureEventSubtractsFiveMinutes() {
        let start = now.addingTimeInterval(30 * 60)
        XCTAssertEqual(
            FeasibilityAlarmCandidate.evaluate(
                eventStart: start,
                isAllDay: false,
                leadTime: 5 * 60,
                now: now
            ),
            .eligible(start.addingTimeInterval(-5 * 60))
        )
    }

    func testAllDayEventIsIneligible() {
        XCTAssertEqual(
            FeasibilityAlarmCandidate.evaluate(
                eventStart: now.addingTimeInterval(60 * 60),
                isAllDay: true,
                leadTime: 5 * 60,
                now: now
            ),
            .ineligible(.allDay)
        )
    }

    func testAlarmDateEqualToNowIsIneligible() {
        XCTAssertEqual(
            FeasibilityAlarmCandidate.evaluate(
                eventStart: now.addingTimeInterval(5 * 60),
                isAllDay: false,
                leadTime: 5 * 60,
                now: now
            ),
            .ineligible(.alarmDateNotInFuture)
        )
    }

    func testAlarmDateBeforeNowIsIneligible() {
        XCTAssertEqual(
            FeasibilityAlarmCandidate.evaluate(
                eventStart: now.addingTimeInterval(4 * 60),
                isAllDay: false,
                leadTime: 5 * 60,
                now: now
            ),
            .ineligible(.alarmDateNotInFuture)
        )
    }
}
