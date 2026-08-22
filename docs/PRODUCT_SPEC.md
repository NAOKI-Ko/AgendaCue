# AgendaCue Product Specification — Production V1

## Purpose and promise

AgendaCue converts selected calendar events available in the device's iOS calendar database into prominent AlarmKit alarms at a user-configured lead time.

> If an important calendar event starts at 10:00, AgendaCue can alert me with a real alarm at the configured time before it.

## Product constraints

- iOS 26+ using Swift and SwiftUI.
- Free; no ads or in-app purchases.
- Fully local; no account, login, backend, analytics, networking product, Google Calendar API, or AI.
- Calendar events are fetched through EventKit. Calendars surfaced by iOS, including configured iCloud and Google calendars, may participate.
- The app is read-only by policy even though the current EventKit permission required to fetch events is named full access.
- Saving, updating, deleting events, or altering calendars is forbidden.
- Alarm scheduling uses AlarmKit.
- V1 has no watchOS target. Paired Apple Watch behavior is limited to AlarmKit's native system experience and must be verified in WU-00.

## Core V1 capabilities

- Production onboarding and permission/recovery UX.
- Selection of participating device calendars.
- A default alarm lead time.
- Per-event alarm ON/OFF and per-event lead-time override.
- All-day events excluded by default.
- AlarmKit scheduling with duplicate prevention and stale-alarm cleanup.
- Reconciliation of added, changed, and deleted calendar events.
- Foreground reconciliation and handling of `EKEventStore` changes.
- Best-effort background reconciliation, scheduled later in the implementation plan and constrained by verified platform behavior.
- Correct timezone and day-boundary behavior.
- Settings, empty/error states, accessibility, reliability, and App Store release readiness.

## Intended one-shot alarm model

For a calendar-derived one-shot alarm:

`alarmDate = event.startDate - effectiveLeadTime`

Use an absolute/fixed alarm date unless later platform verification demonstrates a reason to change it. This is a domain requirement, not an implementation in the bootstrap baseline.

## Success boundaries

V1 succeeds when an eligible selected event produces at most one correct alarm candidate, the corresponding AlarmKit alarm can be maintained as the calendar changes, and permission/failure states are understandable and recoverable without modifying calendar data.

## V1.1+ parking lot — explicitly excluded from V1

- Dedicated watchOS app
- Widgets
- Multiple alarms per event
- Keyword automation
- AI importance classification
- Travel-time alarms
- Location automation
- Custom sound product system
- Advanced snooze product design
- Analytics
- Backend sync
- Accounts
- Monetization

These items cannot be promoted into V1 without explicit human approval and Source of Truth changes.
