# WU-12 Accessibility XXXL Timeline Fix

Date: 2026-08-24 (Asia/Tokyo)

Work Unit: WU-12 Accessibility XXXL Timeline Layout Fix

## Repository and defect

1. **Branch:** `wu-10-release-gate`.
2. **Starting HEAD:** `bebe9de87e4018c384e242b6c5ad40d24ae6adf4` (`Document Production V1 quality validation`). The preflight working tree was clean.
3. **Defect:** `DEFECT-WU11-001`, S2/P1 — Accessibility XXXL timeline content overlap/clipping and vertically fragmented time text. WU-12 disposition: **RESOLVED IN WU-12**.
4. **Root cause:** The current-time row always used a compact `HStack` with a fixed 70-point time column. The event row had an accessibility reflow, but it began only at accessibility categories, leaving XXXL on the rigid compact geometry. At Accessibility XXXL, the current time could wrap character-by-character and row content could become obscured.

## Change scope and strategy

5. **Production files changed:** `CalendarAlarmFeasibility/Production/Features/ProductionUXView.swift` only. The deterministic DEBUG-only long scenario was aligned with the requested synthetic title/calendar, and the two timeline row presentations were corrected.
6. **Test files changed:** `CalendarAlarmFeasibilityTests/ProductionUXTests.swift` only. Two focused tests protect compact selection below XXXL and expanded selection at XXXL/all accessibility categories.
7. **Layout strategy:** A shared `TimelineRowLayoutMode` presentation policy preserves the compact rows for Large, XL, and XXL. XXXL and all accessibility categories use a rail beside a vertically growing content stack. Event/current times appear above their related details instead of inside the fixed-width compact time column.
8. **Why accessibility-safe:** The adaptive path follows Dynamic Type rather than device width, permits vertical growth and normal vertical scrolling, retains full title/alarm/status meaning, and avoids shrinking, scaling, truncating, clipping, hiding information, or horizontal timeline scrolling. Time `Text` uses intrinsic horizontal size (`fixedSize(horizontal: true, vertical: false)`), so the `HH:mm` value remains one conceptual unit. Existing grouped accessibility labels remain unchanged.

The production behavior change is presentation/layout only. The Today-first sequence, current divider, timeline rail, date grouping/sticky-header implementation, title hierarchy, alarm/status strings, tabs, colors, data inputs, and interactions remain in place.

## Fresh Simulator validation

Environment: macOS 26.5.2; Xcode 26.6 (17F113); iOS 26.5 Simulator. All scenarios used DEBUG-only deterministic synthetic data. No real calendar data was used.

| # | Required result | Result and evidence |
|---|---|---|
| 9 | Large | **PASS (visual).** Existing compact horizontal presentation remains visually acceptable; time, long title, and alarm hierarchy are intact. `01-large-light-pro.png`. |
| 10 | XXXL | **PASS (visual).** Expanded presentation activates at the requested boundary; current/event times remain intact and content grows vertically. `02-xxxl-light-pro.png`. |
| 11 | Accessibility XXXL | **PASS (visual).** No fragmented time, unrelated overlap, essential clipping, unreadable hierarchy, or horizontal viewport overflow was observed. Long content wraps and the timeline remains vertically scrollable. `03-axxxl-light-pro.png`. |
| 12 | Light | **PASS (visual).** Large, XXXL, Accessibility XXXL, all three widths, and deterministic state variants were inspected. |
| 13 | Dark | **PASS (visual).** Accessibility XXXL contrast/hierarchy and reflow remained understandable. `04-axxxl-dark-pro.png`. |
| 14 | Small iPhone | **PASS (visual).** iPhone 17e, device `6C46C38C-16DF-4001-B436-A2B190F987A3`; Accessibility XXXL Light. `05-axxxl-light-small.png`. |
| 15 | Pro | **PASS (visual).** iPhone 17 Pro, device `9D870918-AC43-4F0C-9C63-49B824D22C5B`; Large/XXXL/Accessibility XXXL Light and Accessibility XXXL Dark. `01`–`04`. |
| 16 | Pro Max | **PASS (visual).** iPhone 17 Pro Max, device `F9006C43-A464-4C67-9B9E-D564B1975BC6`; Accessibility XXXL Light. `06-axxxl-light-pro-max.png`. |
| 17 | Sticky header | **BLOCKED — INTERACTIVE SIMULATOR REQUIRED.** Static launch/capture tooling cannot execute the required slow, fast, and reverse scroll gestures, so UI-010 is not claimed as PASS. The sticky-header implementation was not changed. |
| 18 | Accessibility Inspector | **NOT EXECUTED — TOOL NOT AVAILABLE IN THE COMMAND-LINE ENVIRONMENT.** Static semantic audit confirms each row remains one grouped accessibility element with its existing time/title/calendar/alarm label. Real VoiceOver is not claimed and remains a physical Human Gate item. |

