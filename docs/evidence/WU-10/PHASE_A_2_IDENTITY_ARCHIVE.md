# WU-10 Phase A.2 — Production Identity and Archive Readiness

Audit date: 2026-08-22. Parent: `cf8c53831218a53db8edae9e80a5737412bb81d2`.

## Integrated identity

- Display name: `AgendaCue`
- App bundle ID: `com.naoki-ko.agendacue`
- Test bundle ID: `com.naoki-ko.agendacue.tests`
- BGTask identifier: `com.naoki-ko.agendacue.refresh`
- Marketing version/build: `1.0` / `1`

Debug and Release app settings, both test configurations, generated Release Info.plist, BGTask registration/permitted value, and the focused reliability assertion agree. Internal project, target, executable, module, source-directory, and test-host names remain `CalendarAlarmFeasibility` as safe implementation names. Historical evidence retains its then-current example identifiers.

## Automated verification

- XCTest: **PASS — 160 tests, 0 failures**.
- iPhone 17 Pro Simulator Debug: **PASS**.
- Generic Simulator Debug: **PASS**.
- Generic Device Debug unsigned: **PASS**.
- Generic Simulator Release: **PASS**.
- Generic Device Release unsigned: **PASS**.
- Production Release Simulator install/launch as `com.naoki-ko.agendacue`: **PASS**.
- Built product: display name, bundle ID, BGTask ID, version/build, PrivacyInfo, and compiled assets: **PASS**.
- Release executable leakage check for `WU-00`, `UIScenario`, and feasibility alarm copy: no matches.

## Signing and archive

Project signing remains Automatic with team `67BCCSD863`; no source entitlements file or profile specifier is configured. Background mode remains `fetch` only. No App Groups, Push Notifications, iCloud, or Associated Domains capability was added.

`security find-identity -v -p codesigning` reported zero valid identities. A normal signed generic Release build reported no provisioning profile for `com.naoki-ko.agendacue`; no App ID existence was inferred and `-allowProvisioningUpdates` was not used. Therefore:

- Signed device build: **BLOCKED**.
- Archive: **BLOCKED / NOT CREATED**.
- Archive inspection: **N/A — no archive exists**.

Required resolution: owner account must provide a valid signing certificate/private key and a compatible profile, and verify or register the Production App ID. No device install, upload, distribution, App Store Connect operation, or Human Gate execution occurred.

## Regression and scope

Identity strings only were changed. Alarm candidate identity, persisted UUID, alarm date, one-shot scheduling, cancellation/replacement, reconciliation, and exact event-title presentation (`予定` fallback) are unchanged. EventKit stays read-only. BGTask timing/rescheduling and the side-effect-free minute clock are unchanged. Static privacy/network audit remains no networking, analytics, tracking, backend, account, or third-party SDK; the recommendation remains “No data collected.”

Human Gate H01–H46: **PENDING / NOT EXECUTED**.
