import Foundation
import SwiftData
import XCTest
@testable import CalendarAlarmFeasibility

final class ProductionUXTests: XCTestCase {
    func testFirstLaunchRoutesToOnboarding() { XCTAssertEqual(ProductionPresentationPolicy.route(onboardingCompleted: false), .onboarding) }
    func testCompletedOnboardingRoutesToMainApp() { XCTAssertEqual(ProductionPresentationPolicy.route(onboardingCompleted: true), .main) }
    func testPermissionRevocationDoesNotResetCompletedOnboardingRoute() { XCTAssertEqual(ProductionPresentationPolicy.route(onboardingCompleted: true), .main) }

    func testOnboardingCompletionPersistsAcrossStoreInstances() {
        let suite = "OnboardingCompletionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let first = UserDefaultsOnboardingCompletionStore(defaults: defaults)
        XCTAssertFalse(first.isCompleted)
        first.markCompleted()
        XCTAssertTrue(UserDefaultsOnboardingCompletionStore(defaults: defaults).isCompleted)
    }

    func testNotDeterminedPermissionRequestsExactlyOnce() async {
        var requests = 0
        let result = await OnboardingPermissionSequence.resolve(state: .notDetermined) { requests += 1; return .authorized }
        XCTAssertEqual(result, .authorized); XCTAssertEqual(requests, 1)
    }

    func testAlreadyAuthorizedPermissionDoesNotPrompt() async {
        var requests = 0
        let result = await OnboardingPermissionSequence.resolve(state: .authorized) { requests += 1; return .denied }
        XCTAssertEqual(result, .authorized); XCTAssertEqual(requests, 0)
    }

    func testDeniedPermissionDoesNotPromptAgainAndCanExitFlow() async {
        var requests = 0
        let result = await OnboardingPermissionSequence.resolve(state: .denied) { requests += 1; return .authorized }
        XCTAssertEqual(result, .denied); XCTAssertEqual(requests, 0)
    }

    func testProductionTabsUseJapaneseLabels() {
        XCTAssertEqual([ProductionCopy.alarm, ProductionCopy.settings], ["アラーム", "設定"])
    }

    @MainActor
    func testPresentationClockRefreshesFromInjectedTimeSource() {
        var instant = Date(timeIntervalSince1970: 1_000)
        let clock = ProductionPresentationClock(nowProvider: { instant })
        XCTAssertEqual(clock.now, instant)
        instant = Date(timeIntervalSince1970: 1_061)
        clock.refresh()
        XCTAssertEqual(clock.now, instant)
    }

    @MainActor
    func testPresentationClockActivationIsCoalescedAndDeactivationStopsIt() {
        let clock = ProductionPresentationClock(interval: 3_600)
        clock.activate(); clock.activate()
        XCTAssertTrue(clock.isRunning)
        clock.deactivate()
        XCTAssertFalse(clock.isRunning)
    }

    @MainActor
    func testPresentationClockTickHasNoPlatformSideEffects() {
        var reads = 0
        let clock = ProductionPresentationClock(nowProvider: { reads += 1; return Date(timeIntervalSince1970: TimeInterval(reads)) })
        clock.refresh()
        XCTAssertEqual(reads, 2)
        // The clock exposes only lifecycle/refresh operations and owns no service dependency;
        // advancing it therefore cannot fetch, reconcile, persist, or schedule an alarm.
        XCTAssertEqual(clock.now, Date(timeIntervalSince1970: 2))
    }

    func testUnifiedTimelineUsesStartDateAsPastFutureBoundary() {
        let now = Date(timeIntervalSince1970: 1_000)
        let started = CalendarEvent(id: "started", eventIdentifier: nil, title: "開始済み", startDate: .init(timeIntervalSince1970: 999), endDate: .init(timeIntervalSince1970: 2_000), isAllDay: false, calendarID: "c")
        XCTAssertEqual(ProductionPresentationPolicy.alarmTimelinePhase(started, now: now), .completed)
        XCTAssertEqual(ProductionPresentationPolicy.alarmTimelinePhase(event("equal", 1_000), now: now), .future)
    }

