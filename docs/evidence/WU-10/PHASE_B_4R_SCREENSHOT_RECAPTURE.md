# WU-10 Phase B.4R — Final Screenshot Recapture Correction

Audit date: 2026-08-22.

## Candidate and environment

1. Branch: `wu-10-release-gate`.
2. Accepted UI candidate: `50fc6258384f0ac80cc88661132dbec1a7bca2da`.
3. Parent HEAD before recapture: `5f25ed691485b7918fb1eb22ffa696c47c03abcf`.
4. Simulator: iPhone 17 Pro Max (`F9006C43-A464-4C67-9B9E-D564B1975BC6`), iOS 26.5.
5. Locale/appearance/text size: Japanese `ja_JP`, Light, standard Large.
6. Final directory: `docs/release/screenshots/final-ja/`.

## Final order, navigation, and hashes

All images are 1320×2868 portrait JPEG, RGB, no alpha.

| File | Screen and exact navigation context | SHA-256 |
|---|---|---|
| `01.jpg` | Production root → selected `アラーム` tab; Today/current/upcoming focus | `1e4a9c288f0cbabb6063c18ec601a0b539e8f21ca9f04e00f37b7297f0225f46` |
| `02.jpg` | Production root → `アラーム` tab → tap `チーム定例`; back affordance and default five-minute lead visible | `207f5cf50c04419059d3083555aeb51d4cbe7d32f33f6d458edf177dbdd56d4c` |
| `03.jpg` | Production root with DEBUG-injected 15-minute override → `アラーム` tab → tap `チーム定例`; back affordance and custom 15-minute lead visible | `804dda893db6b8acb6c0998bda8a09fc450ea3ffeaad4b76d33e849dee6b0fb0` |
| `04.jpg` | Production root → selected `アラーム` tab → DEBUG-prepared multi-date composition; Today/current, Tomorrow, and August 25 visible | `2eef59fea5a8724165381ab47ad61361d0aa695b1be680a800c10d0b1103e6d6` |
| `05.jpg` | Production root → `設定` tab → tap `表示するカレンダー`; NavigationStack back affordance and synthetic calendars visible | `9969f3b1e1b8505c0722c30e5e6d1f3db65ef214e20313c50ffb91fe8a4fc979` |
| `06.jpg` | Production root → selected `設定` tab | `d6b8740cac09a70afbf88eebc3a528fd9bcbe277e439dcce62e7ee300b42c276` |

`file` and `sips` confirmed the dimensions, baseline JPEG encoding, RGB/three components, and no alpha. All six SHA-256 values are unique. Explicitly, `01 != 04` and `02 != 03`. Visual inspection independently confirmed six distinct screens/states, normal navigation chrome, no accidental crop, no clipped Production UI, no Simulator window chrome, no debug/test labels, and no duplicate composition.

## Privacy, timeline, and sticky-header audit

- Fixture data is deterministic and synthetic: generic Japanese events plus `仕事` and `プライベート` calendar names grouped under EventKit-style source labels. No real account name, email, phone, location, personal event, secret, or private identifier appears.
- Timeline images start at Today; no yesterday/older section appears. `01` emphasizes earlier-today/current/upcoming alarms. `04` is visually distinct and emphasizes Today → Tomorrow → later planning.
- The date-header/navigation region remains an opaque app surface. No transparent gap, content bleed, seam, or jump is visible.

## DEBUG-only harness and Release validation

The only Swift delta is in `CalendarAlarmFeasibility/Production/Features/ProductionUXView.swift` and is limited to existing DEBUG-only scenario behavior:

- `detail-custom` now presents the real root `MainTabsView` while retaining its synthetic 15-minute override, so the event detail is reached by tapping the real timeline row.
- `timeline-future` now presents the real root `MainTabsView`, passes a screenshot-only initial alarm anchor, and limits its deterministic fixture to the three dates needed for a clean multi-date composition.
- `MainTabsView` accepts an optional sample anchor whose default is `nil`; the normal Production root remains unchanged.

`SampleScenarioPolicy.scenario` returns `nil` outside DEBUG, so these routes/data cannot activate in Release. Generic iOS Simulator Release build: **PASS**, no compiler warnings. The accepted B.3 regression remains **167/167 PASS**; the full suite was not rerun because no Release-effective Production behavior or project/configuration changed.

Production Release-effective UI/domain/project/configuration/signing/AppIcon/privacy-manifest diff: **NONE**. The Xcode project file is unchanged.

## Supersession and status

- The previous B.4 screenshot package is superseded and not owner-approved.
- The B.2 Distribution IPA remains stale and must not be uploaded. No archive or IPA was regenerated.
- Screenshot/evidence commit: the single commit containing this document; exact SHA is recorded in the final handoff.
- Working tree: clean after that commit.
- Push: not performed.
- Merge: not performed.
- Tag: not performed.
- Upload: not performed.
- Submission: not performed.
- Owner visual approval: **PENDING / NOT APPROVED**.

**FINAL APP STORE SCREENSHOTS RECAPTURED**  
**OWNER VISUAL APPROVAL PENDING**
