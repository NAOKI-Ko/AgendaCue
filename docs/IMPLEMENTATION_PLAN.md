# Production V1 Implementation Plan

Sequence is mandatory: Spec → Work Unit → Scope Gate → Implementation → Build → Unit Test → Visual QA when applicable → Evidence → Report → Human Gate → Review / Merge. Each post-bootstrap WU uses one branch and one PR. A stop condition ends the WU; it does not authorize the next one.

## WU-00 Feasibility & Platform Gate

- **Goal:** Prove on iOS 26 and real hardware that the minimum read-event-to-prominent-alarm path and native paired-Watch behavior are feasible before Production architecture or UI.
- **Scope:** A disposable/minimal feasibility slice; verify current EventKit fetch authorization/API, read events from device calendars, current AlarmKit authorization and fixed one-shot scheduling, a simple event-start-minus-lead-time path, alarm lifecycle observation, and device evidence H01–H07.
- **Out of Scope:** Production UI/onboarding/settings, durable domain/persistence architecture, background reconciliation, broad polish, release work, calendar writes, and a watchOS target.
- **Automated Gate:** Compile the feasibility target with the pinned Xcode/iOS 26 SDK; focused tests for alarm-date arithmetic where practical; record SDK/API findings and exact SHA.
- **Human Gate:** H01 iPhone AlarmKit fires; H02 Silent Mode; H03 Focus mode; H04 iCloud / Google calendar event fetch through EventKit; H05 Calendar event → lead time → AlarmKit firing; H06 paired Apple Watch display / haptic behavior; H07 dismiss/state behavior across Watch and iPhone.
- **Expected evidence:** Build/test logs, device/OS/Watch versions, permission states, timestamps or recordings/screenshots where appropriate, observed results for every H item, and platform limitations/decisions.
- **Stop condition:** Stop with the Human Device Gate PENDING until explicit human evidence covers H01–H07. If any essential capability fails or is ambiguous, do not start Production work; escalate the feasibility decision.

## WU-01 Product Foundation

- **Goal:** Establish a compile-safe Production app skeleton and test targets with proportional dependency boundaries.
- **Scope:** Xcode project/app identifiers, SwiftUI app shell, composition root, folder/module groups, native dependency wiring, basic navigation placeholders, test infrastructure, build settings, and required privacy-description placeholders based on verified APIs.
- **Out of Scope:** Event fetching, alarm scheduling, Production onboarding flows, persistence behavior, reconciliation, and visual polish.
- **Automated Gate:** Generic iOS build and unit-test target pass without signing/device assumptions; no third-party dependencies or platform service calls from views.
- **Human Gate:** None unless signing/team configuration requires a human decision.
- **Expected evidence:** Project tree, build/test commands and logs, exact SHA, and architecture conformance note.
- **Stop condition:** Stop if WU-00 has not passed explicitly, project ownership/signing assumptions are unresolved, or the foundation requires out-of-scope feature code.

## WU-02 Calendar Source

- **Goal:** Provide a read-only, testable source of selected calendars and event occurrences.
- **Scope:** Current EventKit full-access request/status handling, read-only adapter, calendar listing/selection model, bounded occurrence queries, change notification surface, mapping, errors, and test doubles.
- **Out of Scope:** Any EventKit write, alarm rules/scheduling, reconciliation orchestration, Production event override UI, and background execution.
- **Automated Gate:** Build/tests for authorization states, query bounds/overlap, mapping, selected calendars, errors, and proof that the calendar service interface exposes no mutations.
- **Human Gate:** Targeted device confirmation only if verified WU-00 behavior cannot be reproduced in the Production target automatically.
- **Expected evidence:** API/interface review, unit-test/build logs, sample redacted device fetch evidence if applicable, and exact SHA.
- **Stop condition:** Stop on API ambiguity, any need for calendar mutation, or inability to demonstrate read-only behavior.

## WU-03 Alarm Rule Engine

