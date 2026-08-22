# WU-10 Phase B.3 — Final Timeline UI Polish

Audit date: 2026-08-22. Environment: Xcode 26.6 (17F113), iOS SDK/Simulator 26.5.

## Candidate

- Branch: `wu-10-release-gate`
- Parent SHA: `d4505209725e089a97dc492072bd98753d9c7190`
- Implementation/evidence commit: the single commit containing this document; exact SHA is recorded in the final handoff because a commit cannot embed its own hash.

## Files changed

- `CalendarAlarmFeasibility/Production/Features/ProductionUXModels.swift`
- `CalendarAlarmFeasibility/Production/Features/ProductionUXView.swift`
- `CalendarAlarmFeasibilityTests/ProductionUXTests.swift`
- Current release/evidence documentation under `docs/`

## Visible timeline range

- Old: local dates from 14 days before today through the existing future boundary.
- New: today through the existing future boundary. Yesterday and every earlier local date are excluded from presentation.
- Exact boundary: `calendar.startOfDay(for: now)`. An event is visible when its start date is at or after that boundary and before the unchanged presentation end. The implementation does not use `event.startDate >= now`, so already-ended events from earlier today remain visible.

## Scheduling and EventKit scope

Scheduling domain is unchanged: AlarmKit scheduling, candidate eligibility, reconciliation horizon `[now, now + 14 days)`, stale/past alarm cleanup, overrides, and lead-time rules were not modified. The prior 14-day historical EventKit fetch safety overlap is preserved in a distinct `calendarFetchWindow`; only `timelineWindow` is today-first.

## Sticky-header gap root cause and fix

The pinned `TimelineDateHeader` used translucent `.regularMaterial`, and the navigation bar retained automatic translucent background behavior. Rows scrolling underneath could therefore remain visible through the header/top transition region. The date header now uses opaque adaptive system background, the `ScrollView` has the same background, and the navigation bar explicitly renders a visible system background. Sticky `LazyVStack(pinnedViews: [.sectionHeaders])` behavior, header geometry/copy, row hit targets, and section transitions are unchanged.

## Focused tests

Focused coverage verifies:

- yesterday and older events are excluded;
- earlier-today and later-today events remain;
- tomorrow/future events remain;
- exact local-midnight inclusion and just-before-midnight exclusion;
- grouping contains no pre-today section;
- today section/current divider and current/future anchors remain valid;
- the 14-day historical fetch overlap remains separate;
- reconciliation remains `[now, now + 14 days)`.

## Full regression and builds

- Full XCTest: **PASS — 167 tests, 0 failures**, iPhone 17 Pro Simulator, iOS 26.5.
- Specific iPhone 17 Pro Simulator Debug: **PASS** as part of the test action.
- Generic iOS Simulator Release: **PASS**.
- Generic iOS Device Release unsigned (`CODE_SIGNING_ALLOWED=NO`): **PASS**.
- No new compiler warnings were emitted.

## Simulator visual QA

- Normal-size light timeline: **PASS** — Today is the first section; no yesterday section; an ended event earlier today remains above the actual current-time divider; later-today, tomorrow, and later-future events remain below/in subsequent sections; `現在へ` is present.
- Pinned-header state: **PASS** — DEBUG future-anchor navigation with Accessibility Dynamic Type forced the real scroll view into a scrolled/pinned state. The navigation/header region is opaque; no rows bleed through the former gap; no translucent strip, double seam, or layout jump is visible.
- Dark pinned-header state: **PASS** — adaptive system backgrounds remain opaque and visually coherent.
- QA captures are temporary evidence only, not final App Store screenshots.

## Screenshot readiness

Production UI is stable and ready for **FINAL APP STORE SCREENSHOT CAPTURE**. Final screenshots were not produced in B.3. Previous screenshots are superseded wherever the timeline appearance is visible.

## Distribution artifact status

The Phase B.2 IPA with SHA-256 `cc2d166677e48545f2b21a9e266a5d502b785b340ec53543e8c9ad60020aafb5` predates this Production UI change and is **STALE / MUST NOT BE UPLOADED**. Regenerate Distribution only after final screenshot capture/UI freeze.

## Status

- Working tree: clean after the single intentional commit.
- Push: not performed.
- Merge: not performed.
- Tag: not performed.
- Upload: not performed.
- Submission: not performed.

**TIMELINE POLISH VALIDATED**  
**READY FOR APP STORE SCREENSHOT CAPTURE**
