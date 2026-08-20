# Project State

- Phase: **WU-09-05**
- Current Work: **Lightweight Onboarding + Alarm Presentation Copy**
- Status: **AUTOMATED GATE COMPLETE**
- Lightweight Onboarding: **IMPLEMENTED**
- Alarm Presentation Copy: **EVENT TITLE / BLANK FALLBACK `予定`**
- Visual QA: **PASS WITH EVIDENCE**
- Accessibility: **PASS WITH AUTOMATED / SIMULATOR EVIDENCE**
- Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**
- Next: **WU-10 Release Gate**
- WU-10: **NOT STARTED**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 Simulators.

- XCTest: 160 tests passed, 0 failures (the accepted 156-test WU-09-04 suite plus 4 focused WU-09-05 tests).
- Specific iPhone 17 Pro Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- Production app Simulator launch smoke without sample arguments: passed.
- Twelve-screen onboarding/permission/recovery/navigation visual matrix: passed; evidence is indexed in `docs/evidence/WU-09-05/README.md`.
- Japanese residual audit: app-owned primary UI, permission guidance, state copy, accessibility labels, and purpose strings are Japanese. Product/system names and source-provided calendar/event/source content remain unchanged.
- Scope audit: scheduling dates/identities/lifecycle, reconciliation, background orchestration, domain rules, calendar write prohibition, timeline, settings, and event-detail business behavior are unchanged. Only first-launch presentation state, its local completion flag, permission request sequencing, and AlarmKit title presentation changed.

WU-09-05 provides three lightweight first-launch steps: welcome, Calendar rationale/request, and Alarm rationale/request. Each request is made only while authorization is not determined. Denial still permits completion; completion persists independently of permission state, so later revocation does not replay onboarding. Completed users see the existing inline/System Settings recovery path.

AlarmKit presentation receives the unmodified nonblank source event title. Blank or whitespace-only titles use the Japanese fallback `予定`. Alarm date, stable identity, generated UUID, lifecycle, reconciliation, and capacity behavior are unchanged.

Accessibility Inspector and real VoiceOver navigation were not automated. Signed real-device permission prompts, denial/restoration, AlarmKit system presentation, physical touch/contrast review, final human visual acceptance, release assets/metadata, and actual system-scheduled background execution remain WU-10 work. The pre-existing Swift concurrency warning in `EventOverrideService.swift` remains visible and was not changed.

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
