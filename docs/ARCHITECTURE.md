# Intended Architecture

This document defines boundaries only. No boundary is implemented by the bootstrap.

## Modules / groups

- **App:** composition root, lifecycle signals, dependency construction, and top-level navigation.
- **Features:** SwiftUI screens and presentation state for onboarding, event selection/overrides, settings, status, and recovery.
- **Domain:** framework-light values and deterministic policies for eligibility, lead time, candidate identity, and reconciliation decisions.
- **Services/Calendar:** an EventKit adapter for authorization, read-only queries, calendar/event mapping, and change notifications.
- **Services/Alarm:** an AlarmKit adapter for authorization and app-owned alarm schedule/cancel/status operations.
- **Persistence:** local preferences, overrides, and app-managed scheduling metadata; no backend or sync service.
- **Support:** clock, logging, diagnostics, and small platform utilities.

## Dependency direction

Views consume feature/presentation interfaces and never directly own EventKit or AlarmKit behavior. Features invoke domain policies and service protocols. EventKit and AlarmKit remain behind testable adapters. The App layer composes concrete dependencies; Domain does not depend on SwiftUI or platform service implementations.

## Design constraints

- Keep the design proportional to a small local iOS app.
- Prefer native Swift dependency construction and protocols at meaningful platform seams.
- Do not add third-party dependencies, DI frameworks, networking abstractions, backend concepts, or ceremonial Clean Architecture layers.
- Calendar service APIs expose reads only. No save/update/delete/calendar-mutation capability belongs in the interface.
- Side effects occur only in service adapters; domain candidate generation and reconciliation planning remain deterministic and unit-testable.
- Background behavior is best-effort and may not weaken foreground correctness or claim guaranteed execution.