    func testUnifiedTimelineAlarmCopyIsExactAndPastStateIsNotDuplicated() {
        let now = Date(timeIntervalSince1970: 10_000)
        let future = event("future", 20_000)
        XCTAssertEqual(ProductionPresentationPolicy.alarmTimelineText(event: future, override: nil, settings: .init(), now: now), Date(timeIntervalSince1970: 19_700).formatted(date: .omitted, time: .shortened))
        XCTAssertEqual(ProductionPresentationPolicy.alarmTimelineText(event: event("past", 1_000), override: nil, settings: .init(), now: now), "終了済み")
    }

    func testUnifiedTimelineIdentifiersAndNavigationLabelsAreSemantic() {
        XCTAssertEqual(ProductionAccessibilityID.alarmTimelineList, "alarm-timeline.list")
        XCTAssertEqual(ProductionAccessibilityID.alarmTimelineReturnToCurrent, "alarm-timeline.return-current")
    }

    func testAppOwnedPrimaryCopyIsJapanese() {
        XCTAssertEqual(ProductionCopy.calendars, "カレンダー")
        XCTAssertEqual(ProductionCopy.defaultAlarmTime, "デフォルトのアラーム時間")
        XCTAssertEqual(ProductionCopy.minutesBefore(.fifteenMinutes), "15分前")
    }

    func testPermissionGuidanceIsJapanese() {
        XCTAssertEqual(ProductionPresentationPolicy.permissionStatusText(.denied), "設定から許可してください")
        XCTAssertEqual(ProductionCopy.permissionRecovery, "設定でアクセスを許可したあと、このアプリに戻ってください。")
    }

    func testEmptyAndErrorCopyIsJapanese() {
        XCTAssertEqual(ProductionCopy.emptyTodayTitle, "今日の予定はありません")
        XCTAssertEqual(ProductionCopy.emptyTimelineTitle, "表示できる予定がありません")
        XCTAssertEqual(ProductionCopy.loadErrorTitle, "カレンダーを読み込めません")
    }

    func testTodayEventsSortChronologically() {
        let a = event("a", 200); let b = event("b", 100)
        XCTAssertEqual(ProductionPresentationPolicy.sorted([a, b]).map(\.id), ["b", "a"])
    }

    func testEffectiveLeadTextUsesJapaneseCustomValue() {
        let value = EventOverride(eventIdentity: "a", state: .enabled(leadTimeOverride: .fifteenMinutes))
        XCTAssertTrue(ProductionPresentationPolicy.alarmText(event: event("a", 10_000), override: value, settings: .init(), now: .init(timeIntervalSince1970: 0)).contains("15分前"))
    }

    func testOffOverrideCommunicatesOffWithoutColor() {
        XCTAssertEqual(ProductionPresentationPolicy.alarmText(event: event("a", 1_000), override: .init(eventIdentity: "a", state: .disabled), settings: .init(), now: .init(timeIntervalSince1970: 0)), "アラームなし")
    }

    func testAllDayDoesNotClaimAlarm() {
        let value = CalendarEvent(id: "a", eventIdentifier: nil, title: "終日", startDate: .init(timeIntervalSince1970: 1_000), endDate: .init(timeIntervalSince1970: 2_000), isAllDay: true, calendarID: "c")
        XCTAssertEqual(ProductionPresentationPolicy.alarmText(event: value, override: nil, settings: .init(), now: .init(timeIntervalSince1970: 0)), "終日予定にはアラームなし")
    }

    func testEventAccessibilityLabelUsesJapaneseConceptualSemantics() {
        let label = ProductionPresentationPolicy.eventAccessibilityLabel(event: event("チーム確認", 10_000), calendarTitle: "仕事", override: nil, settings: .init(), now: .init(timeIntervalSince1970: 0))
        XCTAssertTrue(label.contains("チーム確認")); XCTAssertTrue(label.contains("開始")); XCTAssertTrue(label.contains("カレンダー 仕事")); XCTAssertTrue(label.contains("アラーム 5分前"))
    }

