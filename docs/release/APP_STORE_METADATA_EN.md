# App Store Metadata Draft — English

Draft only; owner approval is required before App Store Connect entry.

## Core metadata

- App Name: `AgendaCue` (9/30 characters)
- Bundle ID: `com.naoki-ko.agendacue`
- Subtitle: `Calendar alerts you won’t miss` (30/30 characters)
- Promotional text: `Turn events in your iPhone calendar into alarms at the lead time you choose.`
- Primary category: Productivity
- Secondary category candidate: Utilities
- Keywords: `calendar,agenda,alarm,schedule,reminder,event`
- Version: `1.0`
- Copyright: `© 2026 [OWNER NAME]`
- Support URL: `[OWNER INPUT REQUIRED]`
- Privacy Policy URL/status: `[OWNER INPUT REQUIRED]`

## Description

AgendaCue reads events available in your iPhone calendar and schedules a real alarm at the selected time before each eligible event.

Choose participating calendars, set a default lead time, turn an alarm off for an individual event, or select one of the supported custom lead times.

Calendar access is read-only. AgendaCue does not add, edit, or delete calendar events. There is no account or login, and app settings and processing remain on your device.

Background refresh is a best-effort opportunity controlled by iOS, not a delivery guarantee. Open AgendaCue after changing an event to reconcile the latest calendar state.

AgendaCue supports events registered with iPhone Calendar and available through EventKit. It does not connect directly to Google Calendar, Outlook, Lifebear, or other calendar providers.

## App Review Notes

No account or login is required. Calendar permission is used only to read event timing; Alarm permission is used to schedule AlarmKit alarms. Create a sufficiently future timed event in iPhone Calendar, enable its calendar in AgendaCue, and foreground the app to reconcile. The custom AlarmKit title is exactly the nonblank event title; a blank title falls back to `予定`. All-day events are excluded. Background timing is controlled by iOS and is not guaranteed.

App Name and Subtitle comply with Apple's 30-character maximum documented in [App Store Connect Help](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information).
