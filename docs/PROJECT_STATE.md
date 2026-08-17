# Project State

- Phase: **WU-09-02**
- Current Work: **Japanese UI / Visual Redesign / Timeline Correction Pass**
- Status: **AUTOMATED GATE COMPLETE**
- Japanese UI: **PASS**
- Visual Redesign: **PASS WITH EVIDENCE**
- Timeline UX: **PASS**
- Accessibility QA: **PASS WITH AUTOMATED / SIMULATOR EVIDENCE**
- Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**
- Next: **WU-10 Release Gate**
- WU-10: **NOT STARTED**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 Simulators.

- XCTest: 142 tests passed, 0 failures (the accepted 120-test WU-09 suite plus 22 WU-09-02 tests).
- Specific iPhone 17 Pro Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- Production app Simulator launch smoke without sample arguments: passed.
- Twenty-four-screen visual matrix: passed; evidence and inspection notes are indexed in `docs/evidence/WU-09-02/README.md`.
- Japanese residual audit: app-owned primary UI, permission guidance, state copy, accessibility labels, and purpose strings are Japanese. Product/system names and source-provided calendar/event/source content remain unchanged.
- Scope audit: Production Domain, Services, Persistence, reliability/background orchestration, reconciliation behavior, and calendar-source semantics are byte-for-byte unchanged from accepted WU-09.

WU-09-02 replaces the app-owned Production presentation with a Japanese-first native SwiftUI design. Tabs are `今日 / 予定 / 設定`; Today uses a lightweight chronological hierarchy; Event Detail is summary-first; onboarding, calendar selection, Settings, permission recovery, empty, and error states use consistent Japanese copy and native controls.

The `予定` presentation window is display-only: past 14 days through future 14 days. Its initial position and `現在へ` action resolve to the current boundary or first future event. This does not change alarm ownership: reconciliation remains exactly `[now, now + 14 days)`, past events never become candidates, and the timeline performs no scheduling or cancellation.

Accessibility Inspector and real VoiceOver navigation were not automated. Signed real-device behavior, physical touch/contrast review, final human visual acceptance, release assets/metadata, and actual system-scheduled background execution remain WU-10 work. The pre-existing Swift concurrency warning in `EventOverrideService.swift` remains visible and was not changed.

## WU-10 carry-forward

- Background task identifier: `com.example.CalendarAlarmFeasibility.refresh`.
- Current bundle identifier: `com.example.CalendarAlarmFeasibility`.
- Both identifiers remain unchanged and require Production identity review in WU-10.
- Actual system-scheduled background execution timing was not tested on a real device; foreground/resume remains authoritative.

## Consolidated Human Review

- H01 iPhone AlarmKit fires.
- H02 Alarm fires in Silent Mode.
- H03 Alarm fires in Focus mode.
- H04 EventKit fetches iCloud and configured Google calendar events.
- H05 Calendar event → start date − lead time → AlarmKit → actual firing.
- H06 Paired Apple Watch display / haptic behavior.
- H07 Dismiss/state behavior across Apple Watch and iPhone.
- WU-09/WU-09-02 VoiceOver reading/order, touch targets, physical-device contrast, localization, and final visual acceptance.

No human item is marked passed. By explicit owner policy, intermediate Human Gates are waived and their device/UX/visual verification is deferred to WU-10. This is a schedule decision, not evidence of device behavior.
