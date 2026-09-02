# Project State

## Current state

- Current Work Unit: **WU-18 — Physical Device Permission State Recovery**
- Status: **IMPLEMENTATION + PHYSICAL DEVICE GATE PASS — CHATGPT REVIEW PENDING**
- Branch: `wu-18-physical-permission-recovery`
- Baseline / unchanged `main`: `6b75fb90a2c153e34fcc6fe5f307c2558eb5383b`
- Build 3 Source SHA: `620296af562afd37eda7a59263371c51cd64b046`
- WU-18 Implementation Commit: `31d4cf71060e1e6e05acba6b1d2d576966046f22`
- State Snapshot: this docs-only commit
- App Store Version/Build: **1.0 (3)** unchanged
- Build 4: **NOT CREATED**
- App Store Connect: **NOT TOUCHED**
- Public Release: **NOT COMPLETED**

## Confirmed root cause

Physical iPhone logs confirmed that `requestFullAccessToEvents()` returned `true` while the same-process static EventKit authorization status remained `.notDetermined` until process relaunch. Build 3 discarded the request result twice, refreshed from the stale raw state, advanced to Alarm, and persisted onboarding completion without valid Calendar state. This produced `onboardingCompleted=true` plus `calendarPermission != .authorized`, exactly matching the observed Calendar recovery screen.

## WU-18 implementation

- Retains the EventKit request outcome during the same-process `.notDetermined` lag.
- Uses a maximum of three yielded authoritative reads; no sleep or infinite polling.
- Lets later conclusive OS authorization override the retained result.
- Gives `EventKitCalendarSource` the same coherent permission provider.
- Enforces Calendar-authorized-before-Alarm and Calendar+Alarm-authorized-before-completion invariants.
- Publishes activation permission refresh before reconciliation.
- Adds DEBUG/internal state diagnostics without user/calendar content.

## Verification

- Focused permission/onboarding XCTest: PASS.
- Complete XCTest: **PASS — 182 passed, 0 failed, 0 skipped**.
- Debug Simulator: PASS.
- Release Simulator: PASS.
- Unsigned Device Debug: PASS.
- Unsigned Device Release: PASS.
- Physical iPhone 17 / iOS 26.6.1: PD-01, PD-02, PD-03, PD-04, PD-05, PD-06 PASS as recorded in `docs/evidence/WU-18/PHYSICAL_PERMISSION_RECOVERY.md`.
- Physical Device Gate: **PASS for WU-18 permission recovery scope**.

## Next action

Push the exact WU-18 State Snapshot, prove local/remote equality and 0/0 ahead/behind, then stop for ChatGPT review. Do not merge, create Build 4, archive, upload, or mutate App Store Connect.
