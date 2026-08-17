# Project State

- Phase: **WU-02**
- Current Work: **Calendar Source**
- Status: **AUTOMATED GATE COMPLETE**
- Next: **WU-03 Alarm Rule Engine**
- WU-00: **AUTOMATED GATE COMPLETE; DEVICE EVIDENCE DEFERRED**
- WU-01: **AUTOMATED GATE COMPLETE**
- WU-02: **AUTOMATED GATE COMPLETE**
- WU-03: **NOT STARTED**
- Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 iPhone 17 Pro Simulator.

- XCTest: 19 tests passed, 0 failures.
- Specific iOS Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- No signed real-device or Production device behavior was executed by Codex.

WU-02 adds a read-only EventKit calendar source, framework-independent calendar/event mapping, deterministic event ordering, and persisted enabled-calendar selection. First discovery enables all available calendars; later new calendars stay disabled, while temporarily missing selected identifiers remain stored for safe restoration.

## Consolidated Human Review

- H01 iPhone AlarmKit fires.
- H02 Alarm fires in Silent Mode.
- H03 Alarm fires in Focus mode.
- H04 EventKit fetches iCloud and configured Google calendar events.
- H05 Calendar event → start date − 5 minutes → AlarmKit → actual firing.
- H06 Paired Apple Watch display / haptic behavior.
- H07 Dismiss/state behavior across Apple Watch and iPhone.

No H item is marked passed. By explicit owner policy, intermediate Human Gates are waived and their device/UX/visual verification is deferred to WU-10. This is a schedule decision, not evidence of device behavior.
