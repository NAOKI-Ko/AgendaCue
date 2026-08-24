# AgendaCue Production V1 Test Specification

Status: WU-11 formal release QA specification

Baseline under test: branch `wu-10-release-gate`, pre-WU-11 SHA `436af22e01b12a64f2264d2d895b0d6bed7acd12`

Product: AgendaCue, iOS 26+, Swift/SwiftUI, local-only

## 1. Purpose

This specification proves, as far as each environment permits, that AgendaCue reads eligible iOS Calendar events, calculates `alarmDate = event.startDate - effectiveLeadTime`, and maintains at most one corresponding AlarmKit alarm as permissions, lifecycle, calendar truth, time, timezone, and local overrides change. The North Star example is a 10:00 event with a five-minute lead producing exactly 09:55.

## 2. Scope

Production V1 calendar discovery/read behavior; selection; candidate rules; overrides; AlarmKit scheduling/cancellation; persistence; reconciliation; permissions; onboarding; timeline/detail/settings UI; lifecycle/time signals; privacy; accessibility; release builds; and actual iPhone AlarmKit presentation.

## 3. Out of scope

Calendar writes, provider-specific APIs, accounts, backend/cloud sync, analytics, ads, tracking, AI, monetization, widgets, a watchOS app, multiple alarms per event, keyword/travel/location rules, custom sounds, advanced snooze, upload, submission, merge, and tag creation.

## 4. Quality gates

- Automated gate: all current XCTest cases pass; Debug and Release Simulator builds pass; unsigned generic Device Release passes; `git diff --check` passes; no new compiler warnings attributable to WU-11.
- Core correctness gate: all P0 automated tests pass, with no known wrong time, duplicate, unsafe stale alarm, permission-state lie, crash, calendar write, or privacy contradiction.
- Simulator gate: execute safe interactive cases when a bootable interactive Simulator is available. Otherwise mark them `BLOCKED — INTERACTIVE SIMULATOR REQUIRED`; never infer PASS from screenshots.
- Device gate: DEV-001–DEV-014 require human physical-iPhone execution. They remain NOT EXECUTED until evidence exists. Apple Watch behavior is best-effort/environment-dependent.
- Human gate: owner GO/NO-GO and H01–H46 remain pending; this document cannot complete them.

## 5. Environments and classifications

| Code | Environment | Permitted claim |
|---|---|---|
| AUTO | XCTest/static/build automation on current Mac/Xcode | Deterministic logic, boundaries, buildability, source/config facts |
| SIM | Interactive iOS 26+ Simulator | App-owned UI/layout/navigation and controllable permission states |
| DEV | Physical iPhone on iOS 26+ | Real EventKit/AlarmKit authorization, scheduling, firing, lock screen and lifecycle |
| BEST | Environment-dependent physical/system behavior | Background opportunity, Dynamic Island, paired Apple Watch |

All tests use a clean install or explicitly documented retained state. Capture OS/Xcode/device model, locale, timezone, 12/24-hour setting, permissions, timestamp, screenshot/video or XCTest/build log, and observed result. Never capture real calendar content.

## 6. Requirement inventory and traceability

Coverage means test evidence, not implementation existence. `COVERED` denotes current deterministic automation; `PARTIAL` combines automation with pending manual proof; `MANUAL ONLY`, `DEVICE ONLY`, and `NOT TESTABLE IN CURRENT ENVIRONMENT` are literal.

