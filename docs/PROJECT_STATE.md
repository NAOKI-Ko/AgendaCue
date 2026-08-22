# Project State

- Phase: **WU-10 Release Gate — Phase A.7A**
- Current Work: **Public Site + Privacy URL + Final Screenshot Package**
- Status: **PUBLIC PRIVACY + SCREENSHOT PACKAGE FINALIZED / SUPPORT URL COMPLIANCE BLOCKED / HUMAN GATE PENDING**
- Automated Gate: **PASS**
- Human Gate: **PENDING — REQUIRED / CANNOT BE WAIVED**
- Submission: **NOT STARTED**
- Main Merge: **NOT STARTED**
- Phase B: **NOT STARTED**
- Production Brand: **AgendaCue — OWNER APPROVED / INTEGRATED**
- Customer Display Name: **AgendaCue**
- Production Bundle ID: **`com.naoki-ko.agendacue` — OWNER APPROVED / INTEGRATED**
- Production BGTask ID: **`com.naoki-ko.agendacue.refresh` — OWNER APPROVED / INTEGRATED**
- Final AppIcon: **APPROVED + INTEGRATED**
- AppIcon Technical Validation: **PASS**
- Japanese App Store Metadata: **FINALIZED / READY FOR OWNER ENTRY**
- English App Store Localization: **DRAFT ONLY — DO NOT PUBLISH YET**
- Category Recommendation: **Utilities / Productivity**
- Copyright: **© 2026 Naoki Kondo**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 Simulators.

- XCTest: 160 tests passed, 0 failures.
- Specific iPhone 17 Pro Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device Debug and Release builds with code signing disabled: succeeded.
- Generic iOS Simulator Debug and Release builds: succeeded.
- Production Release app Simulator launch smoke without sample arguments: passed.
- Clean Debug/Release compiler audit: zero warnings after the narrow Sendable fix.
- WU-10 release evidence is indexed in `docs/evidence/WU-10/README.md`.
- Phase A.1 naming evidence is indexed in `docs/evidence/WU-10/PHASE_A_1_NAMING.md`.
- Phase A.1 verification: 160/160 tests; required specific Debug and generic Release Simulator/unsigned Device builds; Release launch; built and installed `CFBundleDisplayName = AgendaCue`.
- Phase A.2 verification: 160/160 tests; all three Debug and both unsigned Release builds; Release launch under `com.naoki-ko.agendacue`; built plist identity and BGTask checks passed.
- Phase A.3 verification: valid Apple Development identity restored; signed generic Release build and local Release archive passed; archive identity/plist/privacy/icon/leakage inspection passed.
- Local archive: `/private/tmp/AgendaCue-WU10-A3.xcarchive`, signed by `Apple Development: Naoki Kondo (8G67FB9S72)` with team `67BCCSD863` and `iOS Team Provisioning Profile: *`.
- Phase A.4 verification: owner-approved 1024×1024 RGB/no-alpha PNG integrated as the sole Production `AppIcon`; 160/160 tests, required Debug/Release builds, Release launch/bundle inspection, and Simulator Home Screen rendering passed.
- Phase A.5 package: Japanese metadata finalized; privacy/support static page sources and release checklist created; seven owner-review screenshot sources captured on iPhone 17 Pro Max Simulator at 1320×2868 JPEG/no-alpha.
- Phase A.6 verification: fresh Release archive and local App Store Connect export passed. The exported IPA is signed by `Cloud Managed Apple Distribution` for team `67BCCSD863` with exact Store profile `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`; exported entitlement `get-task-allow = false`.
- Phase A.6 archive/export: `/private/tmp/AgendaCue-WU10-A6.xcarchive` and `/private/tmp/AgendaCue-WU10-A6-Export/CalendarAlarmFeasibility.ipa`. Nothing was uploaded or distributed.
- Phase A.7A public site: `https://naoki-ko.github.io/agendacue-site/`; Privacy Policy and informational Support pages are public over HTTPS and live-validated. No personal contact information is exposed.
- Phase A.7A screenshot package: six visually inspected raw captures finalized under `docs/release/screenshots/final-ja/` in App Store order; every file remains 1320×2868 JPEG, RGB/no-alpha, byte-identical to its validated source.
- Japanese residual audit: app-owned primary UI, permission guidance, state copy, accessibility labels, and purpose strings are Japanese. Product/system names and source-provided calendar/event/source content remain unchanged.
- Scope audit: scheduling dates/identities/lifecycle, reconciliation, background semantics, domain rules, calendar write prohibition, timeline, settings, persistence schema, and event-detail business behavior are unchanged. Phase A changes are release configuration hygiene, privacy manifest, Japanese stop copy, a narrow Sendable fix, and documentation/evidence.

WU-09-05 provides three lightweight first-launch steps: welcome, Calendar rationale/request, and Alarm rationale/request. Each request is made only while authorization is not determined. Denial still permits completion; completion persists independently of permission state, so later revocation does not replay onboarding. Completed users see the existing inline/System Settings recovery path.

AlarmKit presentation receives the unmodified nonblank source event title. Blank or whitespace-only titles use the Japanese fallback `予定`. Alarm date, stable identity, generated UUID, lifecycle, reconciliation, and capacity behavior are unchanged.

Accessibility Inspector, real VoiceOver, real-device permissions/EventKit/AlarmKit/Watch/background behavior, physical usability, and final owner acceptance remain mandatory Human Gate work. No item is passed by Codex.

## Remaining owner inputs

- Resolution of App Store Support URL compliance under the owner policy prohibiting public email, telephone number, legal address, or other personal contact information.
- Explicit authorization for any later App Store Connect upload or App Review submission.

## Release blockers

- App Store Support URL compliance, H01–H46, and owner GO/NO-GO remain pending.
- Japanese metadata/category/copyright source is prepared; App Store Connect entry itself is not started. English localization must not be published until English in-app UI exists.
- Physical iPhone was listed as unavailable, so no device installation or behavior was claimed.
- Distribution signing and local export validation passed; App Store Connect upload and App Review submission remain NOT STARTED and require explicit owner authorization.
- Actual system-scheduled background execution timing was not tested on a real device; foreground/resume remains authoritative.

## Required Human Review

H01–H46 are defined in `docs/release/HUMAN_GATE_CHECKLIST.md`; the result record is `docs/release/HUMAN_GATE_RESULT.md`. No human item is marked passed. WU-10 Human Gate cannot be waived and final owner decision is PENDING.
