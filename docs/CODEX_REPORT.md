# Codex Report

## Objective

WU-17 Phase A — AgendaCue 1.0 (3) Release Candidate Packaging. Create and audit a fresh Build 3 distribution archive and IPA without upload or App Store Connect changes.

## ChatGPT Release Candidate Review Receipt

- Review date: **2026-08-31**.
- Reviewed Build 3 Source SHA: `620296af562afd37eda7a59263371c51cd64b046`.
- Observed State Snapshot: `99d46761df112a8f965746dbc7b5c37c9e59b944`.
- Decision: **PASS**.
- Accepted: version `1.0` unchanged; build `2` → `3`; functional Swift production delta `0`; XCTest 174/174 PASS; signed archive/export/Distribution signing/package audit PASS; packaged CTA `Continue` / `続ける`.
- Physical-device verification remains **DEVICE_VERIFICATION_DEFERRED — NOT PASS**.

## Baseline

- `main`: `ac138b1b6f7260f0841c5c81e5c66d4213511e8c`
- WU-16 reviewed implementation: `c06b4c38b0ece0e2010b8505c9bcfee86b232fc1`
- Production lineage: `d6423938dedb17df3aaa0f925c30636efc61f948`
- Branch: `wu-17-build3-release-candidate`

## Version

- Before: **1.0 (2)**
- After: **1.0 (3)**
- Marketing version remains `1.0`.

## Production Delta

- `CalendarAlarmFeasibility.xcodeproj/project.pbxproj`: `CURRENT_PROJECT_VERSION` changed from `2` to `3` in Debug and Release.
- `CalendarAlarmFeasibilityTests/ProductionUXTests.swift`: the existing release-configuration test name and build expectation changed from Build 2 to Build 3.
- Functional Swift production source delta: **0**.
- No other production, UI, behavior, identity, signing configuration, entitlement, asset, dependency, or metadata change.

## Build 3 Source SHA

`620296af562afd37eda7a59263371c51cd64b046`

The formal archive and IPA were produced while `HEAD` equaled this exact Packaging Commit and `git status --porcelain` was empty. The later evidence commit does not change the binary mapping.

## Tests

Result: **PASS — 174 passed, 0 failed, 0 skipped**.

```sh
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Debug -destination 'platform=iOS Simulator,id=9D870918-AC43-4F0C-9C63-49B824D22C5B' -derivedDataPath /private/tmp/AgendaCue-WU17-Tests-DD -resultBundlePath /private/tmp/AgendaCue-WU17-Tests-20260831.xcresult test
xcrun xcresulttool get test-results summary --path /private/tmp/AgendaCue-WU17-Tests-20260831.xcresult
```

## Builds

- Release generic Simulator: **PASS**.
- Release unsigned generic Device: **PASS**.
- Signed generic Device Release archive: **PASS**.

```sh
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/AgendaCue-WU17-Release-Sim CODE_SIGNING_ALLOWED=NO build
xcodebuild -quiet -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Release -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/AgendaCue-WU17-Release-Device-Unsigned CODE_SIGNING_ALLOWED=NO build
```

## Archive

- Xcode: **26.6 (17F113)**; iPhoneOS SDK: **26.5**.
- Path: `/private/tmp/AgendaCue-WU17-Build3-620296af-20260831T010322.xcarchive`.
- Timestamp: `2026-08-31T01:03:39+0900`.
- Result: **ARCHIVE SUCCEEDED**.
- Archive-stage signing: `Apple Development: Naoki Kondo (8G67FB9S72)` with team `67BCCSD863`; strict codesign verification passed.

```sh
xcodebuild -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Release -destination 'generic/platform=iOS' -archivePath /private/tmp/AgendaCue-WU17-Build3-620296af-20260831T010322.xcarchive -derivedDataPath /private/tmp/AgendaCue-WU17-Archive-DD -allowProvisioningUpdates archive
```

## Distribution Signing

