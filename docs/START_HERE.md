# Start Here

AgendaCue is a local-only iOS 26+ SwiftUI app that reads selected device calendars through EventKit and schedules prominent alarms through AlarmKit. It does not write calendar data and has no account, backend, analytics, advertising, or in-app purchases.

## Current release state

- Current Work Unit: **WU-18 — Physical Device Permission State Recovery**.
- Branch: `wu-18-physical-permission-recovery`.
- WU-18 baseline `main`: `6b75fb90a2c153e34fcc6fe5f307c2558eb5383b`.
- Build 3 source: `620296af562afd37eda7a59263371c51cd64b046`.
- WU-18 Implementation Commit: `31d4cf71060e1e6e05acba6b1d2d576966046f22`.
- Reviewed State Snapshot: `9ec89202408dd153c8eff398933f33f97efd24aa`.
- WU-18 status: **PASS / REVIEWED**.
- Current app: **PUBLICLY RELEASED**.
- WU-18 fix/update release: **NOT YET RELEASED**.
- Version/build remains **1.0 (3)**.
- Build 4, archive, upload, and App Store Connect changes: **NOT PERFORMED**.

## Incident and resolution

Build 3 failed the physical Calendar permission gate on iPhone 17 / iOS 26.6.1. The OS showed Full Access while the app produced the Calendar recovery route. WU-18 diagnostics reproduced and confirmed the exact cause: EventKit returned a successful request result while the same-process static authorization status remained `.notDetermined`; Build 3 discarded the successful result, advanced onboarding, and persisted an invalid completion state.

WU-18 retains the bounded request outcome until EventKit publishes a conclusive state, applies explicit onboarding invariants, and refreshes permission UI before reconciliation on activation. Later OS denial/restriction always overrides the retained outcome.

## Gates

- XCTest: **182/182 PASS**.
- Debug/Release Simulator: PASS.
- Unsigned Debug/Release Device: PASS.
- Physical PD-01 through PD-06: PASS for the WU-18 permission scope.
- Physical Device Gate: **PASS**.
- ChatGPT exact-SHA review: **PASS**.

## Reading order

1. `../AGENTS.md`
2. `PROJECT_STATE.md`
3. `PRODUCT_SPEC.md`
4. `DOMAIN_RULES.md`
5. `ARCHITECTURE.md`
6. `IMPLEMENTATION_PLAN.md`
7. `QA_CHECKLIST.md`
8. `REVIEW_LOG.md`
9. `CODEX_REPORT.md`
10. `evidence/WU-18/PHYSICAL_PERMISSION_RECOVERY.md`

## Stop line

After the docs-only Review Sync and fast-forward-only `main` closure are pushed and equality is verified, stop. Do not create Build 4, change version/build, archive, upload, or touch App Store Connect. The current app is already public; the WU-18 fix is not yet released.