- **Goal:** Implement deterministic, framework-light conversion from event facts and rules to alarm candidates.
- **Scope:** Eligibility/exclusion, default lead time, all-day default exclusion, event ON/OFF and lead-time inputs, fixed alarm-date arithmetic, past-date handling, occurrence-aware duplicate identity strategy, timezone/DST boundaries, and reconciliation-plan values without side effects.
- **Out of Scope:** AlarmKit calls, EventKit calls, persistence adapters, Production UI, and background execution.
- **Automated Gate:** Exhaustive unit tests with injected clock for defaults/overrides, past/boundary dates, recurring occurrences, identity/idempotency, DST/timezone/day-window cases, and invalid inputs.
- **Human Gate:** None.
- **Expected evidence:** Domain decision table, tests/build logs, coverage of negative/boundary cases, and exact SHA.
- **Stop condition:** Stop if identifier or time semantics cannot be made deterministic from WU-00/WU-02 findings; update the relevant spec through human review first.

## WU-04 Alarm Scheduling

- **Goal:** Safely translate alarm candidates into app-owned AlarmKit lifecycle operations.
- **Scope:** Current AlarmKit authorization/status adapter, fixed one-shot schedule/cancel/status operations, managed identifiers, idempotency, duplicate prevention, partial-failure reporting, test doubles, and truthful schedule state.
- **Out of Scope:** Calendar querying, full reconciliation triggers, event override UX, background refresh, custom sound product system, or advanced snooze design.
- **Automated Gate:** Build/tests for authorization states, create/no-op/replace/cancel, duplicates, stale IDs, failures, and view/service boundary enforcement.
- **Human Gate:** Human device smoke test that a Production-target test alarm fires and can be dismissed; this supplements and does not replace WU-00 evidence.
- **Expected evidence:** Unit/build logs, device details and explicit human result, managed-alarm lifecycle trace, and exact SHA.
- **Stop condition:** Stop at the device gate or upon any mismatch between local claimed state and AlarmKit system state.

## WU-05 Calendar Reconciliation

- **Goal:** Keep app-managed alarms consistent with added, changed, and deleted calendar occurrences.
- **Scope:** Foreground reconciliation, `EKEventStore` change handling, deterministic diff/planning, safe ordering, stale cleanup, identifier-remapping tolerance, query horizon/overlap, retry/error state, and persisted reconciliation metadata.
- **Out of Scope:** Best-effort background execution, event override editing UI, onboarding polish, analytics, or guaranteed OS execution claims.
- **Automated Gate:** Build/integration tests for added/changed/deleted events, repeated no-op runs, duplicates, partial schedule/cancel failures, store changes, revocation, recurrence, timezone/day-boundary overlap, and crash-safe recovery.
- **Human Gate:** Device scenario changing and deleting a real event while observing resulting alarms, with explicit human evidence.
- **Expected evidence:** Before/after reconciliation traces without private calendar content, tests/build logs, device result, failure/retry analysis, and exact SHA.
- **Stop condition:** Stop if reconciliation can duplicate alarms, retain unsafe stale alarms, mutate calendars, or claim freshness after failed/revoked reads.

## WU-06 Event Overrides

- **Goal:** Add durable, local per-event alarm ON/OFF and lead-time overrides with predictable behavior across reconciliation.
- **Scope:** Override persistence/model, occurrence/event identity policy based on earlier findings, UI for eligible event overrides, default fallback, orphan cleanup policy, and reconciliation integration.
- **Out of Scope:** Multiple alarms per event, keyword automation, AI classification, travel/location rules, backend sync, or broad Production polish.
- **Automated Gate:** Build/tests for create/edit/remove override, defaults, recurring identity behavior, identifier changes, persistence migration, orphan handling, and reconciliation effects.
- **Human Gate:** Human UX/device check for changing an override and observing the resulting scheduled-alarm change.
- **Expected evidence:** Tests/build logs, visual QA for changed screens, explicit device result, persistence schema/identity note, and exact SHA.
- **Stop condition:** Stop if overrides can bind unpredictably to the wrong occurrence/event or cannot safely recover from identifier instability.

## WU-07 Production UX