- Exported authority: `Apple Distribution: Naoki Kondo (67BCCSD863)`.
- Certificate SHA-1: `78552718BE68D7426FA66E9CF19554D6A09B69A4`; Cloud Managed Apple Distribution; expires 2027-05-06.
- Store profile: `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`.
- Profile UUID: `2085a254-5677-48a9-8199-8115dec074ad`; expires 2027-05-06.
- Team/App ID: `67BCCSD863` / `67BCCSD863.com.naoki-ko.agendacue`.
- Effective entitlements: application identifier, team identifier, `get-task-allow=false`, `beta-reports-active=true` only.
- `codesign --verify --deep --strict --verbose=4`: **PASS — valid on disk and satisfies Designated Requirement**.

## Export

- ExportOptions source: `/private/tmp/AgendaCue-WU17-ExportOptions.plist`.
- Method/destination: `app-store-connect` / `export`; automatic signing; version/build management disabled.
- Export path: `/private/tmp/AgendaCue-WU17-Build3-Export-20260831T010322`.
- IPA: `/private/tmp/AgendaCue-WU17-Build3-Export-20260831T010322/CalendarAlarmFeasibility.ipa`.
- Size: `2,010,329` bytes.
- Timestamp: `2026-08-31T01:04:16+0900`.
- Result: **EXPORT SUCCEEDED**.
- Upload was not requested or performed.

```sh
xcodebuild -exportArchive -archivePath /private/tmp/AgendaCue-WU17-Build3-620296af-20260831T010322.xcarchive -exportPath /private/tmp/AgendaCue-WU17-Build3-Export-20260831T010322 -exportOptionsPlist /private/tmp/AgendaCue-WU17-ExportOptions.plist -allowProvisioningUpdates
```

## IPA SHA-256

`522d0d603ecdd6330ed5f22a2c432b052099d4728de6ecce86cb5995ae640d3c`

## Package Inspection

- `CFBundleShortVersionString`: `1.0`.
- `CFBundleVersion`: `3`.
- Bundle ID: `com.naoki-ko.agendacue`.
- Display name: `AgendaCue`.
- BGTask permitted identifier: `com.naoki-ko.agendacue.refresh` only.
- Background mode: `fetch` only.
- `ITSAppUsesNonExemptEncryption`: `false`.
- Minimum OS: `26.0`; platform executable: arm64 iPhoneOS.
- Executable, nonempty `Assets.car`, compiled AppIcons, `PrivacyInfo.xcprivacy`, Store profile, signature resources, and Japanese/English localization resources are present.
- Privacy manifest: tracking false, collected data empty, UserDefaults accessed API reason `CA92.1` only.
- No embedded `Frameworks` or `PlugIns`; linkage is Apple system frameworks and Swift runtime only.
- Local strict signature validation: **PASS**. The first sandboxed trust check returned `CSSMERR_TP_NOT_TRUSTED` because Apple trust/OCSP access was unavailable; the same unchanged artifact passed immediately when verified with trust access.

## App Review Correction

- Exported English Calendar CTA: `Continue`.
- Exported Japanese Calendar CTA: `続ける`.
- Exported English Alarm CTA: `Continue`.
- Exported Japanese Alarm CTA: `続ける`.
- Old production/package CTA exact matches: **0**.
- WU-16 visual evidence remains source-equivalent because the only Production configuration delta is build number.
- Release Simulator launch smoke: **PASS**, launch PID `14308`.

## Physical Device Gate

**DEVICE_VERIFICATION_DEFERRED — NOT PASS**. H01–H46 remain **PENDING / NOT PASS**. No Simulator or automated evidence is converted to physical-device evidence.

## App Store Connect

**NOT TOUCHED**. Build 3 upload, build selection, Add for Review, Submit for Review, release, and WU-17 Phase B are **NOT STARTED**.

## Deviations

The initial strict codesign check was executed without external trust/OCSP access and returned `CSSMERR_TP_NOT_TRUSTED`. It did not alter the artifact. Rechecking the same exported app with Apple trust access passed as valid on disk and satisfying its Designated Requirement. No package, source, or acceptance-scope deviation remains.

## Unresolved

- ChatGPT Release Candidate Review is pending for exact Build 3 Source SHA.
- Physical-device authorization behavior and H01–H46 remain deferred / NOT PASS.
- Historical WU-14 and exact WU-11 through WU-15 Review Receipt gaps remain as recorded by WU-16A.
