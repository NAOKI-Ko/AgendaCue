# Intended Architecture

WU-01 establishes the initial Production boundaries below. They remain intentionally small and may be extended only by the Work Unit that owns the relevant behavior.

## Modules / groups

- **App:** composition root, lifecycle signals, dependency construction, and top-level navigation.
- **Features:** SwiftUI screens and presentation state for onboarding, event selection/overrides, settings, status, and recovery.
- **Domain:** framework-light values and deterministic policies for eligibility, lead time, candidate identity, and reconciliation decisions.
- **Services/Calendar:** an EventKit adapter for authorization, read-only queries, calendar/event mapping, and change notifications.
- **Services/Alarm:** an AlarmKit adapter for authorization and app-owned alarm schedule/cancel/status operations.
- **Persistence:** local preferences, overrides, and app-managed scheduling metadata; no backend or sync service.
- **Support:** clock, logging, diagnostics, and small platform utilities.

## WU-01 foundation

- The SwiftUI app is the composition root and creates a local SwiftData `ModelContainer` plus permission providers.
- Domain types are framework-light values: calendar/source descriptors, calendar event facts, lead time, candidate identity/date, event override intent, permission state, and app settings.
- SwiftData persists only app-owned settings, selected calendar identifiers, and minimal override records. EventKit remains the Source of Truth for event content.
- EventKit and AlarmKit authorization are represented through testable protocols. Requests are explicit operations and are never triggered automatically by a view or app launch.
- The default lead time is a domain-safe five-minute value with a finite supported set.
- WU-00 scheduling/fetch feasibility code remains isolated; it is not wired into the Production root.

## Dependency direction

Views consume feature/presentation interfaces and never directly own EventKit or AlarmKit behavior. Features invoke domain policies and service protocols. EventKit and AlarmKit remain behind testable adapters. The App layer composes concrete dependencies; Domain does not depend on SwiftUI or platform service implementations.

## Design constraints

- Keep the design proportional to a small local iOS app.
- Prefer native Swift dependency construction and protocols at meaningful platform seams.
- Do not add third-party dependencies, DI frameworks, networking abstractions, backend concepts, or ceremonial Clean Architecture layers.
- Calendar service APIs expose reads only. No save/update/delete/calendar-mutation capability belongs in the interface.
- Side effects occur only in service adapters; domain candidate generation and reconciliation planning remain deterministic and unit-testable.
- Background behavior is best-effort and may not weaken foreground correctness or claim guaranteed execution.
- Full event fetching/listing is WU-02, rule evaluation is WU-03, alarm lifecycle is WU-04, reconciliation is WU-05, and Production UX is WU-07.

## WU-02 calendar source

- `CalendarSourceProviding` exposes async discovery and bounded event fetch using only domain values.
- `EventKitCalendarSource` is an actor, so synchronous `events(matching:)` work runs off the main actor and EventKit access is serialized.
- EventKit calendars are passed directly to `predicateForEvents`; disabled calendars are not fetched and filtered afterward.
- `CalendarSelectionStore` owns SwiftData selection identifiers. Initial discovery enables all; later new calendars default disabled. Missing selected calendars are ignored without deletion, so a returning calendar restores its prior enabled state.
- Missing `eventIdentifier` is preserved as `nil`; an interval-local deterministic fallback supplies `Identifiable.id`. Long-term identifier instability remains WU-03/WU-05 scope.
- Calendar source interfaces expose no write operations, permission prompts, provider APIs, or networking.

## WU-03 alarm rule engine

- `AlarmRuleEvaluating` is a pure Domain protocol; `AlarmRuleEngine` depends only on Foundation `Date` and domain values.
- Callers pass `now` and `AlarmLeadTime` explicitly. Identical inputs produce identical results.
- Results contain either a domain `AlarmCandidate` or a focused exclusion reason. Candidates contain no AlarmKit UUID, schedule state, or persistence lifecycle metadata.
- Arithmetic uses absolute instants; timezone conversion and formatting remain presentation concerns.

## WU-04 alarm scheduling

- `AlarmSystemScheduling` isolates AlarmKit; only its adapter imports AlarmKit.
- `AlarmSchedulingCoordinator` serializes operations per candidate identity and provides idempotent schedule, replace, and cancel outcomes.
- SwiftData stores only candidate identity, AlarmKit UUID, and alarm date. System success precedes persistence mutation.
- Fixed one-shot schedules and default sound are used. There is no countdown, Widget, listener, or calendar reconciliation; WU-05 owns recovery/orchestration.

## WU-05 calendar reconciliation

- `ReconciliationPlanner` is a pure deterministic diff between chronologically ordered WU-03 candidates, app-owned mappings, and actual app AlarmKit IDs.
- `CalendarReconciliationCoordinator` is an actor that serializes whole passes. A trigger received during a pass marks the coordinator dirty and guarantees a follow-up pass while coalescing bursts.
- The live composition refetches selected calendars/events on app activation and `EKEventStoreChanged`; notification payloads are not treated as event truth and no permission prompt is automatic.
- The adjustable Production default window is `[now, now + 14 days)`. Only mappings whose alarm date is inside the active window are retired for absence, preventing false deletion at window boundaries.
- Recovery reschedules a desired missing system alarm with its persisted UUID. Fired/stale mappings and app-owned AlarmKit orphans are cleaned independently; failures are isolated and reported.
- WU-05 is active-app only. BackgroundTasks and best-effort background reliability remain WU-08 scope.
