import Foundation
import XCTest
@testable import CalendarAlarmFeasibility

@MainActor
final class AlarmSchedulingTests: XCTestCase {
    func testNewSchedulePersistsAfterOneSystemCall() async throws {
        let x = setup(); let result = try await x.coordinator.schedule(candidate())
        guard case .scheduled(let id) = result else { return XCTFail() }
        XCTAssertEqual(x.system.scheduleCount, 1); XCTAssertEqual(x.store.value?.alarmIdentifier, id)
    }
    func testIdenticalTwiceIsNoOp() async throws { let x = setup(); _ = try await x.coordinator.schedule(candidate()); let second = try await x.coordinator.schedule(candidate()); guard case .alreadyScheduled = second else { return XCTFail() }; XCTAssertEqual(x.system.scheduleCount, 1) }
    func testConcurrentIdenticalRequestsDoNotDuplicate() async throws { let x = setup(); async let a = x.coordinator.schedule(candidate()); async let b = x.coordinator.schedule(candidate()); _ = try await (a,b); XCTAssertEqual(x.system.scheduleCount, 1) }
    func testChangedDateReplacesAndPreservesID() async throws { let x = setup(); guard case .scheduled(let first) = try await x.coordinator.schedule(candidate()) else { return XCTFail() }; guard case .replaced(let second) = try await x.coordinator.schedule(candidate(date: .init(timeIntervalSince1970: 2000))) else { return XCTFail() }; XCTAssertEqual(first, second); XCTAssertEqual(x.system.cancelCount, 1); XCTAssertEqual(x.system.lastDate, .init(timeIntervalSince1970: 2000)) }
    func testScheduleFailureDoesNotPersist() async { let x = setup(); x.system.setScheduleFailure(true); do { _ = try await x.coordinator.schedule(candidate()); XCTFail() } catch { XCTAssertNil(x.store.value) } }
    func testDeniedDoesNotSchedule() async { let x = setup(state: .denied); do { _ = try await x.coordinator.schedule(candidate()); XCTFail() } catch { XCTAssertEqual(x.system.scheduleCount, 0) } }
    func testNotDeterminedDoesNotRequestOrSchedule() async { let x = setup(state: .notDetermined); do { _ = try await x.coordinator.schedule(candidate()); XCTFail() } catch { XCTAssertEqual(x.system.scheduleCount, 0) } }
    func testCancelExistingRemovesOnlyAfterSystemSuccess() async throws { let x = setup(); _ = try await x.coordinator.schedule(candidate()); let result = try await x.coordinator.cancel(candidateIdentity: "logical"); XCTAssertEqual(result, .cancelled); XCTAssertNil(x.store.value) }
    func testCancelMissingIsNoOp() async throws { let x = setup(); let result = try await x.coordinator.cancel(candidateIdentity: "missing"); XCTAssertEqual(result, .notScheduled); XCTAssertEqual(x.system.cancelCount, 0) }
    func testCancelFailureRetainsMapping() async throws { let x = setup(); _ = try await x.coordinator.schedule(candidate()); x.system.setCancelFailure(true); do { _ = try await x.coordinator.cancel(candidateIdentity: "logical"); XCTFail() } catch { XCTAssertNotNil(x.store.value) } }
    func testNilEventIdentifierAndExactFixedDateAndTitleAreSafe() async throws { let x = setup(); let date = Date(timeIntervalSince1970: 1234); _ = try await x.coordinator.schedule(candidate(date: date, identifier: nil, title: "Meeting")); XCTAssertEqual(x.system.lastDate, date); XCTAssertEqual(x.system.lastTitle, "Meeting") }
    func testBlankTitleUsesDeterministicFallback() async throws { let x = setup(); _ = try await x.coordinator.schedule(candidate(title: "  ")); XCTAssertEqual(x.system.lastTitle, "Calendar Event") }
    func testReplacementFailureDoesNotUpdateMapping() async throws { let x = setup(); _ = try await x.coordinator.schedule(candidate()); let old = x.store.value; x.system.setScheduleFailure(true); do { _ = try await x.coordinator.schedule(candidate(date: .init(timeIntervalSince1970: 3000))); XCTFail() } catch { XCTAssertEqual(x.store.value, old) } }

    private func candidate(date: Date = .init(timeIntervalSince1970: 1000), identifier: String? = "event", title: String = "Title") -> AlarmCandidate { .init(id: "logical", calendarIdentifier: "cal", eventIdentifier: identifier, eventTitle: title, eventStartDate: date.addingTimeInterval(300), alarmDate: date, appliedLeadTime: .fiveMinutes) }
    private func setup(state: PermissionState = .authorized) -> (coordinator: AlarmSchedulingCoordinator, system: FakeAlarmSystem, store: FakeAlarmStore) { let system = FakeAlarmSystem(state: state); let store = FakeAlarmStore(); return (.init(system: system, store: store), system, store) }
}

private enum FakeFailure: Error { case requested }
@MainActor
private final class FakeAlarmSystem: AlarmSystemScheduling, @unchecked Sendable {
    let state: PermissionState; var scheduleCount = 0; var cancelCount = 0; var lastDate: Date?; var lastTitle: String?; var scheduleFailure = false; var cancelFailure = false
    init(state: PermissionState) { self.state = state }
    func authorizationState() async -> PermissionState { state }
    func schedule(id: UUID, at date: Date, title: String) async throws { scheduleCount += 1; if scheduleFailure { throw FakeFailure.requested }; lastDate = date; lastTitle = title }
    func cancel(id: UUID) async throws { cancelCount += 1; if cancelFailure { throw FakeFailure.requested } }
    func setScheduleFailure(_ value: Bool) { scheduleFailure = value }
    func setCancelFailure(_ value: Bool) { cancelFailure = value }
}
@MainActor
private final class FakeAlarmStore: ScheduledAlarmStoring, @unchecked Sendable {
    var value: ScheduledAlarmMapping?
    func mapping(for identity: String) async -> ScheduledAlarmMapping? { value?.candidateIdentity == identity ? value : nil }
    func save(_ mapping: ScheduledAlarmMapping) async { value = mapping }
    func remove(identity: String) async { if value?.candidateIdentity == identity { value = nil } }
}