- **Goal:** Deliver complete, truthful Production onboarding, Settings, calendar/event controls, and recovery states.
- **Scope:** Onboarding, permission education and recovery, participating-calendar selection, default lead-time settings, event status/override access, alarm status, empty/loading/error states, and coherent navigation/content.
- **Out of Scope:** New domain capabilities, background reliability work, widgets/watchOS, advanced accessibility polish reserved for WU-09, monetization, or release submission.
- **Automated Gate:** Build/tests for presentation state and navigation across authorization/data/error combinations; snapshot/UI tests where stable and useful.
- **Human Gate:** Human walkthrough on representative device sizes covering first run, denied/revoked recovery, settings, empty/error states, and the primary promise.
- **Expected evidence:** Build/test logs, visual QA screenshots, accessibility baseline notes, walkthrough result, and exact SHA.
- **Stop condition:** Stop if UI overstates permission/alarm status, hides recovery, or requires scope expansion to proceed.

## WU-08 Reliability

- **Goal:** Harden lifecycle behavior and add platform-permitted best-effort background reconciliation without promising guaranteed delivery.
- **Scope:** Lifecycle triggers, best-effort background task strategy verified against current APIs, retry/backoff where appropriate, interruption recovery, persisted operation state, cleanup, diagnostics/logging without analytics, and stress/failure testing.
- **Out of Scope:** Backend push/sync, accounts, analytics, guaranteed background execution, unrelated performance rewrites, or new product features.
- **Automated Gate:** Build/tests for interrupted/duplicate/concurrent reconciliation, background expiration, revocation, partial failures, app relaunch, store changes, clock/timezone changes, and bounded resource use.
- **Human Gate:** Multi-cycle real-device reliability check including background opportunity, foreground recovery, restart, and permission changes; observations must distinguish OS behavior from guarantees.
- **Expected evidence:** Test/build logs, device timeline and OS conditions, diagnostic excerpts without private data, known limitations, and exact SHA.
- **Stop condition:** Stop if reliability mechanisms risk duplicate/stale alarms, data corruption, excessive battery use, or claims stronger than iOS permits.

## WU-09 Accessibility & Polish

- **Goal:** Make all V1 user journeys accessible, visually consistent, and ready for final release validation.
- **Scope:** Dynamic Type, VoiceOver labels/order/traits, contrast, touch targets, Reduce Motion, localization-ready strings, appearance/device-size layouts, copy consistency, icons/assets, and final empty/error-state polish.
- **Out of Scope:** New functionality, widgets, watchOS target, custom sound system, analytics, monetization, or architecture expansion.
- **Automated Gate:** Build/tests plus available accessibility/UI checks; no truncation or layout failures in tested text sizes/locales.
- **Human Gate:** Human VoiceOver and large-text walkthrough plus visual QA across representative devices, light/dark appearance, and relevant states.
- **Expected evidence:** Screenshot matrix, accessibility audit, build/test logs, explicit human findings/resolution, and exact SHA.
- **Stop condition:** Stop with unresolved critical accessibility defects, misleading copy, or visual regressions in primary journeys.

## WU-10 Release Gate

- **Goal:** Establish evidence that the exact release candidate is App Store ready and obtain final human approval.
- **Scope:** Release configuration/signing, archive, privacy manifest/descriptions, App Store metadata/assets/checklists, clean install/upgrade where applicable, regression suite, final real-device matrix, known limitations, review of all V1 requirements/exclusions, and release SHA/tag preparation.
- **Out of Scope:** Any new product capability, parked V1.1+ item, speculative refactor, backend, analytics, accounts, or monetization.
- **Automated Gate:** Clean Release build/archive and full applicable test suite for the exact candidate SHA; repository clean; review findings resolved or explicitly accepted.
- **Human Gate:** Final human acceptance of primary promise, permissions/recovery, alarm behavior, accessibility, privacy/App Store materials, known risks, and go/no-go for submission/merge.
- **Expected evidence:** Exact candidate SHA, archive/build/test logs, device/visual/accessibility matrices, privacy and metadata checklist, review record, and explicit human decision.
- **Stop condition:** Stop before submission/merge/tag if any required automated gate fails, evidence is stale for the SHA, or explicit human go is absent.
