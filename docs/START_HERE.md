# Start Here

Calendar Alarm is at the specification and repository-baseline stage. There is no feature implementation or implementation evidence.

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

Bootstrap establishes documentation and Git only. Do not begin WU-00, request calendar or alarm permissions, create EventKit or AlarmKit behavior, or create Production UI during bootstrap. The next authorized unit is WU-00 only after a human starts it.

## Product invariants

- iOS 26+; Swift and SwiftUI.
- Local-only, free, no ads, no IAP, no login, no backend, no analytics, no AI.
- EventKit reads existing device calendar data; app policy forbids all calendar writes.
- AlarmKit schedules alarms; there is no watchOS target in V1.
- Git is the formal Project Source of Truth and portable AI memory.
