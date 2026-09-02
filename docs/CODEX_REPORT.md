# Codex Report

## WU-18 result

**PASS — IMPLEMENTATION AND PHYSICAL DEVICE PERMISSION GATE COMPLETE; CHATGPT REVIEW PENDING**

## Exact root cause

On physical iPhone 17 / iOS 26.6.1, `requestFullAccessToEvents()` returned `true` but `EKEventStore.authorizationStatus(for: .event)` remained `.notDetermined` in the current process through repeated reads and lifecycle transitions. It became `.fullAccess` after force-quit/relaunch.

Build 3 discarded the request result in both the provider and onboarding sequence, then `refresh()` overwrote the model from the stale status. Calendar onboarding advanced regardless, and Alarm onboarding unconditionally persisted completion. This created `completed=true`, Calendar nonauthorized, route main, and permissionBlocked load state.

## Fix

The provider retains the request result only while authoritative status is `.notDetermined`, performs three bounded yielded reads, and lets every conclusive OS state override the retained value. Onboarding now requires Calendar authorization before Alarm and both required authorizations before completion. Calendar source access consumes the same coherent provider state. Activation publishes permission refresh before reconciliation.

## Evidence

- Implementation Commit: `31d4cf71060e1e6e05acba6b1d2d576966046f22`
- Full XCTest: **182 passed, 0 failed, 0 skipped**.
- Debug/Release Simulator builds: PASS.
- Unsigned Debug/Release Device builds: PASS.
- PD-01 through PD-06: PASS for WU-18 scope.
- Evidence: `docs/evidence/WU-18/PHYSICAL_PERMISSION_RECOVERY.md`.

## Safety and release state

- CTA `Continue` / `続ける`: unchanged.
- Version/build: `1.0 (3)` unchanged.
- No Build 4, archive, upload, App Store Connect mutation, main merge, dependency, analytics, backend, schema, event-model, or alarm-scheduling change.
- Physical WU-18 gate is PASS; exact-SHA ChatGPT review remains required before any release packaging decision.