| Requirement ID | Requirement | Source / implementation reference | Test ID(s) | Type | Priority | Current coverage | Notes |
|---|---|---|---|---|---|---|---|
| REQ-PLAT-01 | iOS 26+, SwiftUI Production app | PRODUCT_SPEC; project build settings; App entry/root view | REL-001–003 | AUTO | P0 | COVERED | Build verification required |
| REQ-PLAT-02 | Local-only; no login/account/backend/networking | PRODUCT_SPEC; ARCHITECTURE; source/project audit | PRIV-001–004 | AUTO | P0 | PARTIAL | Static proof plus device network observation |
| REQ-PLAT-03 | No analytics, ads, tracking, AI or third-party SDK | PRODUCT_SPEC; project dependency audit | PRIV-002, PRIV-003 | AUTO | P0 | COVERED | Re-audit current project |
| REQ-PLAT-04 | No provider-specific calendar API | PRODUCT_SPEC; CalendarSourceService | CAL-001, PRIV-004 | AUTO | P1 | COVERED | EventKit only |
| REQ-CAL-01 | EventKit full-access API used read-only by policy | PRODUCT_SPEC; CalendarSourceProviding/EventKitCalendarSource | CAL-001, PRIV-005 | AUTO | P0 | PARTIAL | Device confirms actual prompt/read |
| REQ-CAL-02 | Discover iOS-exposed sources/calendars | CalendarSourceService | CAL-002, DEV-001 | AUTO+DEV | P1 | PARTIAL | Provider compatibility needs device |
| REQ-CAL-03 | First discovery enables all; later new calendars default disabled | ARCHITECTURE; CalendarSelectionStore | CAL-003 | AUTO | P1 | COVERED | Missing calendar selection retained |
| REQ-CAL-04 | Per-calendar enable/disable controls event fetch | CalendarSourceCoordinator | CAL-004, REC-006, UI-008 | AUTO+SIM | P0 | PARTIAL | Visual control pending current run |
| REQ-CAL-05 | Bounded event retrieval is sorted and read-only | CalendarSourceService | CAL-005, CAL-006 | AUTO | P1 | COVERED | Fetch errors propagate |
| REQ-CAL-06 | All-day fact preserved and excluded from alarms | DOMAIN_RULES; mapper/rule engine | CAL-007, RULE-007, REC-005 | AUTO | P0 | COVERED | UI claim also checked |
| REQ-CAL-07 | Changed/deleted events converge safely | DOMAIN_RULES; reconciliation | REC-003, REC-004, DEV-009, DEV-010 | AUTO+DEV | P0 | PARTIAL | Actual EventKit mutation pending |
| REQ-CAL-08 | Nil/unusual identifier is safe; fallback is deterministic and conservative | DOMAIN_RULES; CalendarDomainMapper | CAL-008, REC-013 | AUTO | P1 | COVERED | No fuzzy rebinding |
| REQ-CAL-09 | Zero calendars/no events/all-day-only states are truthful | Production UX; reconciliation | CAL-009, CAL-010, UI-009 | AUTO+SIM | P1 | PARTIAL | Current visual run required |
| REQ-RULE-01 | Alarm date is event start minus effective lead | DOMAIN_RULES; AlarmRuleEngine | RULE-001–005 | AUTO | P0 | COVERED | Explicit 10:00 matrix |
| REQ-RULE-02 | Supported leads are exactly 5/10/15/30/60 minutes; default 5 | DomainModels | RULE-001–005, RULE-009 | AUTO | P0 | COVERED | Stable raw values |
| REQ-RULE-03 | No override inherits default | DOMAIN_RULES; resolver | RULE-006 | AUTO | P0 | COVERED | Default changes follow through |
| REQ-RULE-04 | Custom event lead overrides default | DOMAIN_RULES; resolver | RULE-006 | AUTO | P0 | COVERED | 15 over 5 case |
| REQ-RULE-05 | OFF disables; reset restores inheritance | DOMAIN_RULES; override service | RULE-006, REC-007 | AUTO | P0 | COVERED | Persist-before-trigger tested |
| REQ-RULE-06 | Only `alarmDate > now` is eligible; equality/past excluded | DOMAIN_RULES; AlarmRuleEngine | RULE-008 | AUTO | P0 | COVERED | Single injected now |
| REQ-RULE-07 | Absolute Date arithmetic; timezone/DST does not reinterpret instant | DOMAIN_RULES | TIME-001, TIME-002 | AUTO+DEV | P0 | PARTIAL | Device timezone smoke pending |
| REQ-RULE-08 | Invalid/obsolete local lead state fails closed | DOMAIN_RULES; Codable enum/SwiftData | RULE-009, REC-014 | AUTO+STATIC | P1 | PARTIAL | Destructive store injection manual only |
| REQ-ALARM-01 | Authorized fixed one-shot AlarmKit schedule | AlarmSchedulingService | ALARM-001, DEV-001, DEV-002 | AUTO+DEV | P0 | PARTIAL | Actual fire pending |
| REQ-ALARM-02 | Stable UUID mapping and duplicate prevention | DOMAIN_RULES; scheduling coordinator | ALARM-002, REC-002 | AUTO | P0 | COVERED | Concurrent identical calls included |
| REQ-ALARM-03 | Changed date cancels/replaces using stable UUID | AlarmSchedulingService | ALARM-003, REC-003 | AUTO | P0 | COVERED | Device confirmation pending separately |
| REQ-ALARM-04 | Cancellation removes mapping only after system success | AlarmSchedulingService | ALARM-004, ALARM-007 | AUTO | P0 | COVERED | Failure retains recovery state |
| REQ-ALARM-05 | Schedule failure creates no false mapping | AlarmSchedulingService | ALARM-005 | AUTO | P0 | COVERED | Truthful failure |
| REQ-ALARM-06 | Replacement failure retains old metadata and reports recovery | DOMAIN_RULES; scheduling coordinator | ALARM-006 | AUTO | P0 | COVERED | Old system alarm was cancelled; retry required |
| REQ-ALARM-07 | Stale/missing/orphan system divergence recovered | DOMAIN_RULES; planner | REC-008–010 | AUTO | P0 | COVERED | Physical observation pending |
| REQ-ALARM-08 | Alarm authorization states block scheduling without prompting | PermissionServices; scheduler | PERM-005–007, ALARM-008 | AUTO+DEV | P0 | PARTIAL | System prompt/revocation pending |
| REQ-ALARM-09 | Exact nonblank title; blank/whitespace fallback `予定` | PROJECT_STATE; scheduling service | ALARM-009, ALARM-010, DEV-003, DEV-004 | AUTO+DEV | P1 | PARTIAL | System presentation pending |
| REQ-ALARM-10 | V1 has stop/dismiss but no snooze product UI | AlarmKitSystemScheduler; PRODUCT_SPEC exclusions | ALARM-011, DEV-008 | STATIC+DEV | P1 | PARTIAL | System behavior pending |
| REQ-ALARM-11 | Capacity/platform errors are typed partial results | DOMAIN_RULES; reconciliation | REC-011 | AUTO | P0 | COVERED | No numeric capacity assumed |
| REQ-REC-01 | Foreground launch/resume reconciles fresh truth | ARCHITECTURE; FoundationRootView | LIFE-001, LIFE-002, DEV-005 | AUTO+DEV | P0 | PARTIAL | Actual lifecycle pending |
| REQ-REC-02 | EventKit store change triggers refetch/reconcile | ARCHITECTURE; FoundationRootView | LIFE-003, DEV-009 | STATIC+DEV | P0 | PARTIAL | Actual notification pending |
| REQ-REC-03 | Added/changed/deleted/disabled events converge | DOMAIN_RULES; coordinator | REC-001, REC-003–007 | AUTO | P0 | COVERED | Device proof pending where applicable |
| REQ-REC-04 | Repeated unchanged passes are idempotent | DOMAIN_RULES | REC-002 | AUTO | P0 | COVERED | One candidate/mapping/alarm |
| REQ-REC-05 | Concurrent triggers serialize/coalesce and dirty trigger follows | ARCHITECTURE; coordinator actor | REC-012 | AUTO | P0 | COVERED | Cancellation case included |
| REQ-REC-06 | Active scheduling horizon is fresh 14-day `[now,end)` | DOMAIN_RULES; ReconciliationWindow | TIME-005 | AUTO | P0 | COVERED | Exact half-open boundary |
| REQ-REC-07 | Absence retires only mappings owned by current window | DOMAIN_RULES; planner | TIME-005, REC-015 | AUTO | P0 | COVERED | Out-of-window preserved |
| REQ-REC-08 | Calendar denial/read failure preserves mappings and alarms | DOMAIN_RULES; coordinator | PERM-004, REC-016 | AUTO | P0 | COVERED | No mass destruction |
| REQ-REC-09 | Fired/past missing alarm cleanup and future recovery | DOMAIN_RULES | REC-008, REC-009 | AUTO | P0 | COVERED | Stable UUID recovery |
| REQ-REC-10 | Missing calendar preserves selection; reappearance restores | DOMAIN_RULES; selection store | CAL-003 | AUTO | P1 | COVERED | Different ID inherits nothing |
| REQ-REC-11 | Override/default/calendar mutations trigger same coordinator | service boundaries | REC-006, REC-007 | AUTO | P0 | COVERED | No parallel scheduling path |
| REQ-REC-12 | Best-effort background uses same path and never guarantees timing | ARCHITECTURE; ReliabilityService | LIFE-004, LIFE-005 | AUTO+BEST | P1 | PARTIAL | System execution timing device-only |
| REQ-PERM-01 | Calendar notDetermined requests once and refreshes authority immediately | PROJECT_STATE; onboarding sequence | PERM-001, ONB-002 | AUTO+DEV | P0 | PARTIAL | Real prompt pending |
| REQ-PERM-02 | Calendar granted refreshes data/UI without foreground round trip | PROJECT_STATE; ProductionUXView | PERM-002, DEV-001 | AUTO+DEV | P0 | PARTIAL | Device proof pending |
| REQ-PERM-03 | Calendar denied/revoked UI truthful, recoverable, no crash/mass cancel | DOMAIN_RULES; UX | PERM-003, PERM-004, DEV-011 | AUTO+SIM+DEV | P0 | PARTIAL | Revocation device-only |
| REQ-PERM-04 | Alarm notDetermined requests once; granted/denied truth refreshed | PROJECT_STATE; onboarding | PERM-005, PERM-006 | AUTO+DEV | P0 | PARTIAL | Real prompt pending |
| REQ-PERM-05 | Alarm denial/revocation blocks schedule and offers recovery | DOMAIN_RULES; UX | PERM-007, DEV-011 | AUTO+DEV | P0 | PARTIAL | Existing intent retained |
| REQ-PERM-06 | Restricted/unavailable states map truthfully | PermissionServices | PERM-008 | AUTO | P1 | COVERED | System reproduction environment-dependent |
| REQ-PERM-07 | Permission prompts never arise from lifecycle/background | ARCHITECTURE | PERM-009, LIFE-004 | AUTO+DEV | P0 | PARTIAL | Device observation pending |
| REQ-ONB-01 | First launch starts Calendar rationale; no obsolete Welcome | PROJECT_STATE; UX models/views | ONB-001 | AUTO+SIM | P1 | PARTIAL | Current visual run required |
| REQ-ONB-02 | Calendar then Alarm rationale/request order | PROJECT_STATE | ONB-002, ONB-003 | AUTO+SIM | P1 | PARTIAL | Real prompt device-only |
| REQ-ONB-03 | Completion persists independently of denial | PROJECT_STATE; UserDefaults store | ONB-004 | AUTO | P1 | COVERED | Denial cannot trap user |
| REQ-ONB-04 | Later revocation never replays onboarding | PROJECT_STATE; route policy | ONB-005 | AUTO+DEV | P1 | PARTIAL | Device revocation pending |
| REQ-ONB-05 | Completed app exposes Settings recovery | Production UX | ONB-006, UI-007 | AUTO+SIM | P1 | PARTIAL | Visual verification pending |
| REQ-UI-01 | Root tabs are `アラーム` and `設定` | PROJECT_STATE; ProductionUXView | UI-001 | AUTO+SIM | P1 | PARTIAL | Current visual run required |
| REQ-UI-02 | Timeline is Today-first; yesterday/older excluded; earlier today retained | PROJECT_STATE; presentation policy | UI-002, UI-003 | AUTO+SIM | P1 | PARTIAL | Past fetch overlap remains internal |
| REQ-UI-03 | Future dates and day grouping are chronological | presentation policy | UI-003, TIME-003 | AUTO+SIM | P1 | PARTIAL | Today section always present |
| REQ-UI-04 | Current-time divider and return action are presentation-only | QA_CHECKLIST; presentation clock | UI-004, LIFE-006 | AUTO+SIM | P1 | PARTIAL | No scheduling from tick |
| REQ-UI-05 | Rows show title, start, exact alarm/status and completed appearance | QA_CHECKLIST; UX policy/view | UI-005 | AUTO+SIM | P1 | PARTIAL | Calendar label remains semantic |
| REQ-UI-06 | Detail shows default/custom/OFF and supports override/reset | Production UX | UI-006, RULE-006 | AUTO+SIM | P1 | PARTIAL | Mutation effects automated |
| REQ-UI-07 | Calendar selection and Settings are coherent | Production UX | UI-007, UI-008 | AUTO+SIM | P1 | PARTIAL | Current manual run required |
| REQ-UI-08 | Empty/error/permission states truthful and recoverable | Production UX | UI-009, PERM-003 | AUTO+SIM | P1 | PARTIAL | Deterministic DEBUG scenarios only |
| REQ-UI-09 | Sticky header/top surface opaque; no bleed/gap/flash/jump | PROJECT_STATE; ProductionUXView | UI-010 | SIM | P1 | MANUAL ONLY | Historical evidence is not current PASS |
| REQ-TIME-01 | Display follows current locale/timezone; identity uses absolute instants | DOMAIN_RULES | TIME-001, TIME-002 | AUTO+DEV | P0 | PARTIAL | Device change pending |
| REQ-TIME-02 | Midnight grouping uses `Calendar.startOfDay`; no previous-day group | presentation policy | TIME-003 | AUTO+SIM | P1 | PARTIAL | Near-midnight visual smoke pending |
| REQ-TIME-03 | Day/timezone/significant-time changes refetch/reconcile | ReliabilityPolicy/FoundationRootView | TIME-004, DEV-012 | AUTO+DEV | P0 | PARTIAL | Notification configuration automated |
| REQ-TIME-04 | Minute presentation refresh is active-only and side-effect free | presentation clock | LIFE-006 | AUTO | P1 | COVERED | No fetch/persist/schedule dependencies |
| REQ-TIME-05 | DST elapsed subtraction is absolute | DOMAIN_RULES | TIME-002 | AUTO | P0 | COVERED | Calendar display may change, instant does not |
| REQ-PRIV-01 | No personal data transmitted; no network dependency | PRODUCT_SPEC; source/project audit | PRIV-001, PRIV-004 | AUTO+DEV | P0 | PARTIAL | Network observation optional confirmation |
| REQ-PRIV-02 | Only local app-owned settings/selections/overrides/mappings persisted | ARCHITECTURE; Persistence | PRIV-006 | AUTO | P0 | COVERED | Event content not persisted |
| REQ-PRIV-03 | PrivacyInfo and usage descriptions match behavior | PrivacyInfo.xcprivacy; Info.plist | PRIV-007 | AUTO | P0 | COVERED | Build bundle recheck required |
| REQ-PRIV-04 | No sensitive values/test scenarios leak into Release | DEBUG gating; build artifact audit | PRIV-008 | AUTO | P0 | PARTIAL | Release artifact scan required |
| REQ-A11Y-01 | Core controls/rows have semantic VoiceOver labels and non-color status | QA_CHECKLIST; accessibility IDs | A11Y-001, A11Y-002, DEV-006 | AUTO+DEV | P1 | PARTIAL | Real VoiceOver pending |
| REQ-A11Y-02 | Dynamic Type, readability, tap targets, no clipping/truncation | QA_CHECKLIST | A11Y-003, A11Y-004 | SIM+DEV | P1 | MANUAL ONLY | Accessibility Inspector/device pending |
| REQ-A11Y-03 | Japanese-first app copy; system/source text not mistranslated | PROJECT_STATE | A11Y-005 | AUTO+SIM | P1 | PARTIAL | Source names remain verbatim |
| REQ-A11Y-04 | Light/dark appearance supported without contrast/layout regression | QA_CHECKLIST | A11Y-006 | SIM+DEV | P2 | MANUAL ONLY | Human inspection required |
| REQ-REL-01 | Actual AlarmKit system presentation/title/stop behavior | PRODUCT_SPEC; scheduler | DEV-001–008 | DEV | P0 | DEVICE ONLY | Not inferable from unit tests |
| REQ-REL-02 | Changed/deleted events do not later fire stale alarms | DOMAIN_RULES | DEV-009, DEV-010 | DEV | P0 | DEVICE ONLY | Release-critical |
| REQ-REL-03 | Multiple upcoming alarms remain distinct | DOMAIN_RULES | DEV-013 | DEV | P0 | DEVICE ONLY | Capacity not assumed |
| REQ-REL-04 | Paired Apple Watch behavior is native system behavior only | PRODUCT_SPEC | DEV-014 | BEST | P2 | NOT TESTABLE IN CURRENT ENVIRONMENT | No watchOS target |

