# WU-10 Phase B.2 — Fresh Distribution Package and Final Pre-Upload Audit

Audit date: 2026-08-22. Environment: Xcode 26.6 (17F113), iOS SDK 26.5.

## Candidate

- Branch: `wu-10-release-gate`
- Production candidate SHA: `4027062ce519ab15f0274417d7d65d54133097ae`
- Production/project changes in B.2: none

## Fresh archive

- Result: **PASS — ARCHIVE SUCCEEDED**
- Path: `/private/tmp/AgendaCue-WU10-B2.xcarchive`
- Creation timestamp: `2026-08-22 18:37:16 +0900`
- Scheme/configuration/destination: `CalendarAlarmFeasibility` / Release / generic iOS Device
- Archive identity: `com.naoki-ko.agendacue`, version/build `1.0 / 1`, arm64, team `67BCCSD863`
- Archive-stage signing: `Apple Development: Naoki Kondo (8G67FB9S72)` with wildcard Development profile; `get-task-allow = true`. This is the expected intermediate archive signature, not the exported Distribution signature.

## Fresh App Store Distribution export

- Result: **PASS — EXPORT SUCCEEDED**
- Export method/destination: `app-store-connect` / local `export`
- Signing style: automatic; version/build management disabled
- Export directory: `/private/tmp/AgendaCue-WU10-B2-Export/`
- Export timestamp: `2026-08-22 18:37:59 +0900`
- IPA: `/private/tmp/AgendaCue-WU10-B2-Export/CalendarAlarmFeasibility.ipa`
- IPA size: `2,001,902` bytes
- IPA SHA-256: `cc2d166677e48545f2b21a9e266a5d502b785b340ec53543e8c9ad60020aafb5`

## Distribution signing and provisioning

- Signature: `Apple Distribution: Naoki Kondo (67BCCSD863)`
- Team: `67BCCSD863`
- Provisioning profile: `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`
- Profile UUID: `2085a254-5677-48a9-8199-8115dec074ad`
- Application identifier: `67BCCSD863.com.naoki-ko.agendacue`
- Bundle/display/version/build: `com.naoki-ko.agendacue` / `AgendaCue` / `1.0` / `1`
- Platform/minimum/device family: iPhoneOS / iOS 26.0 / iPhone only

## Entitlements and codesign

Exported entitlements are exactly:

- `application-identifier = 67BCCSD863.com.naoki-ko.agendacue`
- `com.apple.developer.team-identifier = 67BCCSD863`
- `get-task-allow = false`
- `beta-reports-active = true`

No Push, App Groups, iCloud, Associated Domains, or other unexpected entitlement is present. `codesign --verify --deep --strict` passed; the app is valid on disk and satisfies its designated requirement.

## Identity, configuration, and resources

- Automatic signing, Release configuration, team, bundle, version/build, iPhone-only family, and iOS 26.0 minimum are correct.
- `BGTaskSchedulerPermittedIdentifiers` contains only `com.naoki-ko.agendacue.refresh`.
- `UIBackgroundModes` contains only `fetch`.
- Nonempty Japanese EventKit Full Access and AlarmKit usage descriptions are present.
- `Assets.car`, compiled AppIcon resources, `PrivacyInfo.xcprivacy`, Info.plist, executable, signature resources, and embedded Store profile are present.
- Privacy manifest declares no tracking, no collected data types, and UserDefaults accessed-API reason `CA92.1`.

## Leakage audit

- No test or UI-test bundle, PlugIns directory, embedded third-party framework, WU-00 artifact, debug/sample resource, evidence Markdown, private calendar/customer data, local filesystem path, or signing secret is embedded.
- Executable string scan found no `WU-00`, `UIScenario`, feasibility view/model, repository path, evidence path, focused-test suite name, or controlled sample customer strings.
- Only Apple system frameworks and Swift runtime libraries are linked.
- The retained internal executable/module name `CalendarAlarmFeasibility` is intentional and allowed.

## Privacy/product audit

V1 remains local-only: no login, account, backend, analytics, ads, tracking, third-party SDK, or direct Google/Outlook API. EventKit remains read-only. The App Store privacy recommendation remains **No Data Collected**, subject to owner confirmation in App Store Connect.

## Regression reference

No Production source or Xcode project changed in B.2, so the B.1 baseline remains applicable: **164/164 tests passed**, with required Simulator Debug and generic Simulator/unsigned Device Release builds passing and no new compiler warnings.

## App Store materials

- Japanese metadata: **FINALIZED / READY FOR OWNER ENTRY**.
- English metadata: **DRAFT ONLY — DO NOT PUBLISH**.
- Final screenshots: **PASS / UNCHANGED** — six 1320×2868 RGB/no-alpha JPEGs in final order: Alarm timeline, default detail, custom lead detail, multi-date timeline, Calendar selection, Settings.
- Privacy Policy URL: **PASS — PUBLIC / VERIFIED** — `https://naoki-ko.github.io/agendacue-site/privacy/`.
- App Store Support URL: `https://naoki-ko.github.io/agendacue-site/privacy/` — **OWNER-ACCEPTED WITH REVIEW RISK**, not strict-compliance PASS.

## Human Gate and remaining blockers

- H01–H46: **DEFERRED BY OWNER TO POST-REVIEW / PRE-RELEASE VALIDATION — NOT PASS**; not an App Review submission blocker under explicit owner policy.
- Preferred release mode: **MANUAL RELEASE AFTER APPROVAL**.
- Remaining blockers: owner authorization for upload; owner authorization for App Review submission; App Store Connect metadata/privacy/category entry; post-review/pre-release H01–H46; final owner public-release GO/NO-GO. The accepted Support URL review risk remains open.

## External-state status

- Push: **NOT PERFORMED**
- Merge: **NOT PERFORMED**
- Tag: **NOT PERFORMED**
- Upload: **NOT STARTED / PENDING OWNER AUTHORIZATION**
- Submission: **NOT STARTED / PENDING OWNER AUTHORIZATION**

## Final audit result

Production code: **PASS**  
Regression: **164/164 PASS**  
Fresh archive: **PASS**  
Fresh Distribution export: **PASS**  
IPA signing/identity/entitlements/codesign: **PASS**  
Privacy/resources/leakage/AppIcon/Japanese metadata/screenshots/Privacy URL: **PASS**  
Support URL: **OWNER-ACCEPTED WITH REVIEW RISK**  
Human Gate: **DEFERRED / NOT PASS**  
Upload authorization: **PENDING OWNER**  
Submission authorization: **PENDING OWNER**

**FRESH DISTRIBUTION PACKAGE VALIDATED**  
**READY FOR UPLOAD AUTHORIZATION**
