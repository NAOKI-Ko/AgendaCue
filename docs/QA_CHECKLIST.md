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

## UX and accessibility

- Onboarding, Settings, empty/loading/error/recovery states, and permission changes are exercised.
- Dynamic Type, VoiceOver labels/order, contrast, touch targets, Reduce Motion where applicable, and localization-ready text are checked.
- Visual QA is captured for affected Production UI across relevant device sizes and appearance modes.

## Human/device and release

- Required device scenarios are executed by a human and evidence is attached.
- Human Device Gate remains PENDING until explicit human confirmation.
- Privacy descriptions/disclosures match behavior; App Store metadata, icons, screenshots, signing, archive, and release checklist are complete in WU-10.
- Review targets the exact SHA and merge occurs only after all applicable gates pass.