## 7. Deterministic synthetic test data

Use a dedicated local calendar named `AgendaCue QA` and never real user information. Freeze `now = 2026-08-25 09:00:00` in the selected timezone unless a case says otherwise.

| Data ID | Event | Start / end | Calendar | Special state |
|---|---|---|---|---|
| D01 | チーム定例 | Aug 25 10:00–10:30 | QA | North Star, stable ID `evt-team-1` |
| D02 | 歯科検診 | Aug 25 13:00–14:00 | QA | custom 15 min |
| D03 | オンライン面談 | Aug 26 11:00–11:45 | QA | future day |
| D04 | 企画レビュー | Aug 30 16:00–17:00 | QA | horizon interior |
| D05 | 移動 | Aug 25 08:30–09:00 | QA | earlier today/past alarm |
| D06 | 昼食 | Aug 25 00:03–00:30 | QA | lead crosses midnight |
| D07 | 終日イベント | Aug 25 all day | QA | all-day exclusion |
| D08 | `   ` | Aug 25 15:00–15:30 | QA | whitespace title fallback |
| D09/D10 | チーム定例 | Aug 27 10:00 and 14:00 | QA | duplicate titles, distinct IDs |
| D11 | 変更対象 | initially 10:00, then 11:00 | QA | mutation/replacement |
| D12 | 削除対象 | Aug 25 17:00 | QA | schedule then delete |
| D13 | 無効カレンダー予定 | Aug 25 18:00 | QA Disabled | calendar disable |

Boundary data is generated as absolute `Date` values at `now`, `now + horizon - 1 second`, `now + horizon`, and `now + horizon + 1 second`. For presentation-midnight tests, use 23:59, 00:00 and 00:01 around a local day transition. Duplicate titles must never share identity.

## 8. Test case protocol

Each case below includes every required field in compact form. Common failure criteria for all cases: crash, hang, false success/state, duplicate data/alarm, silent persistence corruption, calendar mutation, or result differing from the stated expectation. Common evidence: command/log for AUTO; timestamped screenshot/video plus setup notes for SIM/DEV. Environment requirements are the classification in §5 plus any case-specific condition.

### Calendar and rule engine

**CAL-001 — Read-only EventKit boundary.** Purpose: prove provider neutrality/read-only API. Requirements: REQ-CAL-01, REQ-PLAT-04. Priority: P0. Level/class: static integration/AUTO. Preconditions/data: current source and project. Steps: inspect imports, `CalendarSourceProviding`, concrete EventKit adapter, and search for EventKit save/remove/mutation calls. Expected: EventKit-only discovery/fetch/authorization; no calendar mutation surface or provider SDK. Failure: any reachable write/provider API. Evidence: search output and cited files. Environment: source checkout. Notes: EventKit permission API name `fullAccess` does not authorize app-policy writes.

**CAL-002 — Source and calendar discovery.** Purpose: map source metadata correctly. Requirements: REQ-CAL-02. Priority: P1. Level/class: unit/AUTO. Preconditions/data: synthetic descriptors from iCloud/local-style sources. Steps: discover and map descriptors. Expected: IDs/titles/source facts preserved and sorted as implemented. Failure: loss/collision/mutation. Evidence: XCTest. Environment: test host. Notes: real providers require DEV-001.

**CAL-003 — Selection lifecycle.** Purpose: verify initial enable, disable, new/missing/reappearing calendars. Requirements: REQ-CAL-03, REQ-REC-10. Priority: P1. Level/class: unit/AUTO. Preconditions/data: calendars A/B then A/C then A/B/C. Steps: discover, disable B, rediscover with B missing/C new, restore B. Expected: initial set enabled; B remains disabled/missing selection retained; C defaults disabled; B restoration retains intent. Failure: unexpected enabling or selection deletion. Evidence: XCTest. Environment: test host. Notes: identifier-specific.

**CAL-004 — Enabled identifiers constrain fetch.** Purpose: prevent disabled-calendar scheduling. Requirements: REQ-CAL-04. Priority: P0. Level/class: integration/AUTO. Preconditions/data: D01 and D13. Steps: enable QA only; fetch interval. Expected: adapter receives only enabled IDs and D13 does not enter snapshot. Failure: disabled calendar queried/candidate created. Evidence: XCTest. Environment: mocks. Notes: reconciliation cancel is REC-006.

**CAL-005 — Event mapping/sorting.** Purpose: preserve event facts deterministically. Requirements: REQ-CAL-05. Priority: P1. Level/class: unit/AUTO. Preconditions/data: unordered D09/D10 plus all-day and nil-ID facts. Steps: map then sort twice. Expected: start/ID order; title/start/end/all-day/calendar/optional identifier exact. Failure: unstable order or altered facts. Evidence: XCTest. Environment: test host. Notes: no EventKit object persistence.

**CAL-006 — Fetch error propagation.** Purpose: keep untrusted failure distinct from empty truth. Requirements: REQ-CAL-05, REQ-REC-08. Priority: P0. Level/class: integration/AUTO. Preconditions/data: source throws permission/read error. Steps: fetch through coordinator and reconciliation. Expected: typed failure/block; no crash or destructive diff. Failure: empty snapshot treated as deletion. Evidence: XCTest. Environment: mocks. Notes: see REC-016.

**CAL-007 — All-day mapping.** Purpose: preserve EventKit all-day signal. Requirements: REQ-CAL-06. Priority: P0. Level/class: unit/AUTO. Preconditions/data: D07. Steps: map snapshot. Expected: `isAllDay == true`, start not reinterpreted. Failure: clock time synthesized. Evidence: XCTest. Environment: test host. Notes: scheduling exclusion RULE-007.

**CAL-008 — Nil identifier fallback.** Purpose: ensure safety and conservative identity. Requirements: REQ-CAL-08. Priority: P1. Level/class: unit/AUTO. Preconditions/data: nil identifier with fixed calendar/start/title. Steps: map twice; then change title/time. Expected: deterministic same-facts ID; edit may change fallback; no force unwrap/fuzzy bind. Failure: crash or unrelated override attachment. Evidence: XCTest. Environment: test host. Notes: stable EventKit IDs survive fact edits.

**CAL-009 — Zero enabled calendars/no events.** Purpose: truthful empty state. Requirements: REQ-CAL-09. Priority: P1. Level/class: integration+UI/AUTO+SIM. Preconditions/data: none enabled, then enabled with no events. Steps: refresh each state. Expected: no candidates/duplicates/crash; appropriate Japanese empty state. Failure: error presented as success or stale rows. Evidence: XCTest plus screenshot. Environment: controllable simulator. Notes: no permission prompt.

**CAL-010 — Only all-day events.** Purpose: show events without claiming alarms. Requirements: REQ-CAL-09, REQ-CAL-06. Priority: P1. Level/class: integration+UI/AUTO+SIM. Preconditions/data: D07 only. Steps: refresh timeline and reconcile. Expected: visible read-only event where in display window; zero alarm candidates; explicit no-alarm copy. Failure: schedule/ambiguous copy. Evidence: XCTest/screenshot. Environment: controllable simulator.

**RULE-001 — 10:00 with 5-minute lead.** Purpose: North Star. Requirements: REQ-RULE-01/02. Priority: P0. Level/class: unit/AUTO. Preconditions/data: D01, now 08:00. Steps: evaluate lead 5. Expected: candidate at 09:55, delta 300s. Failure: any other instant/exclusion. Evidence: XCTest. Environment: injected clock/GMT calendar. Notes: exact Date assertion.

