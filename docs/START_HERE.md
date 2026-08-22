# Start Here

AgendaCue is at WU-10 Release Gate Phase B.2. The accepted B.1 Production candidate has a fresh, locally validated App Store Distribution archive and IPA. H01–H46 are deferred by explicit owner policy to post-review / pre-release validation; no Human Gate item is marked passed.

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

WU-10 Phase B.2 stops with the fresh package validated and upload/submission authorization pending. Do not push, merge, tag, upload, submit, or publicly release. Manual release is preferred so H01–H46 and final owner validation can occur after approval and before public release.

## Product invariants

- iOS 26+; Swift and SwiftUI.
- Local-only, free, no ads, no IAP, no login, no backend, no analytics, no AI.
- EventKit reads existing device calendar data; app policy forbids all calendar writes.
- AlarmKit schedules alarms; there is no watchOS target in V1.
- Foreground/resume is the authoritative correctness path. Background app refresh is supplemental, best-effort, and has no timing guarantee.
- Git is the formal Project Source of Truth and portable AI memory.
