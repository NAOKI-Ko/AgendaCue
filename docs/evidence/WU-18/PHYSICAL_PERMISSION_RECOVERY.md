# WU-18 — Physical Device Permission State Recovery

Date: 2026-09-02 (Asia/Tokyo)

## Exact target

- Branch: `wu-18-physical-permission-recovery`
- Baseline: `6b75fb90a2c153e34fcc6fe5f307c2558eb5383b`
- Implementation Commit: `31d4cf71060e1e6e05acba6b1d2d576966046f22`
- Version/build: `1.0 (3)` unchanged
- Device: physical iPhone 17, iOS 26.6.1
- Production bundle: `com.naoki-ko.agendacue`

## Confirmed root cause

**MULTIPLE CONFIRMED CONTRIBUTING CAUSES**

On a fresh diagnostic bundle containing the unchanged pre-fix production flow, EventKit returned `granted=true` from `requestFullAccessToEvents()`, while `EKEventStore.authorizationStatus(for: .event)` continued to return `.notDetermined` in the same process. The stale raw value persisted through the request completion, repeated provider reads, the immediate model refresh, active lifecycle refreshes, and a Settings/background/foreground cycle. Force-quit and relaunch changed the raw state to `.fullAccess`.

The production flow discarded the successful request result twice, overwrote the model from the stale raw state, advanced to Alarm onboarding without Calendar authorization, and unconditionally persisted onboarding completion. The captured invalid state was:

```text
raw EventKit = notDetermined
calendarPermission = notDetermined
alarmPermission = authorized
onboardingCompleted = true
route = main
loadState = permissionBlocked
```

This exactly derives the reported Calendar recovery screen while iOS Settings reports Full Access.

## Fix contract

- Retain the EventKit request result.
- Perform at most three immediate authoritative reads with `Task.yield()` between reads.
- While the authoritative result remains `.notDetermined`, retain the current-session request result.
- A later conclusive OS state (`.fullAccess`, `.denied`, `.restricted`, `.writeOnly`, or unknown/unavailable mapping) overrides the retained request result.
- Use the same coherent provider state for EventKit source access.
- Do not advance Calendar onboarding unless Calendar is `.authorized`.
- Do not persist onboarding completion unless Calendar and Alarm are both `.authorized`.
- On activation, publish a permission UI refresh generation before reconciliation.

The strategy is bounded, contains no sleep, and cannot poll indefinitely.

## Physical-device matrix

| Case | Result | Evidence |
|---|---|---|
| PD-01 fresh install / Full Access | PASS | Fresh WU-18 diagnostic identity began at raw/model `.notDetermined`; after owner Full Access action, the fixed flow reached Calendar `.authorized` without the recovery trap. |
| PD-02 Calendar → Alarm → Main | PASS | Owner allowed Calendar and Alarm; fixed fresh flow reached Calendar/Alarm `.authorized`, `onboardingCompleted=true`, route `.main`. |
| PD-03 permission-sheet lifecycle | PASS | Pre-fix trace captured inactive/active and persistent raw `.notDetermined`; fixed lifecycle preserved `.authorized` and refreshed permission UI before reconciliation. |
| PD-04 Deny → Settings → Full Access | PASS | Owner executed the complete sequence on exact Implementation Commit. Final foreground trace: raw `.fullAccess`, provider/model `.authorized`, route `.main`, load `.content`. |
| PD-05 force quit / relaunch | PASS | Relaunch with Full Access initialized raw `.fullAccess`, model `.authorized`, route `.main`; exact production bundle also launched in this state. |
| PD-06 original contradiction | PASS (pre-fix reproduced; post-fix not reproduced) | Pre-fix invalid combination was logged exactly. After the fix, fresh completion and Settings recovery reached Main without Calendar recovery. |

Physical-device release-critical minimum: **PASS** (`PD-01`, `PD-02`, `PD-04`, `PD-05`).

## Diagnostic privacy

DEBUG-only unified/console logging records permission and lifecycle state only. It does not record event titles, calendar contents, calendar identifiers, user identifiers, analytics, networking, or backend data.

## Automated evidence

- Focused `ProductionUXTests`: PASS.
- Full XCTest: **182 passed, 0 failed, 0 skipped** on iPhone 17 Pro Simulator, iOS 26.5.
- Debug Simulator build: PASS.
- Release Simulator build: PASS.
- Unsigned generic Device Debug build: PASS.
- Unsigned generic Device Release build: PASS.
- Signed physical-device Debug build/install/launch for exact Implementation Commit: PASS.

## Deviations

- iOS retained the production bundle's TCC and onboarding state after uninstall/reinstall. Fresh TCC runs therefore used temporary diagnostic bundle identifiers signed by the existing wildcard development profile, with identical source and no project-file or developer-portal mutation.
- A final extra fresh trace identity was left at `.notDetermined` because no additional owner interaction occurred; it was not used as PASS evidence.
- Three temporary diagnostic apps were removed after testing. The production WU-18 Debug app remains installed.
- Initial CoreData creation emitted transient first-launch diagnostics and recovered successfully; it was unrelated to permission behavior.

## Scope audit

Unchanged: permission CTA copy, Alarm scheduling, reconciliation rules except activation ordering, event models, default lead time, persistence schema, metadata, version/build, App Store Connect, archive, upload, and Build 4.