**RULE-002 — 10:00 with 10-minute lead.** Purpose/requirements/preconditions/steps/evidence/environment: as RULE-001 with lead 10. Priority: P0. Level/class: unit/AUTO. Expected: 09:50, delta 600s. Failure: mismatch. Notes: supported lead.

**RULE-003 — 10:00 with 15-minute lead.** Purpose/requirements/preconditions/steps/evidence/environment: as RULE-001 with lead 15. Priority: P0. Level/class: unit/AUTO. Expected: 09:45, delta 900s. Failure: mismatch. Notes: custom-lead exemplar.

**RULE-004 — 10:00 with 30-minute lead.** Purpose/requirements/preconditions/steps/evidence/environment: as RULE-001 with lead 30. Priority: P0. Level/class: unit/AUTO. Expected: 09:30, delta 1800s. Failure: mismatch. Notes: supported lead.

**RULE-005 — 10:00 with 60-minute lead.** Purpose/requirements/preconditions/steps/evidence/environment: as RULE-001 with lead 60. Priority: P0. Level/class: unit/AUTO. Expected: 09:00, delta 3600s. Failure: mismatch. Notes: supported lead.

**RULE-006 — Override precedence/reset.** Purpose: deterministic effective lead. Requirements: REQ-RULE-03–05. Priority: P0. Level/class: unit/integration AUTO. Preconditions/data: default 5, D01. Steps: evaluate no override; custom 15; OFF; reset. Expected: alarms 09:55, 09:45, none, 09:55; persistence mutation precedes one reconciliation trigger. Failure: wrong precedence/stale override/duplicate trigger. Evidence: XCTest. Environment: in-memory stores. Notes: explicit ON without custom inherits default.

**RULE-007 — All-day exclusion.** Purpose: never schedule all-day. Requirements: REQ-CAL-06. Priority: P0. Level/class: unit/integration AUTO. Preconditions/data: D07. Steps: evaluate and reconcile with/without explicit ON. Expected: `.allDay`, zero schedule; existing owned alarm cancelled. Failure: any candidate/schedule. Evidence: XCTest. Environment: mocks. Notes: ON cannot bypass eligibility.

**RULE-008 — Future/equality/past eligibility.** Purpose: enforce strict boundary. Requirements: REQ-RULE-06. Priority: P0. Level/class: unit/AUTO. Preconditions/data: fixed now; events whose calculated alarm is now+1s, now, now-1s. Steps: evaluate using one injected now. Expected: candidate only for now+1s. Failure: equality or past schedules. Evidence: XCTest. Environment: test host. Notes: `>` not `>=`.

**RULE-009 — Supported/default/invalid lead state.** Purpose: constrain domain values. Requirements: REQ-RULE-02/08. Priority: P1. Level/class: unit+static/AUTO. Preconditions/data: enum and persistence schema. Steps: enumerate raw values/default; inspect decode path for obsolete value. Expected: exactly 5/10/15/30/60, default 5; unsupported value cannot create valid candidate. Failure: unexpected lead or unsafe fallback schedule. Evidence: XCTest/source audit. Environment: test host. Notes: destructive migration injection is not required for release run.

### Alarm scheduling and reconciliation

**ALARM-001 — New schedule transaction.** Purpose: system-before-persistence correctness. Requirements: REQ-ALARM-01. Priority: P0. Level/class: service/AUTO. Preconditions/data: authorized, no mapping, D01 candidate. Steps: schedule. Expected: one fixed-date system call with exact date/title then one UUID mapping. Failure: persistence first/duplicate/wrong data. Evidence: XCTest. Environment: mock AlarmKit boundary. Notes: actual firing DEV-002.

**ALARM-002 — Duplicate prevention.** Purpose: at most one alarm. Requirements: REQ-ALARM-02. Priority: P0. Level/class: concurrency/AUTO. Preconditions/data: unchanged candidate. Steps: schedule twice sequentially and concurrently. Expected: one system schedule, one mapping, same UUID; later result no-op. Failure: duplicate. Evidence: XCTest. Environment: actor/mocks. Notes: also REC-002.

**ALARM-003 — Replacement uses stable identity.** Purpose: change schedule safely. Requirements: REQ-ALARM-03. Priority: P0. Level/class: service/AUTO. Preconditions/data: D11 initially 10:00/09:55. Steps: schedule; change to 11:00; reschedule. Expected: cancel old UUID, schedule same UUID 10:55, update mapping after success. Failure: old alarm retained or second UUID. Evidence: XCTest. Environment: mocks.

**ALARM-004 — Successful cancel.** Purpose: remove alarm and mapping. Requirements: REQ-ALARM-04. Priority: P0. Level/class: service/AUTO. Preconditions/data: mapped alarm. Steps: cancel by candidate ID. Expected: one system cancel, mapping removed after success; missing mapping is no-op. Failure: orphan mapping/alarm. Evidence: XCTest. Environment: mocks.

**ALARM-005 — Schedule failure.** Purpose: no false local success. Requirements: REQ-ALARM-05. Priority: P0. Level/class: negative/AUTO. Preconditions/data: system throws. Steps: schedule. Expected: error, no mapping, retry possible, no crash. Failure: fake mapping/silent success. Evidence: XCTest. Environment: failing mock.

**ALARM-006 — Replacement failure.** Purpose: truthful divergence recovery. Requirements: REQ-ALARM-06. Priority: P0. Level/class: negative/AUTO. Preconditions/data: existing mapping; cancel succeeds; replacement schedule fails. Steps: replace. Expected: `replacementRecoveryRequired`, old metadata retained, later pass can recover; no second mapping. Failure: metadata falsely updated/corrupted. Evidence: XCTest. Environment: failing mock. Notes: release UI must not claim updated active alarm.

**ALARM-007 — Cancel failure.** Purpose: retain retry state. Requirements: REQ-ALARM-04. Priority: P0. Level/class: negative/AUTO. Preconditions/data: existing mapping; cancel throws. Steps: cancel. Expected: mapping retained, failure reported, later retry possible. Failure: mapping removed despite unknown system state. Evidence: XCTest. Environment: failing mock.

**ALARM-008 — Authorization blocks.** Purpose: no schedule/request when not authorized. Requirements: REQ-ALARM-08. Priority: P0. Level/class: negative/AUTO. Preconditions/data: notDetermined/denied/restricted/unavailable. Steps: call schedule. Expected: typed authorization error, zero system schedule, zero mapping, no prompt. Failure: side effect or false active state. Evidence: XCTest. Environment: mocks.

**ALARM-009 — Exact source title.** Purpose: system display fidelity. Requirements: REQ-ALARM-09. Priority: P1. Level/class: service/AUTO. Preconditions/data: `歯医者 / Team Sync`. Steps: schedule. Expected: exact string, no prefix/suffix; date/identity unchanged. Failure: branding/calendar text added or wrong date. Evidence: XCTest. Environment: mock.

**ALARM-010 — Blank-title fallback.** Purpose: usable AlarmKit title. Requirements: REQ-ALARM-09. Priority: P1. Level/class: service/AUTO. Preconditions/data: D08 and newline-only variant. Steps: schedule. Expected title exactly `予定`. Failure: blank/whitespace/different fallback. Evidence: XCTest. Environment: mock.

**ALARM-011 — V1 AlarmKit presentation configuration.** Purpose: prevent unsupported snooze/product controls. Requirements: REQ-ALARM-10. Priority: P1. Level/class: static+device/AUTO+DEV. Preconditions/data: scheduler source/current build. Steps: inspect fixed schedule/alert buttons; on device fire alarm. Expected: one `停止` stop control, default sound/system presentation, no app snooze configuration. Failure: unsupported custom snooze/countdown semantics. Evidence: source audit and DEV-008 video. Environment: source+iPhone.

**REC-001 — Added event schedules.** Purpose: converge new truth. Requirements: REQ-REC-03. Priority: P0. Level/class: integration/AUTO. Preconditions/data: empty mappings then D01. Steps: reconcile. Expected: desired=1, scheduled=1, one mapping/system alarm. Failure: missing/duplicate. Evidence: XCTest. Environment: mocks.

**REC-002 — Repeated unchanged reconciliation.** Purpose: convergence/idempotency. Requirements: REQ-REC-04, REQ-ALARM-02. Priority: P0. Level/class: integration/AUTO. Preconditions/data: D01. Steps: run three passes unchanged, including close triggers. Expected: one candidate, mapping, UUID and system alarm; later operations keep/no-op. Failure: duplicates/contradiction. Evidence: XCTest.

**REC-003 — Event mutation replacement.** Purpose: replace stale time. Requirements: REQ-CAL-07, REQ-REC-03. Priority: P0. Level/class: integration/AUTO. Preconditions/data: D11 10:00/default 5. Steps: reconcile (09:55); edit start to 11:00; reconcile. Expected: old alarm removed/replaced, stable UUID at 10:55, one mapping/alarm. Failure: old/duplicate/wrong time. Evidence: XCTest.

**REC-004 — Event deletion.** Purpose: delete stale alarm. Requirements: REQ-CAL-07. Priority: P0. Level/class: integration/AUTO. Preconditions/data: D12 scheduled; trustworthy snapshot then omits D12. Steps: reconcile. Expected: system cancel and mapping removal; no orphan. Failure: later alarm/stale mapping. Evidence: XCTest.

