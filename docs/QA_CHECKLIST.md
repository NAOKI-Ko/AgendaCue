# QA Checklist

Apply only the sections relevant to the active WU and record actual evidence against an exact commit SHA.

## Scope and Source of Truth

- Active WU, branch, SHA, scope, exclusions, and gates are identified.
- `START_HERE`, `PROJECT_STATE`, and relevant specs agree.
- No parked feature, calendar write path, watchOS target, backend, analytics, AI, monetization, or third-party dependency slipped in.

## Automated quality

- Generic iOS build succeeds when the project and toolchain make it possible.
- Unit tests cover deterministic domain boundaries, negative cases, time boundaries, duplicates, and idempotency.
- Tests use controlled clocks/timezones where time affects results.
- Static warnings and failures are reported; no result is fabricated.

## Calendar safety and correctness

- Current EventKit read authorization API and denial/revocation paths are verified.
- No calendar save, update, delete, or calendar mutation API is reachable.
- Selected/unselected calendars, all-day defaults, recurring occurrences, changes, deletions, identifier instability, timezones, DST, and day boundaries are covered.

## Alarm correctness

- AlarmKit authorization states are handled.
- Alarm date equals event start minus effective lead time.
- Duplicate prevention, stale cleanup, changed schedule replacement, past dates, and partial failures are covered.
- UI never claims an alarm is scheduled without system-backed evidence.
- Reconciliation covers new/changed/deleted/ineligible events, missing-system recovery, fired/stale mapping cleanup, orphan cancellation, partial capacity, permission revocation, idempotency, and window-boundary ownership.
- Foreground/resume and `EKEventStoreChanged` triggers refetch fresh events; overlapping triggers serialize and a change during a pass causes a follow-up pass.
- Calendar-day, significant-clock/DST, and system-time-zone signals use the same reconciliation path and refresh Today/Upcoming state without manual timezone arithmetic or polling timers.
- Override precedence, reset/inherit, supported custom leads, base eligibility, persistence failure, permission blocks, reconciliation replacement/cancellation, identity isolation, and out-of-window preservation are regression-tested.
- Permission revocation never converts inaccessible EventKit truth into deletion; restoration, missing/reappearing calendars, fired/missing alarms, long-gap windows, capacity retry, orphan cleanup, and nil-identifier safety are regression-tested.

## Background reliability

- The Production app registers exactly one short app-refresh handler with the configured permitted identifier and only the `fetch` background mode.
- Repeated request scheduling replaces the one logical pending request; the conservative earliest-begin date is not represented as a guarantee.
- Background execution invokes the existing reconciliation coordinator, schedules its successor, issues no permission prompt/UI, and truthfully reports blocked/partial/cancelled work.
- Expiration cancellation and duplicate completion protection are tested. Foreground remains operational after registration/submission failure.
- Unit/debug orchestration evidence is distinguished from real-device system-scheduled execution timing, which belongs to WU-10.

## UX and accessibility

- Onboarding, Settings, empty/loading/error/recovery states, and permission changes are exercised.
- Dynamic Type, VoiceOver labels/order, contrast, touch targets, Reduce Motion where applicable, and localization-ready text are checked.
- Visual QA is captured for affected Production UI across relevant device sizes and appearance modes.
- WU-07 evidence covers onboarding, populated/empty Today, Upcoming, default/custom/OFF detail, calendar selection, Settings, denied guidance, and dark mode without exposing internal identifiers or feasibility controls.
- WU-09 evidence covers 20 Simulator states across onboarding, Today, multi-date Upcoming grouping, detail default/custom/OFF, calendars, Settings, denied recovery, empty/error, light/dark appearances, long content, small/large devices, and accessibility Dynamic Type sizes.
- WU-09-02 evidence covers 24 fresh Simulator states for Japanese onboarding, `今日`, display-only `予定`, default/custom/OFF/past details, calendar selection, Settings, recovery/error, long content, light/dark appearances, small/large devices, and Accessibility XXXL.
- App-owned Production copy is Japanese-first. iOS system UI follows the device language, while calendar/event/source names are rendered as source-provided data without translation.
- The `予定` display window includes the previous 14 days and next 14 days, remains chronological and read-only, starts at the current boundary/first future event, and exposes `現在へ`. It must not broaden the reconciliation window or schedule past alarms.
- Core controls have stable semantic accessibility identifiers; event rows expose one conceptual title/start/calendar/alarm label; alarm OFF and recovery meaning are not communicated by color alone.
- Accessibility Inspector and real VoiceOver reading/order remain explicit WU-10 human/device checks; Simulator screenshots and unit/static assertions do not substitute for them.

## Human/device and release

- Required device scenarios are executed by a human and evidence is attached.
- Human Device Gate remains PENDING until explicit human confirmation.
- Privacy descriptions/disclosures match behavior; App Store metadata, icons, screenshots, signing, archive, and release checklist are complete in WU-10.
- Review targets the exact SHA and merge occurs only after all applicable gates pass.
