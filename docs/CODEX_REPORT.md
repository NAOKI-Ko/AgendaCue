# Codex Report

## Objective

WU-16 App Review 5.1.1(iv) Permission CTA Correction. Replace the Calendar and AlarmKit custom pre-permission CTA copy with neutral wording without changing permission behavior.

## Baseline

- Current `main` / branch baseline: `3b06f919889cbc8e56c4f71b0208aa5e0dfa23b7`
- Production source baseline lineage: `d6423938dedb17df3aaa0f925c30636efc61f948`
- Branch: `wu-16-permission-cta-correction`
- App Store version/build: **1.0 (2)**

## Implementation

- Updated only the localized Calendar and AlarmKit onboarding CTA values.
- Added the two CTA localization keys to the existing Japanese/English canonical localization regression table.
- Preserved the SwiftUI action wiring, EventKit and AlarmKit providers, permission request timing, authoritative state refresh, denial behavior, and Settings recovery.

## Exact Copy

- Calendar EN: `Allow Calendar Access` → `Continue`
- Calendar JA: `カレンダーを許可` → `続ける`
- Alarm EN: `Allow Alarms` → `Continue`
- Alarm JA: `アラームを許可` → `続ける`

## Changed Files

- `CalendarAlarmFeasibility/Localizable.xcstrings`
- `CalendarAlarmFeasibilityTests/ProductionUXTests.swift`
- `docs/START_HERE.md`
- `docs/PROJECT_STATE.md`
- `docs/CODEX_REPORT.md`
- `docs/evidence/WU-16/README.md`
- `docs/evidence/WU-16/ui/01-ja-calendar-pre-permission.png`
- `docs/evidence/WU-16/ui/02-en-calendar-pre-permission.png`
- `docs/evidence/WU-16/ui/03-ja-alarm-pre-permission.png`
- `docs/evidence/WU-16/ui/04-en-alarm-pre-permission.png`

## Verification

- Debug Simulator build: **PASS**
- Release Simulator build: **PASS**
- Unsigned Device Debug build: **PASS**
- Unsigned Device Release build: **PASS**
- Complete XCTest: **PASS — 174 passed, 0 failed, 0 skipped**
- Result bundle: `/private/tmp/AgendaCue-WU16-Tests-20260830.xcresult`
- Static old-CTA audit: **PASS** — no old CTA remains in production source, tests, or localization. Repository-wide matches are confined to the intentional Before → After history in this report.

Commands:

```sh
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/AgendaCue-WU16-Debug-Sim CODE_SIGNING_ALLOWED=NO build
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/AgendaCue-WU16-Release-Sim CODE_SIGNING_ALLOWED=NO build
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Debug -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/AgendaCue-WU16-Debug-Device CODE_SIGNING_ALLOWED=NO build
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Release -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/AgendaCue-WU16-Release-Device CODE_SIGNING_ALLOWED=NO build
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Debug -destination 'platform=iOS Simulator,id=9D870918-AC43-4F0C-9C63-49B824D22C5B' -derivedDataPath /private/tmp/AgendaCue-WU16-Tests-DD -resultBundlePath /private/tmp/AgendaCue-WU16-Tests-20260830.xcresult test
xcrun xcresulttool get test-results summary --path /private/tmp/AgendaCue-WU16-Tests-20260830.xcresult
```

## Functional Verification

- Calendar request path: **PASS by unchanged-source inspection and complete XCTest** — the custom button still invokes `continueCalendarOnboarding()`, which resolves only `.notDetermined` through the existing EventKit `requestFullAccessToEvents()` provider and rereads authoritative state.
- AlarmKit request path: **PASS by unchanged-source inspection and complete XCTest** — the custom button still invokes `continueAlarmOnboarding()`, which resolves only `.notDetermined` through the existing AlarmKit `requestAuthorization()` provider and rereads authoritative state.
- Denial and Settings recovery: **PASS by unchanged-source inspection and complete XCTest** — denial does not reprompt, onboarding can complete, and the existing Settings recovery policy/button remains unchanged.
- Native system permission behavior on physical hardware: **DEVICE_VERIFICATION_DEFERRED**

## Visual Evidence

- Result: **PASS**
- Japanese Calendar pre-permission: `docs/evidence/WU-16/ui/01-ja-calendar-pre-permission.png`
- English Calendar pre-permission: `docs/evidence/WU-16/ui/02-en-calendar-pre-permission.png`
- Japanese Alarm pre-permission: `docs/evidence/WU-16/ui/03-ja-alarm-pre-permission.png`
- English Alarm pre-permission: `docs/evidence/WU-16/ui/04-en-alarm-pre-permission.png`

All four 1206×2622 iPhone 17 Pro Simulator captures were directly inspected. CTA copy is correct and fully visible with no truncation, overlap, horizontal overflow, layout regression, OS-alert imitation, arrow, or added grant instruction. Details and SHA-256 values are recorded under `docs/evidence/WU-16/`.

## App Review State

- 2026-08-29: Apple rejected Build 2 under Guideline 5.1.1(iv), submission `1fad3077-c612-45aa-9f65-bc99102a671b`.
- 2026-08-30: the owner accidentally Developer-Cancelled the rejected submission. The rejection remains historical fact.
- Build 3: **NOT CREATED**
- Archive/export/upload/resubmission: **NOT PERFORMED**

## Git State

- Implementation Commit / Review Target: `c06b4c38b0ece0e2010b8505c9bcfee86b232fc1`
- State Snapshot Commit: `5cce155a4c79e6a2e354b7a3db5321e776436cd3`
- Review Sync Commit: reported after commit creation because a commit cannot contain its own SHA
- Closure merge: fast-forward-only final result and exact `main` SHA are reported after commit creation in the closure handoff

## ChatGPT Review Receipt

- Review date: **2026-08-31**
- Reviewer: **ChatGPT**
- Reviewed Implementation Commit: `c06b4c38b0ece0e2010b8505c9bcfee86b232fc1`
- Observed State Snapshot: `5cce155a4c79e6a2e354b7a3db5321e776436cd3`
- Decision: **PASS**
- Accepted verification: four builds PASS; XCTest 174/174 PASS; final four-screen Visual QA PASS.
- Physical-device native Calendar/AlarmKit authorization behavior: **DEVICE_VERIFICATION_DEFERRED — NOT PASS**
- Next Work Unit: **WU-17 — NOT STARTED**

## Deviations

The first Alarm screenshot attempt used the wrong DEBUG scenario argument form and displayed Calendar. Both invalid captures were replaced before commit using `-UIScenario=onboarding-alarm`; only the corrected Alarm evidence is retained. No production or acceptance-criteria deviation remains.

## Unresolved

- Physical-device Calendar/AlarmKit native authorization behavior remains deferred and is not claimed by Simulator evidence.
- Historical WU-14 and exact WU-11 through WU-15 Review Receipt gaps remain as recorded by WU-16A.
