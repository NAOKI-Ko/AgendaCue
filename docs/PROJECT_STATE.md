# Project State

- Phase: **WU-08**
- Current Work: **Reliability**
- Status: **AUTOMATED GATE COMPLETE**
- Next: **WU-09 Accessibility & Polish**
- WU-00: **AUTOMATED GATE COMPLETE; DEVICE EVIDENCE DEFERRED**
- WU-01: **AUTOMATED GATE COMPLETE**
- WU-02: **AUTOMATED GATE COMPLETE**
- WU-03: **AUTOMATED GATE COMPLETE**
- WU-04: **AUTOMATED GATE COMPLETE**
- WU-05: **AUTOMATED GATE COMPLETE**
- WU-06: **AUTOMATED GATE COMPLETE**
- WU-07: **AUTOMATED GATE COMPLETE**
- WU-08: **AUTOMATED GATE COMPLETE**
- WU-09: **NOT STARTED**
- Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 iPhone 17 Pro Simulator.

- XCTest: 111 tests passed, 0 failures (98 retained plus 13 WU-08 reliability tests).
- Specific iOS Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device build with code signing disabled: succeeded.
- No signed real-device or Production device behavior was executed by Codex.

WU-08 keeps foreground/resume reconciliation as the authoritative recovery path and adds a short, best-effort `BGAppRefreshTask` using `com.example.CalendarAlarmFeasibility.refresh`. Initial/active, EventKit change, override/default/calendar mutation, significant day/time/time-zone change, and background opportunities all converge through the existing WU-05 coordinator. The background request uses a conservative six-hour earliest-begin policy; iOS decides whether and when it runs.

Permission denial blocks convergence without treating inaccessible data as deletion. Restoration is recovered by the next foreground/trigger pass. Missing/fired system alarms, stale mappings, selected calendar disappearance/reappearance, capacity failures, trigger coalescing, a fresh 14-day horizon, and conservative event identity behavior remain covered by the combined regression suite.

- Production UI Simulator launch smoke: **PASS**.
- Background orchestration/configuration: **PASS in unit/static verification**; actual system-scheduled execution timing was not tested on a real device.
- Background expiration cancels the Swift task and reports failure. An individual EventKit/AlarmKit platform call already in flight may not be atomically interrupted; reconciliation stops before subsequent independent operations and remains safe to retry.
- WU-07 Visual QA remains recorded under `docs/evidence/WU-07`; WU-08 made no visual redesign.

## Consolidated Human Review

- H01 iPhone AlarmKit fires.
- H02 Alarm fires in Silent Mode.
- H03 Alarm fires in Focus mode.
- H04 EventKit fetches iCloud and configured Google calendar events.
- H05 Calendar event → start date − 5 minutes → AlarmKit → actual firing.
- H06 Paired Apple Watch display / haptic behavior.
- H07 Dismiss/state behavior across Apple Watch and iPhone.

No H item is marked passed. By explicit owner policy, intermediate Human Gates are waived and their device/UX/visual verification is deferred to WU-10. This is a schedule decision, not evidence of device behavior.
