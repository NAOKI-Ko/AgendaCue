# WU-09-04 Automated Evidence

Target branch: `wu-09-04-unified-alarm-timeline-live-clock`  
Accepted base: `3e6f19b399e1e15c5b9c03cf4ba5987a65936024`

## Result

- XCTest: 156 passed, 0 failures. The first run encountered a Simulator test-host bootstrap exit before tests connected; the unchanged build passed completely on retry after the Simulator was ready.
- Specific iPhone 17 Pro Simulator build: PASS.
- Generic iOS Simulator build: PASS.
- Generic iOS Device build with signing disabled: PASS.
- Simulator launch: PASS.
- Human Gate: OWNER WAIVED / DEFERRED TO WU-10. No real-device, AlarmKit firing, VoiceOver, or final human visual result is claimed.

## Root cause and isolation

The stale divider/classification came from screen-local `@State private var now = Date()` snapshots with no advancing source. WU-09-04 introduces one root-owned active-only minute clock. Lifecycle activation and existing significant-time/timezone/day refresh-generation signals refresh it immediately; deactivation invalidates its sole timer. A minute tick only publishes a `Date`: the clock has no calendar provider, reconciliation coordinator, persistence store, or alarm scheduler dependency. Focused tests cover time injection, activation coalescing, stop behavior, start-date boundary semantics, exact alarm copy, navigation identifiers, and the platform-side-effect isolation boundary.

## Visual matrix

The twelve fresh iPhone 17 Pro Simulator captures are `01-main.png` through `12-detail-past.png`. They cover the two-tab shell, unified populated/current/past/future/no-future/empty timelines, long content, alarm OFF, Settings, calendar selection, and default/past detail paths. The minute changed during capture (20:21 → 20:23), and later captures/render inspection confirmed the divider and row classification used the live value without forced scroll.

## Scope audit

Only Production presentation models/views, focused Production UX tests, documentation, and visual evidence changed. EventKit remains read-only; AlarmKit scheduling, reconciliation horizon/logic, BackgroundTasks, persistence schema, settings behavior, and event-override business semantics were not modified. No third-party dependency, backend, analytics, watchOS target, calendar write path, WU-10 work, merge, or push was introduced.