**REC-005 — Event becomes ineligible.** Purpose: clean all-day/past/OFF transitions. Requirements: REQ-CAL-06, REQ-REC-03. Priority: P0. Level/class: integration/AUTO. Preconditions/data: mapped event. Steps: separately change to all-day, move alarm <= now, set OFF; reconcile. Expected: owned future mapping cancelled/removed for each. Failure: stale alarm. Evidence: XCTest.

**REC-006 — Calendar disable.** Purpose: remove disabled-calendar alarms. Requirements: REQ-CAL-04, REQ-REC-11. Priority: P0. Level/class: integration/AUTO. Preconditions/data: D13 scheduled while calendar enabled. Steps: disable calendar through service; reconciliation fetch returns no D13. Expected: selection persists disabled; associated owned alarm cancelled/mapping removed. Failure: stale alarm or calendar write. Evidence: XCTest.

**REC-007 — Override/default mutations.** Purpose: converge user intent. Requirements: REQ-RULE-05, REQ-REC-11. Priority: P0. Level/class: integration/AUTO. Preconditions/data: D01 mapped default 5. Steps: custom 15, OFF, ON/reset, default change. Expected: replacement/cancel/schedule using same coordinator and stable identity; idempotent after convergence. Failure: wrong precedence/duplicate. Evidence: XCTest.

**REC-008 — Mapping exists, future alarm missing.** Purpose: repair system divergence. Requirements: REQ-ALARM-07, REQ-REC-09. Priority: P0. Level/class: integration/AUTO. Preconditions/data: desired future candidate and mapping, UUID absent from system. Steps: reconcile. Expected: reschedule exact candidate with same UUID; update metadata. Failure: new UUID/duplicate/missing recovery. Evidence: XCTest.

**REC-009 — Missing fired/past alarm.** Purpose: clean obsolete persistence. Requirements: REQ-REC-09. Priority: P0. Level/class: integration/AUTO. Preconditions/data: expired mapping absent from system, candidate undesired/expired. Steps: reconcile. Expected: remove mapping only; no schedule. Failure: resurrect past alarm. Evidence: XCTest.

**REC-010 — Alarm exists but event/mapping missing.** Purpose: orphan cleanup. Requirements: REQ-ALARM-07. Priority: P0. Level/class: integration/AUTO. Preconditions/data: app-visible system UUID with no mapping/event. Steps: reconcile trustworthy snapshot. Expected: deterministic orphan cancel; no fabricated mapping. Failure: orphan remains/silent corruption. Evidence: XCTest.

**REC-011 — Capacity/operation partial failure.** Purpose: preserve independent successes. Requirements: REQ-ALARM-11. Priority: P0. Level/class: negative/AUTO. Preconditions/data: multiple ordered candidates; one capacity/schedule failure. Steps: reconcile. Expected: earliest successes persist; failed item unpersisted; typed issue; independent later operations continue where safe; retry converges. Failure: rollback corruption/fake success/crash. Evidence: XCTest.

**REC-012 — Concurrent triggers/coalescing.** Purpose: serialize truth changes. Requirements: REQ-REC-05. Priority: P0. Level/class: concurrency/AUTO. Preconditions/data: blocked first snapshot then second trigger. Steps: fire multiple triggers close together; release first; also cancel pass with dirty trigger. Expected: one pass at a time and one follow-up using latest request; no duplicates/lost trigger. Failure: overlap/contradictory work. Evidence: XCTest.

**REC-013 — Identifier mutation safety.** Purpose: avoid wrong override binding. Requirements: REQ-CAL-08. Priority: P1. Level/class: unit/integration AUTO. Preconditions/data: stable-ID edit and nil-ID edit. Steps: change title/time. Expected: stable ID retains intent; fallback may orphan old override; no fuzzy attachment to another event. Failure: unrelated binding/crash. Evidence: XCTest.

**REC-014 — Malformed/obsolete local state.** Purpose: fail safely. Requirements: REQ-RULE-08. Priority: P1. Level/class: static/manual/AUTO. Preconditions/data: current SwiftData models and enum encoding. Steps: inspect schema/defaults and unsupported decode behavior; if a disposable store harness exists inject obsolete values. Expected: no invalid candidate, crash, duplicate or silent rewrite. Failure: unsafe schedule/corruption. Evidence: source/test log. Environment: disposable store only. Notes: no production store mutation.

**REC-015 — Window ownership.** Purpose: avoid false deletion outside pass. Requirements: REQ-REC-07. Priority: P0. Level/class: unit/AUTO. Preconditions/data: mappings just inside and outside `[start,end)`. Steps: reconcile absent desired set. Expected: cancel/remove only owned interior mappings; preserve outside. Failure: out-of-window destructive inference. Evidence: XCTest.

**REC-016 — Calendar read failure.** Purpose: preserve alarms when truth unavailable. Requirements: REQ-REC-08. Priority: P0. Level/class: negative/AUTO. Preconditions/data: existing mappings/system alarms; permission authorized but snapshot throws. Steps: reconcile. Expected: blocked `calendarReadFailed`, zero diff operations, state retained, recoverable next pass. Failure: mass cancel or current-state claim. Evidence: XCTest. Environment: throwing mock. Notes: add automation if not directly distinguished by existing coverage.

### Permissions, onboarding, UI, time, lifecycle

**PERM-001 — Calendar first grant authority refresh.** Purpose: no foreground round trip. Requirements: REQ-PERM-01. Priority: P0. Level/class: unit+device/AUTO+DEV. Preconditions/data: notDetermined; request mock returns stale value but authoritative provider becomes authorized. Steps: request during onboarding; reread provider. Expected: one request; observable authorized state immediately. Failure: stale UI/repeated prompt. Evidence: XCTest and device video.

**PERM-002 — Calendar grant reloads data.** Purpose: newly authorized content appears. Requirements: REQ-PERM-02. Priority: P0. Level/class: integration/device AUTO+DEV. Preconditions/data: notDetermined with D01 available after grant. Steps: grant. Expected: discover/fetch refresh before advancing; D01 appears without app foreground cycle. Failure: empty/stale UI. Evidence: orchestration test/device video.

**PERM-003 — Calendar denied UI/recovery.** Purpose: truthful denial flow. Requirements: REQ-PERM-03. Priority: P0. Level/class: presentation/SIM+AUTO. Preconditions/data: denied. Steps: launch/refresh; open recovery. Expected: Japanese denied state, Settings path, no crash/re-prompt/data-current claim. Failure: lie/trap. Evidence: screenshot/static XCTest. Environment: simulator state.

**PERM-004 — Calendar later revoked.** Purpose: preserve inaccessible truth. Requirements: REQ-PERM-03, REQ-REC-08. Priority: P0. Level/class: integration/device AUTO+DEV. Preconditions/data: granted, existing alarm/mapping, onboarding complete; revoke in Settings. Steps: foreground/reconcile. Expected: denied UI; reconciliation blocked before fetch/diff; no mass destruction; onboarding stays complete; recovery path. Failure: crash/cancel-all/replay onboarding. Evidence: XCTest/device video.

**PERM-005 — Alarm first grant.** Purpose: authoritative Alarm state refresh. Requirements: REQ-PERM-04. Priority: P0. Level/class: unit+device AUTO+DEV. Preconditions/data: notDetermined. Steps: request in Alarm rationale. Expected: one request and immediate authoritative state. Failure: repeated prompt/stale state. Evidence: XCTest/device video.

**PERM-006 — Alarm denied during onboarding.** Purpose: denial does not trap. Requirements: REQ-PERM-04. Priority: P0. Level/class: presentation/device AUTO+DEV. Preconditions/data: notDetermined then deny. Steps: request, deny, complete. Expected: denial shown truthfully; completion available/persists; no schedule claim. Failure: block/re-prompt/lie. Evidence: XCTest/device video.

**PERM-007 — Alarm revoked after scheduling.** Purpose: safe blocked scheduling. Requirements: REQ-PERM-05. Priority: P0. Level/class: integration/device AUTO+DEV. Preconditions/data: authorized with intent/mappings; revoke. Steps: foreground/reconcile and edit override. Expected: UI denied/recovery; scheduling blocked; local user intent may persist; no prompt/crash/false active claim. Failure: corruption or false schedule. Evidence: XCTest/device video.

**PERM-008 — Restricted/unavailable mappings.** Purpose: cover all states. Requirements: REQ-PERM-06. Priority: P1. Level/class: unit/AUTO. Preconditions/data: platform authorization enums. Steps: map each Calendar/Alarm state. Expected: exact `PermissionState`; Japanese status text truthful. Failure: authorized/denied conflation. Evidence: XCTest.

**PERM-009 — No implicit permission prompts.** Purpose: lifecycle/background safety. Requirements: REQ-PERM-07. Priority: P0. Level/class: boundary/AUTO+DEV. Preconditions/data: notDetermined. Steps: launch, resume, time/store/background triggers without tapping rationale action. Expected: zero request calls/prompts. Failure: automatic prompt. Evidence: mock counts/device observation.

**ONB-001 — First launch Calendar rationale/no Welcome.** Purpose: correct first screen. Requirements: REQ-ONB-01. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: clean install. Steps: launch. Expected: Calendar rationale first; no obsolete Welcome. Failure: wrong/replayed stage. Evidence: route XCTest+screenshot.

**ONB-002 — Calendar authorization flow.** Purpose: correct first request/advance. Requirements: REQ-ONB-02. Priority: P1. Level/class: presentation/SIM+DEV. Preconditions/data: ONB-001. Steps: tap Calendar action; grant or deny. Expected: request only if notDetermined, authoritative refresh/data reload, then Alarm rationale. Failure: skip/double request/stale UI. Evidence: video.