Additional Accessibility XXXL deterministic visual states were inspected in temporary captures and intentionally not committed: earlier Today/current/future rows, multiple date groups, default lead, 15-minute custom lead (`15分前にアラーム`), and OFF (`アラームなし`). Current product behavior excludes all-day events from the alarm timeline; WU-12 did not alter or fabricate that domain behavior.

### Time integrity

The changed expanded layout gives every formatted `HH:mm` value intrinsic horizontal width and never places it in the 70-point compact column. Static layout-path review explicitly covered `09:00`, `10:30`, `15:55`, `21:16`, and `23:59`: each is one five-character `Text` value using monospaced digits and horizontal fixed size. Fresh Accessibility XXXL captures visually confirm the same path with live `21:xx` current/future values. None fragmented into vertical character pieces.

## Automated and build gates

| # | Gate | Result |
|---|---|---|
| 19 | Full XCTest from the WU-12 worktree | **PASS — 170 tests, 0 failures, 0 skipped.** iPhone 17 Pro Simulator. Result: `/private/tmp/AgendaCue-WU12-Tests/Logs/Test/Test-CalendarAlarmFeasibility-2026.08.24_21-36-14-+0900.xcresult`. |
| 20 | Debug generic Simulator build | **PASS.** |
| 21 | Release generic Simulator build | **PASS.** |
| 22 | Unsigned generic Device Release build | **PASS** with `CODE_SIGNING_ALLOWED=NO`. |
| 23 | Warnings | **PASS — no new actionable compiler warnings; all three successful `xcodebuild -quiet` gates produced no compiler output.** `git diff --check` also passed. |

24. **Domain non-regression audit:** PASS. The Production diff is confined to `ProductionUXView.swift` presentation and DEBUG-only synthetic strings. Full XCTest passed. No change was made to alarm-date calculation; 5/10/15/30/60-minute leads; event-override precedence; all-day exclusion; `alarmDate > now`; duplicate prevention; reconciliation; Today-first filtering; 14-day scheduling horizon; AlarmKit title behavior; or EventKit read-only policy.

25. **Remaining blocked/device cases:** UI-010 interactive sticky-header scrolling is blocked; Accessibility Inspector/real VoiceOver is not executed; physical AlarmKit/EventKit/Watch/background and Human Gate H01–H46 remain pending. No public-release, upload, submission, or distribution claim follows from Simulator presentation evidence.

26. **Release recommendation:** **CONDITIONAL GO FOR NEXT RELEASE-GATE PHASE.** The automated gate passes and `DEFECT-WU11-001` is resolved. Physical-device validation and Human Gate H01–H46 remain required before any final public-release GO.

## Committed visual evidence

- `01-large-light-pro.png`
- `02-xxxl-light-pro.png`
- `03-axxxl-light-pro.png`
- `04-axxxl-dark-pro.png`
- `05-axxxl-light-small.png`
- `06-axxxl-light-pro-max.png`

These are fresh defect-focused captures. Temporary state-matrix images are intentionally excluded from the commit.
