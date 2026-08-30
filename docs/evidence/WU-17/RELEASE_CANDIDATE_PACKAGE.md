# WU-17 Phase A — Build 3 Release Candidate Package Evidence

Audit date: 2026-08-31 (Asia/Tokyo)

## ChatGPT Release Candidate Review

- Review date: **2026-08-31**.
- Reviewed Build 3 Source SHA: `620296af562afd37eda7a59263371c51cd64b046`.
- Observed State Snapshot: `99d46761df112a8f965746dbc7b5c37c9e59b944`.
- Decision: **PASS**.
- Physical-device Calendar/AlarmKit verification remains **DEVICE_VERIFICATION_DEFERRED — NOT PASS**.

## Exact source contract

- Branch baseline: `ac138b1b6f7260f0841c5c81e5c66d4213511e8c`.
- Packaging Commit / Build 3 Source SHA: `620296af562afd37eda7a59263371c51cd64b046`.
- Pre-archive `git rev-parse HEAD`: exact Packaging SHA above.
- Pre-archive `git status --porcelain`: empty.
- Version/build: `1.0 (2)` → `1.0 (3)`.
- Baseline-to-Packaging delta: project build number and corresponding configuration regression-test expectation/name only; functional Swift production source delta 0.

## Automated gates

- Complete XCTest: **174 passed, 0 failed, 0 skipped**.
- Result bundle: `/private/tmp/AgendaCue-WU17-Tests-20260831.xcresult`.
- Release generic Simulator build: **PASS**.
- Release unsigned generic Device build: **PASS**.
- Release Simulator install/launch smoke: **PASS**, PID `14308`.
- Xcode 26.6 (`17F113`), iOS Simulator/iPhoneOS SDK 26.5.

## Archive and export

- Archive: `/private/tmp/AgendaCue-WU17-Build3-620296af-20260831T010322.xcarchive`.
- Archive timestamp/result: `2026-08-31T01:03:39+0900`; **ARCHIVE SUCCEEDED**.
- ExportOptions: `/private/tmp/AgendaCue-WU17-ExportOptions.plist`; `app-store-connect`, local `export`, automatic signing, version/build management disabled.
- Export directory: `/private/tmp/AgendaCue-WU17-Build3-Export-20260831T010322`.
- IPA: `/private/tmp/AgendaCue-WU17-Build3-Export-20260831T010322/CalendarAlarmFeasibility.ipa`.
- IPA timestamp/result: `2026-08-31T01:04:16+0900`; **EXPORT SUCCEEDED**.
- IPA size: `2,010,329` bytes.
- IPA SHA-256: `522d0d603ecdd6330ed5f22a2c432b052099d4728de6ecce86cb5995ae640d3c`.
- Upload: **NOT STARTED**.

## Distribution and package audit

- Exported signature: `Apple Distribution: Naoki Kondo (67BCCSD863)`; certificate SHA-1 `78552718BE68D7426FA66E9CF19554D6A09B69A4`.
- Store profile: `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`; UUID `2085a254-5677-48a9-8199-8115dec074ad`; expiration 2027-05-06.
- Effective entitlements: `application-identifier = 67BCCSD863.com.naoki-ko.agendacue`, team `67BCCSD863`, `get-task-allow = false`, `beta-reports-active = true`.
- Strict codesign: **PASS** with Apple trust access.
- Identity: version `1.0`, build `3`, bundle `com.naoki-ko.agendacue`, display name `AgendaCue`, minimum iOS 26.0.
- Configuration: BGTask `com.naoki-ko.agendacue.refresh`, background mode `fetch`, non-exempt encryption `false`.
- Resources: executable, Assets catalog, AppIcons, privacy manifest, signature/profile, and Japanese/English localization resources present.
- Privacy: tracking false, collected-data list empty, UserDefaults accessed API reason `CA92.1` only.
- No embedded Frameworks, PlugIns, test bundle, third-party SDK, analytics, ads, account/backend, or unexpected capability.

## App Review correction and gates

- Packaged Calendar and Alarm CTA values are `Continue` / `続ける` in English/Japanese.
- Old exact CTA values have zero Production/package matches.
- WU-16 visual evidence remains source-equivalent; no new full visual matrix is required for a build-number-only Production delta.
- Physical-device permission behavior: **DEVICE_VERIFICATION_DEFERRED — NOT PASS**.
- H01–H46: **PENDING / NOT PASS**.
- App Store Connect: **NOT TOUCHED**.
- App Review resubmission and WU-17 Phase B: **NOT STARTED**.

The binary maps to the Packaging Commit, not the later documentation-only State Snapshot commit.
