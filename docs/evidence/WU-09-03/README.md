# WU-09-03 Today Visual QA Evidence

`00-owner-approved-source-of-truth.png` is the owner-provided final Today mockup and the visual Source of Truth. The twelve fresh Simulator screenshots were captured on 2026-08-18 with Xcode 26.6 and iOS 26.5, using deterministic DEBUG-only sample scenarios and Japanese presentation.

| # | Evidence | Coverage | Result |
|---:|---|---|---|
| 00 | `00-owner-approved-source-of-truth.png` | Owner-approved hierarchy/layout reference | SOURCE |
| 01 | `01-today-populated-light.png` | Populated Today, Light, native tabs | PASS |
| 02 | `02-today-populated-dark.png` | Populated Today, Dark | PASS |
| 03 | `03-past-current-future.png` | Past/current/future chronological structure | PASS |
| 04 | `04-current-divider-representative.png` | Current time, filled marker, label, dashed rule | PASS |
| 05 | `05-long-event-title.png` | Multiline event-title growth | PASS |
| 06 | `06-alarm-off.png` | Explicit `アラームなし` secondary state | PASS |
| 07 | `07-today-empty.png` | Existing Japanese empty-state quality | PASS |
| 08 | `08-large-dynamic-type.png` | Large Dynamic Type | PASS |
| 09 | `09-accessibility-xxxl.png` | Accessibility XXXL vertical growth/scrolling | PASS |
| 10 | `10-small-iphone.png` | Small iPhone | PASS |
| 11 | `11-standard-iphone.png` | Standard iPhone | PASS |
| 12 | `12-large-iphone.png` | Large iPhone | PASS |

## Inspection and comparison

Every capture was inspected for title/time hierarchy, compact header height, excess whitespace, three-column alignment, marker/line weight, current divider, exact alarm-time priority, separator placement, Japanese clipping, Dark Mode, Dynamic Type, tab-bar weight, debug leakage, and whole-row interaction.

Compared with WU-09-02 Today, the screen is structurally different: event titles use stronger `title2` typography; repeated visible calendar labels are removed; time, marker, and content form a continuous vertical timeline; future alarms show only their exact time; past events use a neutral checked marker and explicit `終了済み`; and the actual current time is inserted chronologically with a filled accent marker and subtle dashed rule. The native iOS 26 `TabView` appearance remains system-owned.

The implementation follows the mockup's information hierarchy and rhythm without copying fixed pixels. Semantic fonts/colors and an accessibility-size layout replace fixed geometry when required. Accessibility Inspector, real VoiceOver traversal, physical-device contrast/touch review, and final device visual acceptance remain deferred to WU-10.
