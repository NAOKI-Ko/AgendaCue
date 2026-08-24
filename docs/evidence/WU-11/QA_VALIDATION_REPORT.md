# WU-11 QA Validation Report

Date: 2026-08-24 (Asia/Tokyo)

Work Unit: WU-11 Production V1 Test Specification & Quality Validation

## Repository baseline

- Repository: `calendar-alarm-ios`
- Working directory: `/Users/naoki/Documents/Codex/2026-08-18/files-pasted-by-the-user-calendar/work/calendar-alarm-ios`
- Branch: `wu-10-release-gate`
- HEAD before WU-11: `436af22e01b12a64f2264d2d895b0d6bed7acd12`
- Initial working tree: clean (`git status --short` produced no paths)
- Initial history head: `436af22 Recapture screenshots with production navigation`
- Final WU-11 commit: recorded in the final WU-11 handoff because a commit cannot embed its own SHA
- Test specification: `docs/TEST_SPECIFICATION.md`

## Specification inventory

- Traceable requirement rows: **82**
- Stable test cases: **114**
- P0: **70**
- P1: **41**
- P2: **3**
- P3: **0**
- Primary automation classification: **88 automated**, **9 Simulator-manual**, **17 physical-device/best-effort** (exclusive primary classification; hybrid cases retain additional environment requirements in the specification)
- Existing automated coverage: strong across domain arithmetic, selection/mapping, override precedence, AlarmKit service transactions, reconciliation convergence/failures, permission presentation policy, lifecycle/background orchestration, persistence, and UI presentation policies.
- New automated coverage: one test-only regression in `CalendarAlarmFeasibilityTests/AlarmRuleEngineTests.swift`, asserting a 10:00 event produces 09:55/09:50/09:45/09:30/09:00 for every supported 5/10/15/30/60-minute lead. Production code was not changed.

## Automated execution

Environment: macOS 26.5.2 (25F84); Xcode 26.6 (17F113); iOS 26.5 Simulator; iPhone 17 Pro Simulator `9D870918-AC43-4F0C-9C63-49B824D22C5B`.

| Gate | Command summary | Result |
|---|---|---|
| Full XCTest | `xcodebuild ... -configuration Debug -destination platform=iOS Simulator,id=9D... -derivedDataPath /private/tmp/AgendaCue-WU11-Test test` | **PASS — 168 tests, 0 failures** |
| Debug Simulator build | `xcodebuild ... -configuration Debug -destination generic/platform=iOS Simulator ... build` | **PASS** |
| Release Simulator build | `xcodebuild ... -configuration Release -destination generic/platform=iOS Simulator ... build` | **PASS** |
| Unsigned Device Release | `xcodebuild ... -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO ... build` | **PASS** |
| Warning audit | Incremental `xcodebuild -quiet` for all three build configurations | **PASS — no compiler output/warnings** |
| Whitespace audit | `git diff --check` | **PASS** |

The first sandboxed XCTest attempt could not connect to CoreSimulatorService and emitted local Simulator/profile/tooling warnings; it was not treated as a test result. The same command was rerun with permitted Simulator access and passed 168/168. No actionable source/compiler warning appeared in the successful quiet audits. XCTest result bundle: `/private/tmp/AgendaCue-WU11-Test/Logs/Test/Test-CalendarAlarmFeasibility-2026.08.24_21-14-37-+0900.xcresult`.

## Manual Simulator validation

Fresh DEBUG-only deterministic captures were executed on the booted iPhone 17 Pro Simulator. They validate app-owned presentation only; they do not prove live EventKit/AlarmKit behavior.

| Area | Result | Evidence/notes |
|---|---|---|
| Onboarding / Calendar rationale | PASS (visual) | Fresh `onboarding` and `calendar-denied` captures; no obsolete Welcome |
| Permission-state UI where controllable | PASS (visual) | Calendar denial recovery and Alarm rationale captured; real prompts/revocation remain device-only |
| Today-first timeline/current divider | PASS (visual, default size) | Fresh `today` capture; earlier Today/current/future hierarchy visible |
| Future timeline/date groups | PASS (visual) | Fresh `timeline-future` capture |
| Event detail/default/custom/OFF | PASS (visual states) | Fresh `detail-default`, `detail-custom`, `detail-off` captures; gesture navigation was not claimed |
| Calendar selection | PASS (visual) | Fresh `calendars` capture |
| Settings | PASS (visual) | Fresh `settings` capture |
| Empty and error states | PASS (visual) | Fresh `empty` and `error` captures |
| Dark appearance smoke | PASS (visual) | Fresh `dark` timeline capture |
| Sticky header scrolling | **BLOCKED — INTERACTIVE SCROLL GESTURE REQUIRED** | Static capture cannot prove pinning/flash/jump behavior |
| Accessibility XXXL Dynamic Type | **FAIL** | DEFECT-WU11-001; `01-dynamic-type-overlap.png` |

