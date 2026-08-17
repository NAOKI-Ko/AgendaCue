# Project State

- Phase: **WU-07**
- Current Work: **Production UX**
- Status: **AUTOMATED GATE COMPLETE**
- Next: **WU-08 Reliability**
- WU-00: **AUTOMATED GATE COMPLETE; DEVICE EVIDENCE DEFERRED**
- WU-01: **AUTOMATED GATE COMPLETE**
- WU-02: **AUTOMATED GATE COMPLETE**
- WU-03: **AUTOMATED GATE COMPLETE**
- WU-04: **AUTOMATED GATE COMPLETE**
- WU-05: **AUTOMATED GATE COMPLETE**
- WU-06: **AUTOMATED GATE COMPLETE**
- WU-07: **AUTOMATED GATE COMPLETE**
- WU-08: **NOT STARTED**
- Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 iPhone 17 Pro Simulator.

- XCTest: 98 tests passed, 0 failures.
- Specific iOS Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- No signed real-device or Production device behavior was executed by Codex.

WU-07 replaces the placeholder root with compact permission onboarding and native Today, Upcoming, and Settings navigation. Event overrides, calendar participation, and default lead-time mutations use the existing Production services and reconciliation path. Simulator Visual QA covers 11 light/dark and state variants under `docs/evidence/WU-07`.

- Visual QA: **PASS WITH EVIDENCE** (Codex simulator inspection; not Human Gate evidence).

## Consolidated Human Review

- H01 iPhone AlarmKit fires.
- H02 Alarm fires in Silent Mode.
- H03 Alarm fires in Focus mode.
- H04 EventKit fetches iCloud and configured Google calendar events.
- H05 Calendar event → start date − 5 minutes → AlarmKit → actual firing.
- H06 Paired Apple Watch display / haptic behavior.
- H07 Dismiss/state behavior across Apple Watch and iPhone.

No H item is marked passed. By explicit owner policy, intermediate Human Gates are waived and their device/UX/visual verification is deferred to WU-10. This is a schedule decision, not evidence of device behavior.
