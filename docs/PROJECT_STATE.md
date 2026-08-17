# Project State

- Phase: **WU-00**
- Current Work: **Feasibility & Platform Gate**
- Status: **AUTOMATED GATE COMPLETE**
- Next: **Human Device Gate H01–H07**
- WU-00: **AWAITING HUMAN DEVICE GATE**
- WU-01: **NOT STARTED**
- Human Gate: **PENDING**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 iPhone 17 Pro Simulator.

- XCTest: 5 tests passed, 0 failures.
- Specific iOS Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- Simulator install/launch smoke check: succeeded; the minimal feasibility screen rendered.
- No signed real-device install or AlarmKit/EventKit device behavior was executed by Codex.

The WU-00 app fetches events only through EventKit, schedules unique fixed one-shot alarms through AlarmKit, and provides a fixed five-minute event-to-alarm feasibility path. This is disposable feasibility code, not Production architecture or UI.

## Human Device Gate — PENDING

- H01 iPhone AlarmKit fires.
- H02 Alarm fires in Silent Mode.
- H03 Alarm fires in Focus mode.
- H04 EventKit fetches iCloud and configured Google calendar events.
- H05 Calendar event → start date − 5 minutes → AlarmKit → actual firing.
- H06 Paired Apple Watch display / haptic behavior.
- H07 Dismiss/state behavior across Apple Watch and iPhone.

Codex has not marked any H item passed. Stop at this gate until explicit human evidence is recorded. Do not start WU-01 and do not merge to `main`.
