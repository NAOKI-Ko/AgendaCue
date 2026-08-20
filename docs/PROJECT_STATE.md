# Project State

- Phase: **WU-09-04**
- Current Work: **Unified Alarm Timeline + Live Time Refresh**
- Status: **AUTOMATED GATE COMPLETE**
- Unified Alarm Timeline: **IMPLEMENTED**
- Presentation Clock: **LIVE WHILE ACTIVE / SIDE-EFFECT ISOLATED**
- Visual QA: **PASS WITH EVIDENCE**
- Accessibility: **PASS WITH AUTOMATED / SIMULATOR EVIDENCE**
- Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**
- Next: **WU-10 Release Gate**
- WU-10: **NOT STARTED**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 Simulators.

- XCTest: 156 tests passed, 0 failures (the accepted 150-test WU-09-03 suite plus 6 focused WU-09-04 tests).
- Specific iPhone 17 Pro Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- Production app Simulator launch smoke without sample arguments: passed.
- Twelve-screen unified-timeline/navigation visual matrix: passed; evidence is indexed in `docs/evidence/WU-09-04/README.md`.
- Japanese residual audit: app-owned primary UI, permission guidance, state copy, accessibility labels, and purpose strings are Japanese. Product/system names and source-provided calendar/event/source content remain unchanged.
- Scope audit: Production Domain, Services, Persistence, App/reliability/background orchestration, reconciliation behavior, Timeline policy, calendar selection, Settings, and Event Detail business behavior are byte-for-byte unchanged from accepted WU-09-02.

WU-09-04 replaces the separate `今日 / 予定` destinations with one display-only `アラーム` timeline and retains `設定` as the second tab. The timeline covers past 14 days through future 14 days, groups by date, uses the owner-approved WU-09-03 row hierarchy, and keeps whole-row Event Detail navigation. Calendar names stay out of repeated visible rows but remain in conceptual accessibility labels.

The stale-time root cause was screen-local `@State Date()` values initialized once with no advancing source. A single root-owned `ProductionPresentationClock` now refreshes immediately on activation, once per minute only while active, and on existing refresh-generation signals for resume/significant time/timezone/day changes. Its tick owns no EventKit, AlarmKit, persistence, fetch, or reconciliation dependency. Domain and scheduling semantics remain unchanged: reconciliation is exactly `[now, now + 14 days)` and past events never become candidates.

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