**ONB-003 — Alarm authorization flow.** Purpose: correct second request/completion. Requirements: REQ-ONB-02. Priority: P1. Level/class: presentation/SIM+DEV. Preconditions/data: Alarm rationale. Steps: tap Alarm action; grant or deny; complete. Expected: authoritative result and main tabs. Failure: trap/lie. Evidence: video.

**ONB-004 — Denial-independent completion.** Purpose: onboarding is education, not permission state. Requirements: REQ-ONB-03. Priority: P1. Level/class: unit/SIM. Preconditions/data: both denied. Steps: complete; terminate/relaunch. Expected: main app remains; recovery UI used. Failure: onboarding repeats. Evidence: XCTest/screenshot.

**ONB-005 — Later revocation does not replay.** Purpose: stable routing. Requirements: REQ-ONB-04. Priority: P1. Level/class: unit+device AUTO+DEV. Preconditions/data: completed, granted then revoked. Steps: relaunch. Expected: main route with recovery, never onboarding. Failure: replay/reset. Evidence: XCTest/device screenshot.

**ONB-006 — Settings recovery.** Purpose: actionable completed-user path. Requirements: REQ-ONB-05. Priority: P1. Level/class: SIM+DEV. Preconditions/data: denied completed user. Steps: open Settings tab and recovery control. Expected: accurate status and system Settings path. Failure: dead/misleading control. Evidence: screenshot/video.

**UI-001 — Root navigation tabs.** Purpose: Production navigation. Requirements: REQ-UI-01. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: completed onboarding. Steps: launch and switch tabs. Expected: exactly `アラーム` and `設定`; navigation state stable. Failure: obsolete third tab/feasibility UI. Evidence: XCTest+screenshot.

**UI-002 — Today-first timeline.** Purpose: immediate relevance. Requirements: REQ-UI-02. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: yesterday, D05, D01, D03. Steps: open Alarm tab. Expected: first visible group Today; yesterday excluded; earlier/later Today retained. Failure: previous-day group or hidden earlier Today. Evidence: XCTest+screenshot.

**UI-003 — Future groups/day boundary.** Purpose: deterministic chronology. Requirements: REQ-UI-02/03. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: 23:59/00:00/00:01 and D03. Steps: inspect sections/scroll. Expected: chronological Today/Tomorrow/future labels from local calendar, no duplicate/lost event. Failure: wrong day grouping. Evidence: XCTest/screenshots.

**UI-004 — Current divider/sticky return.** Purpose: reliable temporal orientation. Requirements: REQ-UI-04. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: past/current/future Today events. Steps: open, scroll away, tap `現在へ`. Expected: divider placed deterministically; stable anchor; no forced scroll on ticks. Failure: wrong anchor/jump/duplicate divider. Evidence: XCTest/video.

**UI-005 — Row content/status.** Purpose: truthful scan hierarchy. Requirements: REQ-UI-05. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: future, earlier Today, all-day, OFF, long title. Steps: inspect rows. Expected: title/start/exact alarm or explicit state; completed/past not color-only; calendar included in accessibility label. Failure: wrong/ambiguous/truncated core meaning. Evidence: XCTest/screenshots.

**UI-006 — Event detail/default/custom/OFF.** Purpose: override UX. Requirements: REQ-UI-06. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: D01/D02 and OFF event. Steps: open each detail; toggle/set/reset. Expected: inherited default clearly labeled, custom clearly labeled, OFF explicit; navigation works; reconciliation follows mutation. Failure: ambiguous or wrong persisted intent. Evidence: XCTest/video.

**UI-007 — Settings.** Purpose: permission/default/calendar entry accuracy. Requirements: REQ-UI-07, REQ-ONB-05. Priority: P1. Level/class: presentation/AUTO+SIM. Preconditions/data: completed app. Steps: open Settings; inspect statuses/default; change default. Expected: current authority, supported leads, Calendar navigation; persistence+reconcile. Failure: stale state/unsupported lead. Evidence: XCTest/screenshot.

**UI-008 — Calendar selection.** Purpose: per-calendar control. Requirements: REQ-UI-07, REQ-CAL-04. Priority: P1. Level/class: presentation/SIM. Preconditions/data: multiple long-name calendars. Steps: open list; toggle one off/on; return. Expected: readable labels/tap controls, persisted state, correct refresh/reconcile. Failure: clipping/wrong toggle/stale alarms. Evidence: video/screenshots.

**UI-009 — Empty/error states.** Purpose: recoverability. Requirements: REQ-UI-08, REQ-CAL-09. Priority: P1. Level/class: presentation/SIM. Preconditions/data: deterministic empty, zero-calendar, fetch-error scenarios. Steps: open each and use retry. Expected: Japanese truthful copy; retry accessible; no stale/private/sample data. Failure: crash/false empty/error/leak. Evidence: screenshots/video.

**UI-010 — Sticky header opacity and stability.** Purpose: release polish. Requirements: REQ-UI-09. Priority: P1. Level/class: manual/SIM. Preconditions/data: multiple date groups, light and dark. Steps: slow/fast scroll headers under navigation bar and reverse direction. Expected: pinned header and top surface opaque, no bleed/transparent gap/flash/vertical jump. Failure: any artifact. Evidence: screen recording and stills. Environment: interactive Simulator. Notes: historical images do not constitute current execution.

**TIME-001 — Absolute Date across timezone change.** Purpose: preserve schedule instant. Requirements: REQ-RULE-07, REQ-TIME-01. Priority: P0. Level/class: unit+device AUTO+DEV. Preconditions/data: fixed absolute D01 date. Steps: evaluate; change display calendar timezone; refetch/reconcile. Expected: alarm absolute instant remains `start-300s`; formatted wall times change per current timezone only; no offset manually added. Failure: instant shifts by timezone delta. Evidence: XCTest/device before/after.

**TIME-002 — DST boundary.** Purpose: elapsed arithmetic. Requirements: REQ-TIME-05. Priority: P0. Level/class: unit/AUTO. Preconditions/data: absolute dates spanning spring/fall boundary. Steps: evaluate 60-minute lead in affected timezone. Expected: exact 3600-second subtraction, future gate based on absolute Date. Failure: 0/2-hour manual adjustment. Evidence: XCTest.

**TIME-003 — Local midnight.** Purpose: grouping and eligibility at day boundary. Requirements: REQ-TIME-02. Priority: P1. Level/class: unit+SIM AUTO+SIM. Preconditions/data: D06 plus 23:59/00:00/00:01. Steps: group/display/evaluate. Expected: `startOfDay` grouping; no previous-day group; 00:03 with 5 lead alarms previous day 23:58 if still future; display Today/Tomorrow correct. Failure: omission/wrong group/time. Evidence: XCTest/screenshots.

**TIME-004 — Day/timezone/significant-time signals.** Purpose: fresh truth after clock changes. Requirements: REQ-TIME-03. Priority: P0. Level/class: static+integration/AUTO. Preconditions/data: notification configuration. Steps: inspect registered signals and trigger adapter; simulate long-gap fresh now. Expected: same coordinator, fresh `[now,now+14d)`, UI refresh; no manual timezone arithmetic. Failure: stale window/parallel path. Evidence: XCTest/source audit.

**TIME-005 — Scheduling horizon boundaries.** Purpose: exact ownership. Requirements: REQ-REC-06/07. Priority: P0. Level/class: unit/AUTO. Preconditions/data: horizon H=14×24h; alarm dates now, now+H−1s, now+H, now+H+1s. Steps: call `owns` and planner. Expected: owns now and H−1s; excludes H and H+1s; candidate rule separately excludes alarmDate==now from new scheduling; outside mappings preserved. Failure: inclusive end or unsafe retirement. Evidence: XCTest. Notes: domain horizon is duration-based, not calendar-day addition.

**LIFE-001 — Cold app launch reconciliation.** Purpose: authoritative launch convergence. Requirements: REQ-REC-01. Priority: P0. Level/class: integration/device AUTO+DEV. Preconditions/data: permissions granted, D01 changed while app terminated. Steps: launch. Expected: activation trigger uses fresh now/EventKit truth and reconciles once/coalesced. Failure: stale/duplicate/no reconcile. Evidence: trigger test/device trace.

**LIFE-002 — Background to foreground reconciliation.** Purpose: resume convergence. Requirements: REQ-REC-01. Priority: P0. Level/class: device/DEV. Preconditions/data: D11 scheduled; background app; change event externally. Steps: foreground. Expected: fresh EventKit fetch, old alarm replaced, UI refresh. Failure: stale alarm until unrelated action. Evidence: screen/system recording.

**LIFE-003 — EventKit store-change trigger.** Purpose: react while process alive. Requirements: REQ-REC-02. Priority: P0. Level/class: integration/device AUTO+DEV. Preconditions/data: granted; modify D11 in Calendar. Steps: observe store notification/reconcile. Expected: notification payload not trusted as truth; fresh fetch; convergence with coalescing. Failure: duplicate/no refresh. Evidence: source audit/device trace.

**LIFE-004 — Best-effort background task.** Purpose: truthful supplemental reliability. Requirements: REQ-REC-12, REQ-PERM-07. Priority: P1. Level/class: orchestration/AUTO+BEST. Preconditions/data: registered identifier and mocks; optional device OS opportunity. Steps: start twice; execute/expire/deny. Expected: one registration/logical request, successor scheduled, same coordinator, no prompt; blocked/expired reports failure; foreground remains operational. Failure: timing guarantee/duplicate completion/path. Evidence: XCTest; device observation if available.

