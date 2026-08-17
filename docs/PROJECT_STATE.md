# Project State

- Phase: **WU-09-03**
- Current Work: **Today Visual Source of Truth Correction Pass**
- Status: **AUTOMATED GATE COMPLETE**
- Today Visual Source of Truth: **IMPLEMENTED — OWNER APPROVED**
- Visual QA: **PASS WITH EVIDENCE**
- Accessibility: **PASS WITH AUTOMATED / SIMULATOR EVIDENCE**
- Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**
- Next: **WU-10 Release Gate**
- WU-10: **NOT STARTED**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 Simulators.

- XCTest: 150 tests passed, 0 failures (the accepted 142-test WU-09-02 suite plus 8 focused WU-09-03 tests).
- Specific iPhone 17 Pro Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- Production app Simulator launch smoke without sample arguments: passed.
- Twelve-screen Today visual matrix plus the owner-approved Source of Truth: passed; evidence and inspection notes are indexed in `docs/evidence/WU-09-03/README.md`.
- Japanese residual audit: app-owned primary UI, permission guidance, state copy, accessibility labels, and purpose strings are Japanese. Product/system names and source-provided calendar/event/source content remain unchanged.
- Scope audit: Production Domain, Services, Persistence, App/reliability/background orchestration, reconciliation behavior, Timeline policy, calendar selection, Settings, and Event Detail business behavior are byte-for-byte unchanged from accepted WU-09-02.

WU-09-03 applies the owner-approved Today mockup as the Production visual Source of Truth. Today now uses a compact Japanese header, stronger event-title typography, a stable time column, subtle vertical line, checked past markers, outlined future markers, exact alarm times, and a presentation-only current-time divider. Visible repeated calendar labels are removed from Today rows while VoiceOver semantics retain calendar context. Native `今日 / 予定 / 設定` tabs and whole-row Event Detail navigation remain.

The Today hierarchy is event title > event time > exact alarm time > supporting state. Its current divider is presentation-only and performs no scheduling/reconciliation action. Domain and scheduling semantics are unchanged: reconciliation remains exactly `[now, now + 14 days)`, past events never become candidates, and the separate `予定` past/future 14-day display policy is unchanged.

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
- WU-09/WU-09-02/WU-09-03 VoiceOver reading/order, touch targets, physical-device contrast, localization, and final visual acceptance.

No human item is marked passed. By explicit owner policy, intermediate Human Gates are waived and their device/UX/visual verification is deferred to WU-10. This is a schedule decision, not evidence of device behavior.