    func testPastAndFutureAccessibilitySemanticsAreExplicit() {
        let past = CalendarEvent(id: "past", eventIdentifier: "past", title: "完了予定", startDate: .init(timeIntervalSince1970: 100), endDate: .init(timeIntervalSince1970: 200), isAllDay: false, calendarID: "c")
        let label = ProductionPresentationPolicy.eventAccessibilityLabel(event: past, calendarTitle: "仕事", override: nil, settings: .init(), now: .init(timeIntervalSince1970: 1_000))
        XCTAssertTrue(label.contains("終了済み")); XCTAssertTrue(label.contains("5分前"))
    }

    func testDefaultAndCustomEventDetailCopyAreJapaneseAndUnambiguous() {
        XCTAssertEqual(ProductionPresentationPolicy.detailTimingText(lead: nil, settings: .init(defaultLeadTime: .tenMinutes)), "デフォルト設定（10分前）を使用")
        XCTAssertEqual(ProductionPresentationPolicy.detailTimingText(lead: .thirtyMinutes, settings: .init()), "この予定のみ 30分前")
    }

    func testDeniedPermissionOffersSettingsRecoveryOnlyWhenNeeded() {
        XCTAssertTrue(ProductionPresentationPolicy.shouldOfferSettings(calendar: .denied, alarm: .authorized))
        XCTAssertFalse(ProductionPresentationPolicy.shouldOfferSettings(calendar: .authorized, alarm: .authorized))
    }

    func testLongEventAndCalendarTitlesPreserveJapaneseAlarmMeaning() {
        let longEvent = CalendarEvent(id: "long", eventIdentifier: "long", title: String(repeating: "重要な企画会議", count: 12), startDate: .init(timeIntervalSince1970: 10_000), endDate: .init(timeIntervalSince1970: 11_000), isAllDay: false, calendarID: "c")
        let label = ProductionPresentationPolicy.eventAccessibilityLabel(event: longEvent, calendarTitle: String(repeating: "共有カレンダー", count: 10), override: nil, settings: .init(), now: .init(timeIntervalSince1970: 0))
        XCTAssertTrue(label.contains(longEvent.title)); XCTAssertTrue(label.contains("アラーム 5分前"))
    }

    func testSampleModeIsRecognizedArgumentGated() {
        XCTAssertNil(SampleScenarioPolicy.scenario(arguments: []))
        XCTAssertNil(SampleScenarioPolicy.scenario(arguments: ["-UIScenario=unknown"]))
        XCTAssertEqual(SampleScenarioPolicy.scenario(arguments: ["-UIScenario=timeline"]), "timeline")
    }

    func testMajorAccessibilityIdentifiersRemainStableAndSemantic() {
        XCTAssertEqual(ProductionAccessibilityID.todayList, "today.list")
        XCTAssertEqual(ProductionAccessibilityID.eventAlarmToggle, "event.alarm.toggle")
        XCTAssertEqual(ProductionAccessibilityID.timelineReturnToCurrent, "timeline.return-current")
    }

    func testUserFacingPresentationDoesNotExposeInternalTerms() {
        let output = ProductionPresentationPolicy.eventAccessibilityLabel(event: event("a", 10_000), calendarTitle: "仕事", override: nil, settings: .init(), now: .init(timeIntervalSince1970: 0)).lowercased()
        for forbidden in ["eventkit", "alarmkit", "reconciliation", "candidate", "mapping", "uuid"] { XCTAssertFalse(output.contains(forbidden)) }
    }

    func testPrimaryCopyHasNoUnintentionalEnglishResiduals() {
        for value in ProductionCopy.primaryAuditStrings {
            XCTAssertNil(value.range(of: "[A-Za-z]", options: .regularExpression), "Unexpected English in: \(value)")
        }
    }

    func testDateAndTimePresentationUsesSystemFormatterPath() {
        XCTAssertFalse(ProductionPresentationPolicy.startTimeText(for: event("a", 10_000)).isEmpty)
        XCTAssertNotEqual(ProductionPresentationPolicy.startTimeText(for: event("a", 10_000)), "HH:mm")
        XCTAssertFalse(ProductionPresentationPolicy.daySubtitle(.init(timeIntervalSince1970: 10_000)).isEmpty)
    }