Temporary non-defect screenshots are at `/private/tmp/AgendaCue-WU11-Sim/` and are intentionally not committed. Only the defect evidence is retained in the repository.

## Physical device status

- DEV-001–DEV-014: **NOT EXECUTED — PHYSICAL IPHONE REQUIRED**.
- Real AlarmKit schedule/fire/title/fallback/stop/lock-screen/Dynamic Island behavior: NOT EXECUTED.
- Real EventKit provider discovery, real permission grant/revocation/recovery, inactive-event mutation/deletion, timezone/day change, multiple alarms, background timing and paired Apple Watch behavior: NOT EXECUTED or environment-dependent.
- Wholly blocked/unexecuted primary cases: **18** (17 physical-device/best-effort cases plus UI-010 sticky-header interaction). Hybrid AUTO+DEV and SIM+DEV cases are reported as partial rather than added again to this count.
- Human Gate H01–H46: **PENDING / NOT PASS**.

## Privacy and static audit

Result: **PASS for current static/build evidence**.

- No URLSession/Network/WebSocket/backend/cloud/provider API, analytics, ad, tracking, login/account, AI, StoreKit or third-party SDK surface was found in Production source/project searches.
- Release binary linkage contains Apple system frameworks only: Foundation, ActivityKit/AlarmKit, AppIntents, BackgroundTasks, EventKit, SwiftData, SwiftUI/UIKit and Swift runtime libraries.
- Calendar production interfaces expose discovery/fetch and permission operations; no EventKit save/remove/edit API was found.
- App-owned persistence is local. Tests/source show settings, selections, overrides, minimal alarm mappings and the onboarding flag; EventKit event content remains Source of Truth.
- `PrivacyInfo.xcprivacy` is present in source and built Release app; it declares no collected data, tracking false, and UserDefaults reason CA92.1.
- Built Release plist has iOS 26.0 minimum, `com.naoki-ko.agendacue`, Calendar/Alarm descriptions, the single permitted BG task ID, and only `fetch` background mode.
- The only source `print` is inside `#if DEBUG` for background request diagnostics.
- Release binary scan found no `-UIScenario` or synthetic scenario event-title strings. Internal symbol names containing `sample` remain, but Release scenario routing returns nil under compile-time `#if DEBUG`; no sample data/routing string was present in the Release artifact.
- No sensitive tokens, credentials, real calendar values or private identifiers were discovered.

## Defects and release recommendation

- Defect count: **1**.
- `DEFECT-WU11-001` (S2/P1): Accessibility XXXL causes timeline content overlap/clipping and vertically fragmented time text. Reproduced 1/1; no Production fix was made. See `docs/QA_DEFECTS.md`.
- Production implementation diff: **NONE**. WU-11 changes only test specification/defect/evidence documentation, one screenshot, and one focused XCTest method.
- Recommendation: **NO-GO for public release at this time**. The automated quality gate passed, but an unresolved P1 accessibility defect exists and required physical-device/Human Gate validation remains pending. This is not upload, submission, merge or release authorization.

## Mandatory actions before public release

1. Triage/fix or explicitly owner-disposition DEFECT-WU11-001 in a separately authorized WU, then rerun affected automated/build/Simulator accessibility gates.
2. Execute DEV-001–DEV-013 on a physical iPhone and DEV-014 if a paired Watch is available; record SHA-bound human evidence.
3. Complete Accessibility Inspector and real VoiceOver/Dynamic Type/touch-target validation.
4. Execute UI-010 sticky-header scrolling and resolve any finding.
5. Complete H01–H46 and explicit owner GO/NO-GO.
6. Obtain owner screenshot approval and create a fresh post-UI-freeze Distribution archive/IPA; the B.2 IPA is stale.
7. Obtain separate explicit authorization before any push/merge/tag/upload/submission; none is performed by WU-11.
