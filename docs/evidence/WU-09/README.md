# WU-09 Visual QA Evidence

Captured on iOS 26.5 Simulators from the WU-09 worktree. All scenarios use DEBUG-only allowlisted sample data; Release builds ignore these launch arguments. The review checks readable hierarchy, wrapping rather than truncation, semantic system colors, explicit non-color status, recovery actions, and scrollability at large text sizes.

| # | Evidence | Device / appearance / text | Finding |
|---:|---|---|---|
| 01 | `01-onboarding-light.png` | iPhone 17 Pro / Light / Large | PASS — purpose, privacy, permissions, and actions are clear. |
| 02 | `02-onboarding-large-text.png` | iPhone 17 Pro / Light / XXXL | PASS — content wraps and remains scrollable. |
| 03 | `03-today-light.png` | iPhone 17 Pro / Light / Large | PASS — event hierarchy and alarm status are clear. |
| 04 | `04-today-dark.png` | iPhone 17 Pro / Dark / Large | PASS — semantic contrast retained. |
| 05 | `05-today-accessibility-xxxl.png` | iPhone 17 Pro / Light / Accessibility XXXL | PASS — variable-height rows preserve content and scroll. |
| 06 | `06-today-long-content.png` | iPhone 17 Pro / Light / Large | PASS — long event/calendar names wrap without overlap. |
| 07 | `07-upcoming-grouped.png` | iPhone 17 Pro / Light / Large | PASS — two dates form distinct native sections. |
| 08 | `08-detail-default.png` | iPhone 17 Pro / Light / Large | PASS — inherited Default Alarm Time is explicit. |
| 09 | `09-detail-custom.png` | iPhone 17 Pro / Light / Large | PASS — Custom timing is explicit. |
| 10 | `10-detail-off.png` | iPhone 17 Pro / Light / Large | PASS — OFF state is stated in text, not color only. |
| 11 | `11-calendars-light.png` | iPhone 17 Pro / Light / Large | PASS — source grouping and selection controls are legible. |
| 12 | `12-calendars-dark.png` | iPhone 17 Pro / Dark / Large | PASS — calendar selection retains contrast. |
| 13 | `13-calendars-long-names.png` | iPhone 17 Pro / Light / Accessibility XXXL | PASS — long source/calendar names wrap and scroll. |
| 14 | `14-settings.png` | iPhone 17 Pro / Light / Large | PASS — terminology, permissions, and privacy copy align. |
| 15 | `15-permission-denied.png` | iPhone 17 Pro / Light / Large | PASS — denial and iOS Settings recovery are explicit. |
| 16 | `16-empty-today.png` | iPhone 17 Pro / Light / Large | PASS — empty Today state is understandable. |
| 17 | `17-empty-upcoming.png` | iPhone 17 Pro / Light / Large | PASS — empty Upcoming state describes the time window. |
| 18 | `18-error-state.png` | iPhone 17 Pro / Light / Large | PASS — error copy and 44-point-minimum retry action are clear. |
| 19 | `19-small-iphone.png` | iPhone 17e / Light / Large | PASS — long rows fit the small display without clipping. |
| 20 | `20-large-iphone.png` | iPhone 17 Pro Max / Dark / Accessibility XL | PASS — large-display layout and wrapping remain coherent. |

Limitations: screenshots do not prove real VoiceOver reading order, physical touch-target usability, device display contrast, localization, or human aesthetic acceptance. Those checks remain owner-waived here and deferred to WU-10.