    func testTimelineWindowIncludesPastAndFutureFourteenDays() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let window = ProductionPresentationPolicy.timelineWindow(now: now, calendar: utcCalendar)
        XCTAssertTrue(window.start < now); XCTAssertEqual(window.end.timeIntervalSince(now), 14 * 86_400, accuracy: 0.001)
        XCTAssertTrue(window.contains(now.addingTimeInterval(-13 * 86_400)))
        XCTAssertTrue(window.contains(now.addingTimeInterval(13 * 86_400)))
    }

    func testTimelineExcludesEventsOutsideDisplayWindow() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let values = [event("old", now.timeIntervalSince1970 - 15 * 86_400), event("inside", now.timeIntervalSince1970 - 2 * 86_400), event("future", now.timeIntervalSince1970 + 2 * 86_400), event("far", now.timeIntervalSince1970 + 15 * 86_400)]
        XCTAssertEqual(ProductionPresentationPolicy.timelineEvents(values, now: now, calendar: utcCalendar).map(\.id), ["inside", "future"])
    }

    func testTimelineIsChronologicalAndDateSectionsAreDeterministic() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let values = [event("future", now.timeIntervalSince1970 + 90_000), event("past", now.timeIntervalSince1970 - 90_000), event("soon", now.timeIntervalSince1970 + 3_600)]
        let first = ProductionPresentationPolicy.timelineSections(values, now: now, calendar: utcCalendar)
        let second = ProductionPresentationPolicy.timelineSections(values.reversed(), now: now, calendar: utcCalendar)
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.flatMap(\.events).map(\.id), ["past", "soon", "future"])
    }

    func testTimelinePresentationWindowDoesNotAlterReconciliationHorizon() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let display = ProductionPresentationPolicy.timelineWindow(now: now, calendar: utcCalendar)
        let reconciliation = ReconciliationWindow.productionDefault(now: now)
        XCTAssertTrue(display.start < now)
        XCTAssertEqual(reconciliation.startDate, now)
        XCTAssertEqual(reconciliation.endDate, now.addingTimeInterval(14 * 86_400))
    }

    func testPastEventDoesNotBecomeAlarmCandidate() {
        let now = Date(timeIntervalSince1970: 10_000)
        XCTAssertEqual(AlarmRuleEngine().evaluate(event: event("past", 9_000), leadTime: .fiveMinutes, now: now), .excluded(.alarmDateNotInFuture))
    }

    func testInitialTimelineAnchorUsesCurrentForTodayFutureEvent() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        XCTAssertEqual(ProductionPresentationPolicy.initialTimelineAnchor(events: [event("soon", now.timeIntervalSince1970 + 60)], now: now, calendar: utcCalendar), .current)
    }

    func testInitialTimelineAnchorUsesFirstFutureWhenNoTodayFutureEvent() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let tomorrow = utcCalendar.startOfDay(for: now).addingTimeInterval(86_400 + 3_600)
        XCTAssertEqual(ProductionPresentationPolicy.initialTimelineAnchor(events: [event("tomorrow", tomorrow.timeIntervalSince1970)], now: now, calendar: utcCalendar), .event("tomorrow"))
    }

    func testNoFutureEventAnchorFallsBackSafelyToCurrent() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        XCTAssertEqual(ProductionPresentationPolicy.initialTimelineAnchor(events: [event("past", now.timeIntervalSince1970 - 3_600)], now: now, calendar: utcCalendar), .current)
    }

    func testReturnToCurrentUsesSameStableAnchorPolicy() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let values = [event("past", now.timeIntervalSince1970 - 3_600), event("soon", now.timeIntervalSince1970 + 3_600)]
        XCTAssertEqual(ProductionPresentationPolicy.returnToCurrentAnchor(events: values, now: now, calendar: utcCalendar), ProductionPresentationPolicy.initialTimelineAnchor(events: values, now: now, calendar: utcCalendar))
    }

    func testRepeatedTimelinePresentationDoesNotDuplicateOrMutateEvents() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let values = [event("a", now.timeIntervalSince1970 - 3_600), event("b", now.timeIntervalSince1970 + 3_600)]
        let first = ProductionPresentationPolicy.timelineEvents(values, now: now, calendar: utcCalendar)
        let second = ProductionPresentationPolicy.timelineEvents(values, now: now, calendar: utcCalendar)
        XCTAssertEqual(first, second); XCTAssertEqual(Set(first.map(\.id)).count, first.count); XCTAssertEqual(values.count, 2)
    }

    func testTimelineEventPhaseDistinguishesPastCurrentAndFutureWithoutColor() {
        let now = Date(timeIntervalSince1970: 1_000)
        let completed = CalendarEvent(id: "past", eventIdentifier: nil, title: "過去", startDate: .init(timeIntervalSince1970: 100), endDate: .init(timeIntervalSince1970: 200), isAllDay: false, calendarID: "c")
        let active = CalendarEvent(id: "active", eventIdentifier: nil, title: "開催中", startDate: .init(timeIntervalSince1970: 900), endDate: .init(timeIntervalSince1970: 1_100), isAllDay: false, calendarID: "c")
        XCTAssertEqual(ProductionPresentationPolicy.phaseText(ProductionPresentationPolicy.eventPhase(completed, now: now)), "終了済み")
        XCTAssertEqual(ProductionPresentationPolicy.phaseText(ProductionPresentationPolicy.eventPhase(active, now: now)), "開催中")
        XCTAssertNil(ProductionPresentationPolicy.phaseText(ProductionPresentationPolicy.eventPhase(event("future", 2_000), now: now)))
    }

    func testPastEventsAreIncludedInTimelinePresentation() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let past = event("past", now.timeIntervalSince1970 - 2 * 86_400)
        XCTAssertEqual(ProductionPresentationPolicy.timelineEvents([past], now: now, calendar: utcCalendar).map(\.id), ["past"])
    }

    func testFutureEventsAreIncludedInTimelinePresentation() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let future = event("future", now.timeIntervalSince1970 + 2 * 86_400)
        XCTAssertEqual(ProductionPresentationPolicy.timelineEvents([future], now: now, calendar: utcCalendar).map(\.id), ["future"])
    }

    func testTimelineSectionsAlwaysProvideTodayBoundarySectionWhenEventsExistElsewhere() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let tomorrow = event("tomorrow", now.timeIntervalSince1970 + 86_400)
        let sections = ProductionPresentationPolicy.timelineSections([tomorrow], now: now, calendar: utcCalendar)
        XCTAssertTrue(sections.contains { utcCalendar.isDate($0.day, inSameDayAs: now) && $0.events.isEmpty })
    }

    func testTimelineProjectionContainsOnlyReadOnlyCalendarFacts() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let input = [event("past", now.timeIntervalSince1970 - 60), event("future", now.timeIntervalSince1970 + 60)]
        let output = ProductionPresentationPolicy.timelineEvents(input, now: now, calendar: utcCalendar)
        XCTAssertEqual(output, input)
        XCTAssertEqual(output.map(\.eventIdentifier), input.map(\.eventIdentifier))
    }

    func testReturnToCurrentAccessibilityTargetIsStable() {
        XCTAssertEqual(TimelineAnchor.current.id, ProductionAccessibilityID.timelineCurrentBoundary)
        XCTAssertEqual(ProductionAccessibilityID.timelineReturnToCurrent, "timeline.return-current")
    }

    func testLongCalendarNameDoesNotChangeAccessibilityAlarmState() {
        let label = ProductionPresentationPolicy.eventAccessibilityLabel(event: event("予定", 10_000), calendarTitle: String(repeating: "長いカレンダー名", count: 20), override: .init(eventIdentity: "予定", state: .disabled), settings: .init(), now: .init(timeIntervalSince1970: 0))
        XCTAssertTrue(label.contains("長いカレンダー名")); XCTAssertTrue(label.contains("アラームなし"))
    }

    func testEverySupportedLeadHasConciseJapaneseCopy() {
        XCTAssertEqual(AlarmLeadTime.allCases.map(ProductionCopy.minutesBefore), ["5分前", "10分前", "15分前", "30分前", "60分前"])
    }

    func testTodayItemsInsertCurrentMarkerAtDeterministicChronologicalPosition() {
        let now = Date(timeIntervalSince1970: 10_000)
        let items = ProductionPresentationPolicy.todayItems(events: [event("future", 20_000), event("past", 1_000)], now: now)
        XCTAssertEqual(items, [.event(event("past", 1_000)), .current(now), .event(event("future", 20_000))])
    }

    func testTodayCurrentMarkerSafelyFollowsAllPastEvents() {
        let now = Date(timeIntervalSince1970: 10_000)
        let items = ProductionPresentationPolicy.todayItems(events: [event("past", 1_000)], now: now)
        XCTAssertEqual(items.last, .current(now))
    }

    func testTodayFutureAlarmPresentsExactAlarmTimeWithoutRepeatedLead() {
        let now = Date(timeIntervalSince1970: 10_000)
        let future = event("future", 20_000)
        let expected = Date(timeIntervalSince1970: 19_700).formatted(date: .omitted, time: .shortened)
        let output = ProductionPresentationPolicy.todayAlarmText(event: future, override: nil, settings: .init(), now: now)
        XCTAssertEqual(output, expected)
        XCTAssertFalse(output.contains("5分前"))
    }

    func testTodayPastAlarmStateIsExplicitWithoutColor() {
        let output = ProductionPresentationPolicy.todayAlarmText(event: event("past", 1_000), override: nil, settings: .init(), now: .init(timeIntervalSince1970: 10_000))
        XCTAssertEqual(output, "5分前・終了済み")
    }

    func testTodayAlarmOffStateIsExplicit() {
        let override = EventOverride(eventIdentity: "future", state: .disabled)
        XCTAssertEqual(ProductionPresentationPolicy.todayAlarmText(event: event("future", 20_000), override: override, settings: .init(), now: .init(timeIntervalSince1970: 10_000)), "アラームなし")
    }

    func testTodaySummaryCountMatchesDisplayedEventCount() {
        XCTAssertEqual(ProductionCopy.todaySummary(count: 0), "今日の予定は0件です")
        XCTAssertEqual(ProductionCopy.todaySummary(count: 5), "今日の予定は5件です")
    }

    func testTodayCurrentMarkerHasNaturalAccessibilityLabel() {
        let now = Date(timeIntervalSince1970: 10_000)
        XCTAssertEqual(ProductionPresentationPolicy.currentTimeAccessibilityLabel(now), "現在、\(ProductionPresentationPolicy.currentTimeText(now))")
    }

    func testTodayPresentationIdentifiersRemainStableAcrossRepeatedLayoutEvaluation() {
        let now = Date(timeIntervalSince1970: 10_000)
        let values = [event("past", 1_000), event("future", 20_000)]
        XCTAssertEqual(ProductionPresentationPolicy.todayItems(events: values, now: now).map(\.id), ProductionPresentationPolicy.todayItems(events: values, now: now).map(\.id))
        XCTAssertEqual(ProductionPresentationPolicy.todayItems(events: values, now: now).map(\.id), ["today.event.past", ProductionAccessibilityID.todayCurrentMarker, "today.event.future"])
    }

    @MainActor func testDefaultLeadMutationPersistsAndTriggersReconciliation() async throws {
        let container = try PersistenceContainer.make(inMemory: true); let trigger = UXFakeTrigger(); let service = AppSettingsService(container: container, reconciliation: trigger)
        try await service.setDefaultLeadTime(.thirtyMinutes, now: .init(timeIntervalSince1970: 1_000))
        let saved = try await service.load(); XCTAssertEqual(saved.defaultLeadTime, .thirtyMinutes); XCTAssertEqual(trigger.count, 1)
    }

    private var utcCalendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        return value
    }

    private func event(_ id: String, _ time: TimeInterval) -> CalendarEvent {
        .init(id: id, eventIdentifier: id, title: id, startDate: .init(timeIntervalSince1970: time), endDate: .init(timeIntervalSince1970: time + 1_800), isAllDay: false, calendarID: "c")
    }
}

@MainActor private final class UXFakeTrigger: ReconciliationTriggering, @unchecked Sendable {
    var count = 0
    func trigger(now: Date, window: ReconciliationWindow) async -> ReconciliationReport? { count += 1; return nil }
}
