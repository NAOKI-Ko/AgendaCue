# WU-10 Phase A.6 — App Store Distribution Signing and Export Validation

Audit date: 2026-08-22. Parent: `2ada7c0efc6dd8b6919fab8d16283915c54a6e3d`. Environment: Xcode 26.6 (17F113), iOS SDK 26.5.

## Signing and App ID audit

- Local Keychain identity: `Apple Development: Naoki Kondo (8G67FB9S72)`; SHA-1 `EA94C8ACFD4894D70A9AB09FEFC9AAEBC456827F`; valid 2026-07-10 through 2027-07-10; private key availability proven by `security find-identity` and archive signing.
- No local Apple Distribution identity/private key is installed.
- Xcode Automatic signing resolved `Cloud Managed Apple Distribution` during export: `Apple Distribution: Naoki Kondo (67BCCSD863)`; SHA-1 `78552718BE68D7426FA66E9CF19554D6A09B69A4`; valid 2026-05-06 through 2027-05-06. Remote/cloud signing succeeded without installing a local Distribution private key.
- Exact Store profile: `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`; UUID `2085a254-5677-48a9-8199-8115dec074ad`; team `67BCCSD863`; expiration 2027-05-06.
- The exported profile and entitlement contain exact `application-identifier = 67BCCSD863.com.naoki-ko.agendacue` and `get-task-allow = false`. This is direct evidence that the Production bundle identifier resolves as an Explicit App ID suitable for this App Store export.

The Xcode project remains Automatic signing with `DEVELOPMENT_TEAM = 67BCCSD863`, `PRODUCT_BUNDLE_IDENTIFIER = com.naoki-ko.agendacue`, no profile UUID/specifier override, and a Release Archive action. No project setting changed.

## Fresh archive and local export

- Fresh archive: **PASS** — `/private/tmp/AgendaCue-WU10-A6.xcarchive`.
- Archive configuration: shared `CalendarAlarmFeasibility` scheme, Release, generic iOS Device.
- Archive-stage signature: Apple Development identity and wildcard Development profile; `get-task-allow = true`. This intermediate archive was then re-signed by the App Store export pipeline and is not itself the distribution artifact.
- Local export method/destination: `app-store-connect` / `export`; Automatic signing; version/build management disabled.
- Distribution export: **PASS** — `/private/tmp/AgendaCue-WU10-A6-Export/CalendarAlarmFeasibility.ipa`.
- No upload, external distribution, App Store Connect submission, App Review submission, merge, or push occurred.

## Exported artifact inspection

Direct IPA inspection and strict signature verification passed:

- Signature authority `Apple Distribution: Naoki Kondo (67BCCSD863)`; team `67BCCSD863`; exact bundle ID `com.naoki-ko.agendacue`.
- Entitlements: exact application/team identifiers, `get-task-allow = false`, and expected `beta-reports-active = true`; no Push, App Groups, iCloud, or Associated Domains entitlement.
- `CFBundleDisplayName = AgendaCue`; version/build `1.0 / 1`.
- BGTask identifier `com.naoki-ko.agendacue.refresh`; background mode remains only `fetch`.
- Nonempty Japanese EventKit full-access and AlarmKit purpose strings are present.
- `Assets.car`, compiled AppIcon PNGs, and `PrivacyInfo.xcprivacy` are present. The privacy manifest remains no tracking/no collected data with UserDefaults reason `CA92.1`.
- No test bundle or PlugIns directory is embedded. No `WU-00`, `UIScenario`, test-alarm copy, debug/sample UI, or customer-facing feasibility copy was found. Internal executable/module names remain the intentionally retained `CalendarAlarmFeasibility` implementation names.

## Warning and regression audit

Archive completed with `** ARCHIVE SUCCEEDED **`; export completed with `** EXPORT SUCCEEDED **`. Packaging and Xcode distribution logs contain no warning or error record. No signing, asset, icon, or privacy-manifest warning surfaced. `codesign --verify --deep --strict` passed for the exported application.

Phase A.6 changed no app source, Xcode project, signing configuration, or runtime behavior. Under the WU instruction, the full XCTest and unsigned regression builds were optional and were not rerun; the prior 160/160 and build evidence remains the applicable code baseline. AlarmKit scheduling/title, EventKit read-only behavior, reconciliation, persistence, background refresh, minute clock, permissions, onboarding, and metadata semantics are unchanged.

Distribution status: **PASS**. Human Gate H01–H46: **PENDING — OWNER EXECUTION**. Upload/submission: **NOT STARTED**.
