# AgendaCue QA Defects

## DEFECT-WU11-001 — Accessibility XXXL timeline content overlaps and clips

- **Status:** **RESOLVED IN WU-12**
- **Severity:** S2 Major / P1 release-quality requirement
- **Test ID:** A11Y-003
- **Summary:** At Accessibility XXXL, the Today timeline does not preserve readable layout: date/event content is clipped or overlaps and the time column wraps into separate digits.
- **Environment:** Xcode 26.6 (17F113); iOS 26.5 Simulator; iPhone 17 Pro (1206×2622 capture); AgendaCue Debug build from pre-WU-11 Production baseline `436af22e01b12a64f2264d2d895b0d6bed7acd12` plus the test-only WU-11 delta; Light appearance; content size `accessibility-extra-extra-extra-large`.
- **Precondition:** Install the current Debug app; use the deterministic `today-long` scenario; no real calendar information.
- **Steps:**
  1. Set Simulator content size to Accessibility XXXL: `xcrun simctl ui <device> content_size accessibility-extra-extra-extra-large`.
  2. Launch `com.naoki-ko.agendacue` with `-UIScenario=today-long`.
  3. Observe the initial Alarm/Today timeline.
- **Actual:** The date subtitle and row region overlap/clip near the top of the timeline. The current-time value is forced into a narrow fixed column and wraps vertically as separate fragments (`2`, `1:`, `1`, `6`). Event content is partially obscured, so the primary timeline is not reliably readable at this supported accessibility size.
- **Expected:** Text should reflow or scroll without overlap or clipping; time/event meaning should remain readable and grouped at Accessibility XXXL.
- **Reproducibility:** 1/1 on the stated Simulator configuration.
- **Suspected component:** `CalendarAlarmFeasibility/Production/Features/ProductionUXView.swift`, unified timeline row/header layout under accessibility Dynamic Type.
- **Release impact:** Unresolved P1 accessibility defect. It prevents a release GO recommendation under `docs/TEST_SPECIFICATION.md`; it does not invalidate the passing alarm-domain automation.
- **Recommended disposition:** Triage in a separately authorized Production fix WU, add focused layout regression coverage where practical, rerun A11Y-003 across representative small/standard/large iPhones, and obtain human VoiceOver/Dynamic Type acceptance before public release. Do not fix within WU-11.
- **Evidence:** `docs/evidence/WU-11/01-dynamic-type-overlap.png`.
- **WU-12 root cause:** Both timeline row types assumed a compact horizontal geometry. In particular, the current-time row always constrained its time to a 70-point column, and the existing event-row reflow started only at accessibility categories. The fixed column fragmented large time text, while XXXL still used the compact layout.
- **WU-12 fix:** A shared presentation-only layout policy keeps the existing compact layout through XXL and selects a vertically growing rail-plus-content layout at XXXL and every accessibility category. Time values use their intrinsic horizontal size; event title and alarm/status content retain flexible wrapping. No domain value or semantic accessibility label changed.
- **WU-12 validation:** Fresh deterministic Simulator review passed at Large, XXXL, and Accessibility XXXL; Light and Dark; iPhone 17e, iPhone 17 Pro, and iPhone 17 Pro Max. Current and event times remained intact, long event/alarm/OFF/custom content reflowed vertically, and no unrelated overlap, essential clipping, or horizontal viewport overflow was observed. Full XCTest passed 170/170; Debug Simulator, Release Simulator, and unsigned generic Device Release builds passed with no compiler output from quiet builds. See `docs/evidence/WU-12/ACCESSIBILITY_XXXL_FIX.md` and its six committed captures.
- **WU-12 commit:** Recorded in the WU-12 final handoff; a commit cannot embed its own SHA.
- **Residual limitations:** UI-010 remains **BLOCKED — INTERACTIVE SIMULATOR REQUIRED**. Accessibility Inspector and real VoiceOver were not available in the command-line environment. Physical-device validation and Human Gate H01–H46 remain pending, so this resolution is not a public-release GO.