**LIFE-005 — Background registration/submission failure.** Purpose: preserve foreground correctness. Requirements: REQ-REC-12. Priority: P1. Level/class: negative/AUTO. Preconditions/data: scheduler throws. Steps: start then foreground trigger. Expected: debug-local error only; foreground reconciliation still runs. Failure: app disabled/crash. Evidence: XCTest.

**LIFE-006 — Presentation minute clock.** Purpose: fresh display without domain side effects. Requirements: REQ-TIME-04, REQ-UI-04. Priority: P1. Level/class: unit/AUTO. Preconditions/data: injected times. Steps: activate repeatedly, tick, deactivate. Expected: immediate refresh; one timer; active-only; no fetch/reconcile/persist/schedule; stable scroll anchor. Failure: domain operation or duplicate timer. Evidence: XCTest/source boundary.

### Privacy, accessibility, and release automation

**PRIV-001 — Networking surface audit.** Purpose: prove no network product. Requirements: REQ-PLAT-02, REQ-PRIV-01. Priority: P0. Level/class: static/AUTO. Preconditions/data: current source/project. Steps: search imports/symbols/entitlements for URLSession/Network/WebSocket/cloud/backend endpoints. Expected: none in Production product. Failure: unexplained dependency/endpoint. Evidence: command output. Notes: public release-site HTML is not app runtime code.

**PRIV-002 — SDK/dependency audit.** Purpose: no analytics/ads/tracking/third party. Requirements: REQ-PLAT-03. Priority: P0. Level/class: static/AUTO. Preconditions/data: pbxproj/package state/binary link list. Steps: inspect packages/frameworks/imports. Expected: Apple frameworks only; no analytics/ad/tracker. Failure: unexpected SDK. Evidence: project and build linkage output.

**PRIV-003 — Account/identity audit.** Purpose: no login/account/AI/monetization. Requirements: REQ-PLAT-02/03. Priority: P0. Level/class: static/AUTO. Preconditions/data: source/UI/resources. Steps: search auth/account/purchase/AI surfaces and inspect navigation. Expected: none. Failure: hidden user identity or monetization path. Evidence: search output.

**PRIV-004 — Provider/cloud audit.** Purpose: EventKit-only local calendar access. Requirements: REQ-PLAT-04, REQ-PRIV-01. Priority: P0. Level/class: static/AUTO. Preconditions/data: source/project. Steps: search Google/Microsoft/provider APIs and network libraries. Expected: none; calendars arrive only through EventKit. Failure: provider credential/network path. Evidence: search output.

**PRIV-005 — Calendar write prohibition.** Purpose: protect user data. Requirements: REQ-CAL-01. Priority: P0. Level/class: interface/static AUTO. Preconditions/data: provider protocols/concrete adapter. Steps: inspect public methods and EventKit mutation symbols. Expected: discover/fetch/status/request only; no save/remove/update/delete. Failure: reachable calendar mutation. Evidence: source citations/search.

**PRIV-006 — Local persistence inventory.** Purpose: limit stored data. Requirements: REQ-PRIV-02. Priority: P0. Level/class: unit/static AUTO. Preconditions/data: SwiftData models/UserDefaults. Steps: inspect schema; run round trips. Expected: onboarding flag, settings, selected calendar IDs, override intent, mapping identity/UUID/date only; no full event content or sync. Failure: unnecessary personal content/transmission. Evidence: XCTest/schema list.

**PRIV-007 — Privacy manifest/descriptions.** Purpose: declaration consistency. Requirements: REQ-PRIV-03. Priority: P0. Level/class: config/build AUTO. Preconditions/data: Info.plist, PrivacyInfo, built Release app. Steps: plutil/inspect source and bundle. Expected: manifest present; Calendar/Alarm descriptions accurate; no undeclared tracking; resources bundled. Failure: missing/contradictory declaration. Evidence: plutil/build artifact output.

**PRIV-008 — Release leakage/log audit.** Purpose: no debug scenario/private values. Requirements: REQ-PRIV-04. Priority: P0. Level/class: static/build AUTO. Preconditions/data: Release app. Steps: verify DEBUG gating; scan strings/symbol/source for `-UIScenario`, synthetic titles, secrets/tokens/emails/private calendar content and unconditional logs. Expected: no reachable Release sample routing/data or sensitive values; only intentional product strings. Failure: leakage. Evidence: scan output. Notes: test/doc fixtures may exist outside built app.

**A11Y-001 — Semantic labels/identifiers.** Purpose: conceptual VoiceOver content. Requirements: REQ-A11Y-01. Priority: P1. Level/class: unit/static AUTO. Preconditions/data: D01/all-day/OFF/past. Steps: generate labels and inspect stable IDs. Expected: title/start/calendar/alarm/state in Japanese; no raw internal ID; status not color-only. Failure: missing/unstable/technical label. Evidence: XCTest.

**A11Y-002 — Real VoiceOver order.** Purpose: usable spoken journey. Requirements: REQ-A11Y-01. Priority: P1. Level/class: manual/DEV. Preconditions/data: VoiceOver on, populated/denied/detail/settings. Steps: swipe through each screen and activate controls. Expected: logical order/traits/actions; one conceptual row; no focus traps. Failure: inaccessible control or misleading order. Evidence: human checklist/video.

**A11Y-003 — Dynamic Type smoke.** Purpose: preserve core meaning at large sizes. Requirements: REQ-A11Y-02. Priority: P1. Level/class: manual/SIM+DEV. Preconditions/data: default, XXXL, accessibility XXXL; long Japanese titles. Steps: inspect onboarding/timeline/detail/calendars/settings. Expected: readable reflow/scroll; no clipped controls or lost meaning. Failure: inaccessible/truncated essential text. Evidence: screenshots.

**A11Y-004 — Tap targets/readability/Inspector.** Purpose: physical usability. Requirements: REQ-A11Y-02. Priority: P1. Level/class: manual/DEV. Preconditions/data: small/large iPhones. Steps: run Accessibility Inspector where available and use primary controls by touch. Expected: usable targets, contrast, labels/traits, no overlap. Failure: critical Inspector finding or unreliable activation. Evidence: report/video.

**A11Y-005 — Japanese/source-content behavior.** Purpose: language consistency. Requirements: REQ-A11Y-03. Priority: P1. Level/class: unit+SIM AUTO+SIM. Preconditions/data: Japanese app/device plus mixed-language event/source. Steps: inspect app-owned copy and labels. Expected: app copy Japanese; system UI follows OS; source data unchanged. Failure: accidental English primary copy or mistranslation. Evidence: XCTest/screenshots.

**A11Y-006 — Light/dark visual smoke.** Purpose: appearance quality. Requirements: REQ-A11Y-04. Priority: P2. Level/class: manual/SIM+DEV. Preconditions/data: main journeys. Steps: switch appearances and inspect. Expected: readable contrast, opaque headers, no clipping/flash. Failure: unreadable or misleading state. Evidence: screenshots/video.

**REL-001 — Full XCTest suite.** Purpose: regression gate. Requirements: REQ-PLAT-01 and all AUTO mappings. Priority: P0. Level/class: build test/AUTO. Preconditions/data: current HEAD/worktree. Steps: run scheme tests on a specific available iOS 26+ Simulator; retain xcresult/log. Expected: all tests pass, zero failures. Failure: any failure/crash. Evidence: command/result/count. Environment: Xcode/Simulator.

**REL-002 — Debug/Release Simulator builds.** Purpose: configuration gate. Requirements: REQ-PLAT-01. Priority: P0. Level/class: build/AUTO. Preconditions/data: current worktree. Steps: build Debug then Release for generic Simulator or specified bootable simulator. Expected: both succeed. Failure: build error. Evidence: logs. Environment: current Xcode.

**REL-003 — Unsigned generic Device Release.** Purpose: device compilation gate. Requirements: REQ-PLAT-01. Priority: P0. Level/class: build/AUTO. Preconditions/data: signing disabled. Steps: build Release for `generic/platform=iOS` with `CODE_SIGNING_ALLOWED=NO`. Expected: success. Failure: compile/link/resource error. Evidence: log.

**REL-004 — Warning and whitespace audit.** Purpose: clean quality delta. Requirements: release gate. Priority: P1. Level/class: static/build AUTO. Preconditions/data: logs/diff. Steps: run `git diff --check`; inspect warnings in all build/test logs. Expected: no whitespace errors and no new actionable compiler warnings; environment warnings documented separately. Failure: source warning/error. Evidence: outputs.

## 9. Physical iPhone test cases

All cases below require a physical iPhone on iOS 26+ and must remain NOT EXECUTED until a human records evidence. Use the synthetic QA calendar, disable sensitive notification previews if screen recording, and delete QA events/alarms after the run.

**DEV-001 — Actual AlarmKit scheduling.** Purpose: primary integration. Requirements: REQ-ALARM-01, REQ-CAL-02. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: clean install, D01, permissions granted, QA calendar enabled, default 5. Steps: launch/foreground; find D01; verify detail; wait for reconciliation. Expected: one system AlarmKit alarm for 09:55 with no duplicate. Failure: missing/wrong/duplicate alarm. Evidence: device/OS version, app SHA/build, screen recording/system alarm view. Notes: do not use real data.

