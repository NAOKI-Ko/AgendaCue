# Start Here

Calendar Alarm is at WU-09-05 Lightweight Onboarding + Alarm Presentation Copy. The first-launch flow now explains and requests Calendar access before Alarm access, records completion independently of authorization outcomes, and keeps later permission recovery in the normal app. AlarmKit presentation uses the source event title verbatim, with `予定` only for blank titles.

## Reading order

1. `../AGENTS.md` — operating rules and gates.
2. `PROJECT_STATE.md` — authoritative current state and next action.
3. `PRODUCT_SPEC.md` — Production V1 promise, scope, and exclusions.
4. `DOMAIN_RULES.md` — deterministic calendar-to-alarm rules.
5. `ARCHITECTURE.md` — intended boundaries, not implemented structure.
6. `IMPLEMENTATION_PLAN.md` — exact WU sequence and gates.
7. `QA_CHECKLIST.md` — reusable verification inventory.
8. `REVIEW_LOG.md` — SHA-bound review record.

## Current stop line

WU-09-05 automated work is complete. Intermediate Human Gates are owner-waived and deferred to WU-10. The next planned unit is WU-10 Release Gate; it is not started and requires separate authorization.

## Product invariants

- iOS 26+; Swift and SwiftUI.
- Local-only, free, no ads, no IAP, no login, no backend, no analytics, no AI.
- EventKit reads existing device calendar data; app policy forbids all calendar writes.
- AlarmKit schedules alarms; there is no watchOS target in V1.
- Foreground/resume is the authoritative correctness path. Background app refresh is supplemental, best-effort, and has no timing guarantee.
- Git is the formal Project Source of Truth and portable AI memory.
