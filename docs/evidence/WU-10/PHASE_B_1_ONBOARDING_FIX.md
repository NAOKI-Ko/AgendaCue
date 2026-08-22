# WU-10 Phase B.1 — Onboarding Permission Refresh Fix

## 1. Branch

`wu-10-release-gate`

## 2. Parent SHA

`60f4f10904686b2e285d90cba8c8ee3b796a51bf`

## 3. Root cause

The onboarding model assigned the value returned by the permission request operation and immediately advanced. It did not explicitly re-read the provider's authoritative current status or refresh calendar discovery/events in the direct post-system-sheet path. Foreground activation separately refreshed state through `FoundationRootView`, explaining why a later lifecycle transition repaired the stale UI.

## 4. Files changed

- `CalendarAlarmFeasibility/Production/Features/ProductionUXModels.swift`
- `CalendarAlarmFeasibility/Production/Features/ProductionUXView.swift`
- `CalendarAlarmFeasibilityTests/ProductionUXTests.swift`
- Current release-state, checklist, Human Gate policy, and this evidence document under `docs/`

## 5. Old onboarding flow

Welcome → Calendar rationale/request → Alarm rationale/request → completion.

## 6. New onboarding flow

Calendar rationale/request → Alarm rationale/request → completion. The Welcome enum case, view branches, action, and accessibility identifier were removed.

## 7. Calendar permission behavior before

The direct request path trusted the operation's return value, did not independently query current authorization in the presentation flow, and did not reload calendars/events before advancing. A later foreground refresh could repair the observable state.

## 8. Calendar permission behavior after

Only `.notDetermined` initiates a request. After it completes, the flow reads the provider's authoritative state, publishes it on the MainActor, refreshes calendar discovery/events when authorized, and then advances to Alarm rationale. Denial/restriction remain truthful and do not trap completion.

## 9. Authoritative status refresh mechanism

`OnboardingPermissionSequence.resolve` discards the request operation's returned permission value and invokes `authoritativeState`. The live Calendar provider maps `EKEventStore.authorizationStatus(for: .event)` through its `state` property.

## 10. Calendar data refresh mechanism

`continueCalendarOnboarding()` awaits `ProductionUXViewModel.refresh()` after the authoritative status read. Authorized state performs calendar discovery, participating-calendar selection refresh, event fetch, override load, settings load, and load-state publication.

## 11. Denial behavior

Denied/restricted status is published immediately. The flow still advances to Alarm rationale; onboarding completion remains independent of authorization, and Settings recovery remains available.

## 12. Settings/foreground refresh behavior

Unchanged and verified by inspection: `FoundationRootView` reconciles and increments `refreshGeneration` on active scene transitions; `ProductionRootView` then calls `model.refresh()`, which re-reads both authorization providers and reloads Calendar data when authorized.

## 13. Alarm authorization audit result

AlarmKit request policy is unchanged: request only while `.notDetermined`. The presentation flow had the same return-value coupling, so it now performs the same authoritative provider-state reread. No AlarmKit scheduling, authorization policy, or completion semantics changed.

## 14. Focused tests

Added/updated tests cover Calendar-first initial/next stages, exactly-once request from `.notDetermined`, authoritative grant and denial after request, no request when already authorized/denied, foreground/current-status rereads, independent completion persistence, and revocation not replaying onboarding. Removed Welcome references are enforced by source compilation and a zero-result source audit.

## 15. Full XCTest result

PASS — 164 tests, 0 failures, iPhone 17 Pro Simulator (iOS 26.5), Debug.

## 16. Debug/Release build results

- Specific iPhone 17 Pro Simulator Debug: PASS as part of the full XCTest build/test action.
- Generic iOS Simulator Release: PASS.
- Generic iOS Device Release unsigned (`CODE_SIGNING_ALLOWED=NO`): PASS.
- No new compiler warnings observed.

## 17. Simulator onboarding QA

- Fresh Production Release install/launch: PASS on iPhone 17 Pro Max Simulator; first rendered screen is Calendar rationale and no Welcome page precedes it.
- Deterministic DEBUG scenario: Alarm rationale renders as screen 2.
- Deterministic DEBUG denial scenario: truthful Calendar denied status and Settings recovery render without a trap.
- Direct Apple permission-sheet interaction was not automated; immediate transition behavior is covered by focused state-flow tests and is not claimed as real-device evidence.

## 18. App Store screenshot impact

No impact. The final six-image package contains no onboarding image; operational screens were not changed and were not regenerated.

## 19. Human Gate policy status

H01–H46: **DEFERRED BY OWNER TO POST-REVIEW / PRE-RELEASE VALIDATION — NOT PASS**. It is not an App Review submission blocker under explicit owner policy. Manual release is preferred; final public release still requires owner decision.

## 20. Production scope audit

Production changes are limited to onboarding stage/presentation flow and authoritative permission refresh. EventKit remains read-only. Alarm scheduling, reconciliation rules/horizon, persistence schema, BackgroundTasks semantics, event overrides, settings, timeline, product claims, dependencies, networking, analytics, and V1 scope are unchanged.

## 21. Working tree

Clean after the single intentional implementation commit.

## 22. Push/merge/upload/submission status

NOT PUSHED. NOT MERGED. NOT UPLOADED. NOT SUBMITTED.

## 23. HARD STOP

ONBOARDING FIX VALIDATED  
READY FOR FINAL RELEASE AUDIT
