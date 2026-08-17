# WU-09-02 Visual QA Evidence

Captured 2026-08-18 with Xcode 26.6, iOS 26.5 Simulators, Japanese locale, and deterministic DEBUG-only sample scenarios. Each image was inspected for Japanese clipping and line breaks, control width, hierarchy, alignment, spacing, section rhythm, current-position visibility, past/future distinction, light/dark contrast, Dynamic Type, debug leakage, unintended English, and visual consistency.

| # | Evidence | Coverage | Result |
|---:|---|---|---|
| 01 | `01-onboarding-japanese.png` | Japanese onboarding and permission grouping | PASS |
| 02 | `02-onboarding-large-type.png` | Large Dynamic Type and scroll reachability | PASS |
| 03 | `03-today-light.png` | Populated Today, light | PASS |
| 04 | `04-today-dark.png` | Populated Today, dark | PASS |
| 05 | `05-today-long-title.png` | Long event title wrapping | PASS |
| 06 | `06-today-empty.png` | Empty Today state | PASS |
| 07 | `07-timeline-initial-current.png` | Initial current-boundary position | PASS |
| 08 | `08-timeline-past-visible.png` | Upward access to past events | PASS |
| 09 | `09-timeline-current-first-future.png` | Current boundary and first future event | PASS |
| 10 | `10-timeline-future-sections.png` | Future chronological date sections | PASS |
| 11 | `11-timeline-no-future.png` | Safe no-future fallback to current | PASS |
| 12 | `12-detail-default.png` | Default alarm detail | PASS |
| 13 | `13-detail-custom.png` | Custom lead detail | PASS |
| 14 | `14-detail-off.png` | Explicit alarm OFF detail | PASS |
| 15 | `15-detail-past.png` | Read-only completed-event detail | PASS |
| 16 | `16-calendars.png` | Calendar selection | PASS |
| 17 | `17-calendars-long.png` | Long source/calendar names | PASS |
| 18 | `18-settings.png` | Japanese Settings hierarchy | PASS |
| 19 | `19-permission-denied.png` | Denied guidance and Settings recovery | PASS |
| 20 | `20-error.png` | Error state and retry | PASS |
| 21 | `21-small-iphone.png` | Small iPhone layout | PASS |
| 22 | `22-large-iphone.png` | Large iPhone Timeline | PASS |
| 23 | `23-accessibility-xxxl.png` | Accessibility XXXL semantics and scrolling | PASS |
| 24 | `24-timeline-dark.png` | Representative dark Timeline | PASS |

## Before / after review

Compared with `docs/evidence/WU-09/`, WU-09-02 is not a translation-only pass. Onboarding replaces repeated card treatment with a calmer permission group; Today replaces a large rounded event container with a scan-friendly time/content hierarchy; Upcoming becomes a chronological `予定` timeline with past context, an explicit current boundary, and `現在へ`; Event Detail is summary-first and makes completed events visibly read-only; calendar and Settings surfaces use consistent native grouping. These changes materially improve hierarchy, information density, Japanese readability, and Today/Timeline consistency.

Native navigation-bar scroll-edge material may show de-emphasized content beneath the bar during programmatic current/future positioning; this is standard iOS behavior and did not obscure the title or `現在へ` control. Accessibility XXXL intentionally requires vertical scrolling. Accessibility Inspector, real VoiceOver order, physical-device contrast/touch review, and final human visual acceptance remain deferred to WU-10.
