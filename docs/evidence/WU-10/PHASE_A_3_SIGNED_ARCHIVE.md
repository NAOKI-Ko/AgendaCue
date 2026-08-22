# WU-10 Phase A.3 — Signed Build and Local Archive Validation

Audit date: 2026-08-22. Parent: `efef6044e9775c66b298f8f7d8504c8d22d19ca5`. Environment: Xcode 26.6 (17F113), iOS SDK/Simulator 26.5.

## Signing resolution

- Detected identity: `Apple Development: Naoki Kondo (8G67FB9S72)`; SHA-1 `EA94C8ACFD4894D70A9AB09FEFC9AAEBC456827F`.
- Team: `67BCCSD863`.
- Resolved profile: `iOS Team Provisioning Profile: *`; UUID `5e6fc84e-b8e2-4215-ac64-0934a4c04608`; expiration 2027-07-22 JST.
- Signed application entitlement: `application-identifier = 67BCCSD863.com.naoki-ko.agendacue`.
- Normal signed generic iOS Device Release build: **PASS**.

The wildcard team profile resolved the approved bundle ID in actual build/archive output. This proves local development signing resolution, not explicit App ID registration in the Developer Portal and not App Store distribution/export readiness. The archived entitlement includes `get-task-allow = true`; a later distribution/export step requires appropriate distribution credentials/profile.

## Regression

- XCTest on iPhone 17 Pro Simulator: **PASS — 160/160, 0 failures, 0 skipped**.
- Specific iPhone 17 Pro Simulator Debug: **PASS**.
- Generic Simulator Debug: **PASS**.
- Generic Device Debug unsigned: **PASS**.
- Generic Simulator Release: **PASS**.
- Generic Device Release unsigned: **PASS**.
- New compiler warnings: **0**.

A physical iPhone 17 was listed by CoreDevice as `unavailable`; no device install or Human Gate result was claimed.

## Archive

- Result: **PASS**.
- Path: `/private/tmp/AgendaCue-WU10-A3.xcarchive`.
- Scheme/configuration/destination: `CalendarAlarmFeasibility` / Release / generic iOS Device.
- Signature verification: `codesign --verify --deep --strict` **PASS**.
- Signing identity/team/profile: the Apple Development identity, team, and profile listed above.

Archive inspection:

- `CFBundleDisplayName = AgendaCue`.
- `CFBundleIdentifier = com.naoki-ko.agendacue`.
- Version/build `1.0 / 1`.
- `BGTaskSchedulerPermittedIdentifiers[0] = com.naoki-ko.agendacue.refresh`.
- Background mode is only `fetch`.
- Japanese EventKit full-access and AlarmKit purpose strings are present and nonempty.
- `PrivacyInfo.xcprivacy` and compiled `Assets.car` are present.
- Compiled AppIcon PNGs are present; technical compilation passed. Owner visual approval remains pending.
- No `.xctest` or PlugIns/test bundle is embedded.
- Release executable contains no `WU-00`, `UIScenario`, old feasibility alarm title, or WU-00 readiness copy.

No export, upload, distribution, App Store Connect operation, submission, merge, push, physical-device install, or H01–H46 execution occurred.

## Scope regression

No app source or behavior changed in Phase A.3. AlarmKit candidate identity, UUID persistence, date, schedule/cancel/replace, reconciliation, and exact event-title presentation (`予定` fallback) remain covered by the 160-test suite. EventKit remains read-only. The BGTask identifier and existing scheduling semantics remain unchanged; the minute presentation clock has no reconciliation/scheduling/background side effects. Privacy/network posture remains no networking, analytics, tracking, backend, account, or third-party SDK.

Status: **ARCHIVE VALIDATED / HUMAN GATE PENDING**.
