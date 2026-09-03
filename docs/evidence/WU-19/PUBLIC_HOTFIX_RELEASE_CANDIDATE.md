# WU-19 — Public Hotfix Release Candidate

Audit date: 2026-09-03 (Asia/Tokyo)

## Phase 0 — Read-only release preflight

- App: AgendaCue, Bundle ID `com.naoki-ko.agendacue`, Apple app ID `6804742747`.
- Current app: **PUBLICLY RELEASED**.
- Public Marketing Version / Build: **1.0 (3)**.
- App Store version state observed: **配信準備完了**.
- Public version detail showed build **3**, version **1.0**, no App Clip.
- Highest uploaded build: **3**. TestFlight listed only version 1.0 with builds 3, 2, 1.
- Expanded upload history, filter **すべて**, likewise showed only 1.0 (3), (2), (1), all **終了**. No processing/higher build was displayed.
- Distribution sidebar showed only public 1.0; no draft/in-review version.
- App Review showed one **審査完了** and one historical **削除済み** submission, no pending/in-review submission.
- Evidence was read directly from the signed-in App Store Connect UI; no state was inferred from local archive presence.
- Read-only pages: [public version](https://appstoreconnect.apple.com/apps/6804742747/distribution/ios/version/deliverable), [App Review](https://appstoreconnect.apple.com/apps/6804742747/distribution/reviewsubmissions), and the linked TestFlight iOS builds/upload-history view.
- Earlier authentication attempts were blocked; owner reauthenticated before this successful preflight. No version/build change occurred before preflight facts were established.

Selected hotfix: **1.0.1 (4)**, the next patch version above public 1.0, with build 4 greater than all observed uploaded builds. The hotfix is **NOT YET RELEASED**.

## Exact source identity

- Branch: `wu-19-public-hotfix-release`.
- Baseline main: `ad25b3ea513c481bb27b7345cb272c183395d104`.
- Reviewed WU-18 Implementation: `31d4cf71060e1e6e05acba6b1d2d576966046f22`.
- WU-18 reviewed State Snapshot: `9ec89202408dd153c8eff398933f33f97efd24aa`.
- Packaging Commit: `e35868b0612d707c476fa51f2e1272bd9797850e`.
- Pre-archive HEAD equaled the Packaging Commit; `git status --porcelain=v1` was empty.
- Packaging Commit changes only Debug/Release `MARKETING_VERSION = 1.0.1`, `CURRENT_PROJECT_VERSION = 4`, and the focused built-product configuration test name/expectations.
- `git diff --exit-code <baseline> <packaging> -- CalendarAlarmFeasibility`: PASS, no difference.
- The same comparison against WU-18 reviewed Implementation: PASS, no difference.
- Production directory Git tree for all three SHAs: `4f7ba92780667aa2e0645cbb607df8533a858d74`.
- Functional production delta: **0**. Permission convergence, onboarding invariants, CTA, scheduling, reconciliation, persistence, UI, assets and privacy are unchanged.

Physical WU-18 Gate = **previously PASS on exact reviewed implementation lineage**. No new PD-01..PD-06 test is claimed or required for this configuration-only package.

## Automated gates

- Xcode **26.6 (17F113)**; iPhoneOS and iOS Simulator SDK **26.5**.
- Full XCTest on iPhone 17 Pro / iOS 26.5 Simulator: **182 passed / 0 failed / 0 skipped**.
- Result: `/private/tmp/AgendaCue-WU19-uyonHi/FullTests.xcresult`.
- Debug Simulator: **PASS**.
- Release Simulator: **PASS**.
- Unsigned Device Debug: **PASS**.
- Unsigned Device Release: **PASS**.
- Logs: `/private/tmp/AgendaCue-WU19-uyonHi/{tests,debug-simulator,release-simulator,debug-device,release-device}.log`.
- Tests used `xcodebuild -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Debug -destination 'platform=iOS Simulator,id=<local test simulator>' -derivedDataPath <TestDerivedData> -resultBundlePath <FullTests.xcresult> test`.
- Builds used the same project/scheme, Debug/Release and generic iOS Simulator/iOS destinations; Device builds used `CODE_SIGNING_ALLOWED=NO`.
- `xcresulttool get test-results summary` independently confirmed 182/0/0.

## Fresh signed Release archive

- Archive: `/private/tmp/AgendaCue-WU19-uyonHi/AgendaCue-1.0.1-4-e35868b.xcarchive`.
- Start: **2026-09-03T11:49:47+0900**.
- Creation/completion: **2026-09-03T11:50:03+0900**.
- Result: **ARCHIVE SUCCEEDED**.
- Command: `xcodebuild -project CalendarAlarmFeasibility.xcodeproj -scheme CalendarAlarmFeasibility -configuration Release -destination 'generic/platform=iOS' -derivedDataPath <ArchiveDerivedData> -archivePath <archive path above> archive`.
- Version/build: **1.0.1 (4)**; Bundle ID: `com.naoki-ko.agendacue`; arm64.
- Archive signing: `Apple Development: Naoki Kondo (8G67FB9S72)`.
- Team: `67BCCSD863`.
- Archive profile: `iOS Team Provisioning Profile: *`; UUID `5e6fc84e-b8e2-4215-ac64-0934a4c04608`.
- Archive development entitlement `get-task-allow=true` is expected; export re-signs for distribution.
- `codesign --verify --deep --strict --verbose=2`: **PASS**.
- Archive log: `/private/tmp/AgendaCue-WU19-uyonHi/archive.log`.

## Archive → IPA mapping

The single fresh archive above was the input to:

`xcodebuild -exportArchive -archivePath <archive above> -exportPath /private/tmp/AgendaCue-WU19-uyonHi/Export -exportOptionsPlist /private/tmp/AgendaCue-WU19-uyonHi/ExportOptions.plist`

- Export options: method `app-store-connect`, destination `export`, automatic signing, Team `67BCCSD863`, version/build management disabled, symbol stripping enabled.
- No `-allowProvisioningUpdates` flag was used for archive/export; existing local signing assets were sufficient.
- Export completion: **2026-09-03T11:50:38+0900**, **EXPORT SUCCEEDED**.
- IPA: `/private/tmp/AgendaCue-WU19-uyonHi/Export/CalendarAlarmFeasibility.ipa`.
- IPA size: **2,013,180 bytes**.
- IPA SHA-256: `0e974c87797d0c2a1a694f9fd680ea71f0a72994e8f0be6240d0d84f1a808636`.
- Export log: `/private/tmp/AgendaCue-WU19-uyonHi/export.log`.
- Export destination was local; no upload occurred.

## Distribution package audit

- Signature: **Apple Distribution: Naoki Kondo (67BCCSD863)**.
- Strict codesign of the extracted IPA app: **PASS**, valid on disk and satisfies Designated Requirement.
- Team: `67BCCSD863`; Bundle ID: `com.naoki-ko.agendacue`.
- Store profile: `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`.
- Store profile UUID: `2085a254-5677-48a9-8199-8115dec074ad`; expiration **2027-05-06T07:22:49Z**.
- Actual app entitlements: `application-identifier=67BCCSD863.com.naoki-ko.agendacue`, team `67BCCSD863`, `get-task-allow=false`, `beta-reports-active=true`.
- Actual packaged Info.plist: version **1.0.1**, build **4**, display name **AgendaCue**, minimum iOS **26.0**.
- `ITSAppUsesNonExemptEncryption=false`.
- `PrivacyInfo.xcprivacy` present: tracking false, collected data empty, UserDefaults reason `CA92.1`.
- No embedded Frameworks, PlugIns, test bundles, or unexpected SDKs. Mach-O dependencies are system frameworks/libraries only.
- Packaged English `onboarding.allow_calendar` / `onboarding.allow_alarm`: **Continue**.
- Packaged Japanese same keys: **続ける**.
- DEBUG permission diagnostic message markers are absent from the Release executable.
- No changes to CTA, resources, privacy, backend/networking, analytics, or functional production source.

## Deviations, limits and stop line

Sandbox-limited Git metadata, Simulator service, and XCTest report-cache operations were retried with approved access; all gates then passed. No code workaround or permission-behavior change was made. Only local artifacts were created; raw account/session data and calendar content are not stored in Git.

App Store Connect = **READ ONLY / NOT MUTATED**. Upload = **NOT STARTED**. Submission = **NOT STARTED**. Hotfix release = **NOT YET RELEASED**.

No package gate remains unresolved. ChatGPT Release Candidate Review is **PASS**, reviewing Packaging Commit `e35868b0612d707c476fa51f2e1272bd9797850e` and observing State Snapshot `b210f0bbe6f751435fd307608081f272b81ad6ed`; exact receipt is in `docs/REVIEW_LOG.md`. The owner authorized docs-only Review Sync, normal branch push, fast-forward-only main merge, and normal main push. No merge commit, squash, rebase, or force push.

The archive and IPA above remain the exact reviewed artifacts and are not recreated or modified by Review Sync. Packaging Commit → exact reviewed archive → future App Store Connect Build 4 is the authoritative identity; the local IPA hash remains evidence. After main closure, STOP. Next phase is separate hotfix upload/submission. Do not change version/build, repackage, upload, create/update an App Store version record, select build, edit Review Notes, Add/Submit for Review, or release. Candidate **1.0.1 (4) remains NOT YET RELEASED**.