**DEV-002 — Alarm fires at lead time.** Purpose: prove North Star delivery. Requirements: REQ-ALARM-01, REQ-REL-01. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: event at least 10 minutes ahead, lead 5, DEV-001 setup. Steps: lock/idle device and wait through alarm date. Expected: system alarm begins at event start minus exactly five minutes within OS clock precision. Failure: early/late/missing/notification-only behavior. Evidence: continuous time-visible video and observed timestamps.

**DEV-003 — Actual event title.** Purpose: title fidelity. Requirements: REQ-ALARM-09. Priority: P1. Level/class: end-to-end/DEV. Preconditions/data: `チーム定例`. Steps: schedule/fire/view system alarm. Expected: title exactly `チーム定例`, no app prefix/suffix. Failure: wrong/blank/technical title. Evidence: screenshot/video.

**DEV-004 — Blank-title fallback.** Purpose: safe title. Requirements: REQ-ALARM-09. Priority: P1. Level/class: end-to-end/DEV. Preconditions/data: create untitled/whitespace-equivalent event where iOS permits. Steps: schedule and inspect/fire. Expected: AlarmKit title `予定`. Failure: empty or different fallback. Evidence: screenshot/video; document how EventKit represented title.

**DEV-005 — Foreground/background behavior.** Purpose: authoritative resume. Requirements: REQ-REC-01. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: scheduled D11. Steps: background app; move event to 11:00 in Calendar; foreground AgendaCue. Expected: UI refresh and only 10:55 alarm remains; no dependence on background execution. Failure: stale/duplicate. Evidence: before/after video.

**DEV-006 — Locked-device/system presentation.** Purpose: real alarm experience/accessibility. Requirements: REQ-REL-01, REQ-A11Y-01. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: scheduled near-future QA alarm; device locked. Steps: wait for fire. Expected: OS-provided prominent alarm presentation with readable title and stop control. Failure: no presentation/wrong content/unusable control. Evidence: second-camera video where needed; redact notifications.

**DEV-007 — Dynamic Island/system presentation where applicable.** Purpose: observe supported native surface. Requirements: REQ-REL-01. Priority: P2. Level/class: BEST/DEV. Preconditions/data: compatible device; scheduled alarm. Steps: observe pre-fire/fire/active presentation. Expected: native AlarmKit behavior only; app makes no unsupported guarantee. Failure: app-specific broken state. Evidence: device model/video. Notes: mark NOT APPLICABLE if hardware/OS lacks surface.

**DEV-008 — Stop/dismiss; no snooze.** Purpose: V1 interaction semantics. Requirements: REQ-ALARM-10, REQ-REL-01. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: firing QA alarm. Steps: inspect controls; press `停止`; reopen app/system alarm view. Expected: alarm stops/dismisses, no app-provided snooze, no recurring re-fire, UI reconciles on foreground. Failure: cannot stop, unsupported snooze, duplicate re-fire. Evidence: video.

**DEV-009 — Changed event reconciles before fire.** Purpose: prevent obsolete firing. Requirements: REQ-CAL-07, REQ-REL-02. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: D11 scheduled sufficiently ahead. Steps: move 10:00 to 11:00; trigger store change or foreground. Expected: old 09:55 alarm removed; one 10:55 alarm; old time does not fire. Failure: stale/duplicate/wrong alarm. Evidence: before/after system view and continuous observation around old time.

**DEV-010 — Deleted event does not later alarm.** Purpose: stale-alarm safety. Requirements: REQ-CAL-07, REQ-REL-02. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: D12 scheduled. Steps: delete in Calendar; foreground/reconcile; wait past former alarm time. Expected: mapping/system alarm gone and no fire. Failure: any former alarm fires/remains. Evidence: before/after/wait video.

**DEV-011 — Permission revocation/recovery.** Purpose: lifecycle permission truth. Requirements: REQ-PERM-03/05. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: onboarding complete, both granted, QA mapping exists. Steps: revoke Calendar, foreground; restore; revoke Alarm, foreground; restore. Expected: truthful denied/recovery UI; no crash/replayed onboarding/mass destructive Calendar-denial behavior/repeated prompt; restoration pass converges. Failure: lie, crash, data corruption. Evidence: full sequence video/state notes.

**DEV-012 — Timezone/day change smoke.** Purpose: absolute scheduling/day refresh. Requirements: REQ-TIME-01/03. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: absolute future QA event/alarm and near-midnight display data. Steps: record absolute schedule; change system timezone/day where safe; foreground. Expected: refetch/reconcile and regroup using new local day; alarm remains start-minus-lead as an absolute instant; no manual-offset duplicate. Failure: shifted instant/omission/duplicate. Evidence: before/after timestamps/timezones/video. Restore settings afterward.

**DEV-013 — Multiple upcoming alarms.** Purpose: identity/capacity smoke. Requirements: REQ-REL-03. Priority: P0. Level/class: end-to-end/DEV. Preconditions/data: D01/D02/D09/D10 at distinct future alarm times. Steps: reconcile repeatedly and inspect system alarms. Expected: one alarm per eligible occurrence, distinct UUID/instant despite duplicate titles, no duplicates; failures truthful if platform capacity reached. Failure: collision/duplicate/fake mapping. Evidence: system/app views and counts.

**DEV-014 — Paired Apple Watch native behavior.** Purpose: document system behavior without product promise. Requirements: REQ-REL-04. Priority: P2. Level/class: BEST/DEV. Preconditions/data: paired compatible Watch if available; no watchOS target. Steps: schedule/fire one QA alarm with phone locked/unlocked. Expected: record observed native AlarmKit behavior; AgendaCue exposes no Watch app or custom guarantee. Failure: only an app-caused contradiction/crash. Evidence: device/Watch models and video. Notes: NOT APPLICABLE if unavailable, not PASS.

## 10. Regression and automation gap strategy

Existing automation covers domain lead values/default, EventKit mapping/selection, eligibility/all-day/equality/past, overrides, AlarmKit boundary transactions, duplicate/idempotent scheduling, replacement/cancel failures, reconciliation add/change/delete/disable/divergence/capacity/concurrency/window ownership, permission mappings/onboarding routing, presentation policy, lifecycle/background orchestration, and persistence boundaries.

WU-11 adds one focused automated regression, `testTenOClockEventProducesExactAlarmForEverySupportedLeadTime`, because explicit 10:00 arithmetic for 10/15/60-minute leads was missing while the requirement is release-critical and deterministic. No Production code changes are needed. REC-016 is marked for coverage confirmation: existing Calendar permission-denial and source-error tests cover the safety boundary, but a future dedicated coordinator snapshot-throw assertion is recommended only if current execution/source review shows the distinction is not already adequate.

Manual-only items include pinned-header animation, full UI journeys, Dynamic Type layout, Accessibility Inspector and real VoiceOver. Device-only items include real permission prompts/revocation, EventKit provider behavior, AlarmKit system scheduling/firing/lock-screen controls, app inactivity interaction, and Watch/native presentation.

For every Production change, run all AUTO cases; rerun focused categories for the changed component; rerun UI-001–010/A11Y-003/006 for presentation changes; rerun DEV-001/002/005/009/010/011 for scheduling, reconciliation, permission or lifecycle changes. Evidence is SHA-bound and expires after relevant code/config changes.

## 11. Evidence and defect handling

Evidence must identify branch, full SHA or exact dirty diff, command, Xcode/SDK/OS/device, timestamp, result/count, and limitations. Screenshots/videos must avoid real personal events, account names, notification content and identifiers. Store logs under `docs/evidence/WU-11/` only when appropriate for source control; large xcresult/build products stay outside the repository with their paths and summaries recorded.

Defects go in `docs/QA_DEFECTS.md` with DEFECT ID, severity, test ID, summary, environment, precondition, exact steps, actual, expected, reproducibility, suspected component, release impact and recommended disposition. WU-11 does not silently fix Production defects.

Severity: S0 critical (privacy/data loss/security or unusable release); S1 blocker (P0/core alarm/duplicate/stale/crash/permission lie/build failure); S2 major (P1 flow/recoverability/accessibility failure); S3 moderate quality issue; S4 cosmetic. P0 failures are NO-GO regardless of severity label.

## 12. Release GO / NO-GO criteria

NO-GO if any P0 fails; core alarm time is wrong; duplicates occur; changed/deleted/disabled events leave an incorrect alarm; permission transition crashes or lies; Production Release build fails; calendar data is mutated; or actual privacy behavior contradicts declaration. No unresolved P1 should remain unless the owner explicitly accepts it with written rationale. P2/P3 may be accepted only when core correctness, privacy, accessibility and release compliance are unaffected.

`GO` requires the automated gate, required simulator cases, DEV-001–DEV-013 applicable physical-device evidence, resolved/accepted findings, fresh Distribution after UI freeze, and explicit owner approval. `CONDITIONAL GO` may describe automated readiness while named mandatory human/device gates remain; it is not authorization to upload or release. `NO-GO` applies on any blocker above. Owner Human Gate is never completed by Codex.

## 13. Known environment limitations

- Simulator does not prove AlarmKit firing, lock-screen/system UI, provider-backed EventKit behavior, real permission prompts/revocation, background execution timing, paired Watch behavior, physical touch/contrast or real VoiceOver.
- DEBUG sample scenarios are useful for deterministic UI state only; Release routing/data must remain absent.
- Background refresh is best effort; requested earliest begin time is not execution evidence.
- Historical WU-09/WU-10 screenshots and 167/167 results are context only, not current execution results.
- The current owner Human Gate H01–H46, screenshot approval, fresh post-UI-freeze Distribution artifact, App Store Connect entry, upload and submission remain outside this WU.
