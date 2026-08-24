# WU-13 Fresh Distribution Package and Final Pre-Upload Audit

Audit date: 2026-08-25 (Asia/Tokyo)

1. **Branch:** `wu-10-release-gate`.
2. **Starting HEAD:** `f89ed8a0a600e0134d4e6a97e8f801ea7821ef1d`. Preflight branch/HEAD matched and the working tree was clean.
3. **Production SHA archived:** `f89ed8a0a600e0134d4e6a97e8f801ea7821ef1d`. The archive was created before this documentation-only WU-13 commit.
4. **Archive path:** `/private/tmp/AgendaCue-WU13-f89ed8a-20260825T0022.xcarchive` — fresh Release archive for the shared `CalendarAlarmFeasibility` scheme and generic iOS Device destination; **ARCHIVE SUCCEEDED**.
5. **Archive timestamp:** `2026-08-25 00:21:21 +0900`.
6. **Export path:** `/private/tmp/AgendaCue-WU13-Export-20260825T0022/` — fresh `app-store-connect` / local `export`, automatic signing, version/build management disabled; **EXPORT SUCCEEDED** at `2026-08-25 00:21:58 +0900`.
7. **IPA path:** `/private/tmp/AgendaCue-WU13-Export-20260825T0022/CalendarAlarmFeasibility.ipa`.
8. **IPA SHA-256:** `cddf317d8fd40dc54a844e0343d16cad2d3fd255d70f77179ef8e473bb330e38`.
9. **IPA size:** `2,010,460` bytes.
10. **Xcode version:** Xcode 26.6, build `17F113`.
11. **SDK version:** iPhoneOS 26.5 (`iPhoneOS26.5.sdk`); minimum deployment target iOS 26.0.
12. **Signing identity:** Exported app authority `Apple Distribution: Naoki Kondo (67BCCSD863)`. The archive’s expected intermediate signature was `Apple Development: Naoki Kondo (8G67FB9S72)`; it is not the Distribution result.
13. **Provisioning profile:** `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`; UUID `2085a254-5677-48a9-8199-8115dec074ad`; expiration `2027-05-06T07:22:49Z`; App Store profile with `get-task-allow = false`.
14. **Team ID:** `67BCCSD863` in the signature, embedded profile, and effective entitlement.
15. **App ID:** Explicit `67BCCSD863.com.naoki-ko.agendacue`.
16. **Bundle ID:** `com.naoki-ko.agendacue`. Project test bundle remains `com.naoki-ko.agendacue.tests`; no test bundle is packaged.
17. **Version/build:** `CFBundleShortVersionString = 1.0`; `CFBundleVersion = 1`. Display name is `AgendaCue`, supported platform is `iPhoneOS`, `UIDeviceFamily = [1]`, and `MinimumOSVersion = 26.0`. No internal project name is customer-facing.
18. **get-task-allow:** **PASS — `false`** in both the exported effective entitlements and embedded Store profile.
19. **Codesign verification:** **PASS.** `codesign --verify --deep --strict --verbose=4` reports the exported app valid on disk and satisfying its designated requirement.
20. **Entitlements:** Exactly `application-identifier`, `com.apple.developer.team-identifier`, `get-task-allow = false`, and `beta-reports-active = true`. No Push Notifications, App Groups, iCloud, Associated Domains, unexpected Keychain group, network extension, or other unexpected capability is present.
21. **AppIcon/resource audit:** **PASS.** The signed app contains nonempty `Assets.car`, compiled no-alpha AppIcon PNGs, `Info.plist`, executable, `PrivacyInfo.xcprivacy`, signature resources, and embedded Store profile. The sole source AppIcon remains the accepted 1024×1024 PNG with no alpha (SHA-256 `2a70f0fb70cd4557fa1ada0e63f10de2bf9e9f11bdd4f28f3b01e71ad7056fc6`) and was compiled without modifying assets.
22. **PrivacyInfo audit:** **PASS.** The exported manifest declares `NSPrivacyTracking = false`, no collected data types, and only the UserDefaults accessed-API category with reason `CA92.1`. The package is consistent with **No Data Collected**.
23. **Purpose-string audit:** **PASS.** Nonempty Japanese EventKit full-access and AlarmKit descriptions are present and state read-only calendar/alarm purposes accurately.
24. **BGTask/background mode audit:** **PASS.** `BGTaskSchedulerPermittedIdentifiers` contains only `com.naoki-ko.agendacue.refresh`; `UIBackgroundModes` contains only `fetch`.
25. **Linked-framework/SDK audit:** **PASS.** Mach-O linkage contains Apple system frameworks and Swift runtime libraries only: Foundation/CoreFoundation, ActivityKit/AlarmKit, AppIntents, BackgroundTasks, Combine, EventKit, SwiftData, SwiftUI/UIKit, Objective-C/system and Swift runtime libraries. The app embeds no `Frameworks` or `PlugIns` directory, Swift Package declaration, third-party SDK, analytics/ad/tracking SDK, provider-specific calendar API, StoreKit, AI integration, account/login system, backend, or networking dependency.
26. **DEBUG/sample leakage audit:** **PASS.** The actual exported app and separate symbol metadata contain no `-UIScenario`/`UIScenario`, DEBUG scenario names, WU-00/WU-11/WU-12 strings, WU-12 long accessibility fixture strings, test method/target names, XCTest content, feasibility view/model names, evidence documents, or test bundle. Generic internal implementation/module names remain allowed and do not expose reachable sample behavior.
27. **Private-data leakage audit:** **PASS for the signed runtime payload.** No credentials, signing private keys, API keys/tokens, real calendar/customer data, evidence paths, or local filesystem paths were found in `Payload/CalendarAlarmFeasibility.app`. The IPA’s separate Xcode-generated `Symbols/*.symbols` symbolication metadata does contain compilation source paths, including the local workspace path. This metadata is outside the signed runtime app payload, contains no file contents or credentials, is not runtime-reachable, and is a normal App Store export symbol artifact; it is recorded as a non-blocking exact finding rather than misreported as a whole-ZIP zero-match.
28. **XCTest:** Fresh WU-13 rerun **PASS — 170 tests, 0 failures, 0 skipped** on iPhone 17 Pro Simulator, iOS 26.5. Result bundle: `/private/tmp/AgendaCue-WU13-Tests/Logs/Test/Test-CalendarAlarmFeasibility-2026.08.25_00-21-07-+0900.xcresult`.
29. **Production diff:** **NONE.** Archive-time and post-export checks show no difference from `f89ed8a0a600e0134d4e6a97e8f801ea7821ef1d` in Production source, Xcode project/configuration, tests, entitlements, or assets. WU-13 changes this evidence document only.
30. **Store screenshot status:** **FROZEN / OWNER APPROVED** per WU-13 owner direction. The final set remains six Japanese iPhone JPEGs, each 1320×2868, RGB/no alpha. No screenshot was modified or regenerated.
31. **Physical-device gate status:** **PENDING / NOT PASS.** Physical AlarmKit/EventKit/Watch/background validation, real VoiceOver, Accessibility Inspector, and UI-010 interactive sticky-header validation were not executed or changed by WU-13.
32. **H01–H46 status:** **PENDING / NOT PASS.** App Review submission may proceed only under owner policy and separate authorization; public release remains manual and requires later owner GO/NO-GO.
33. **B.2 IPA status:** **STALE — MUST NOT BE UPLOADED.** Historical evidence is preserved; that artifact is not a current candidate.
34. **Fresh IPA status:** **CURRENT WU-13 UPLOAD CANDIDATE.** It is the only current candidate if the paths remain available and the artifact SHA-256 matches this report. It has not been uploaded or submitted.
35. **Final package recommendation:** **READY FOR UPLOAD AUTHORIZATION.** Fresh archive/export, Distribution signing, identity, strict codesign, entitlements, resources/AppIcon, privacy/configuration, SDK/linkage, leakage, fresh XCTest, and Production-freeze audits pass. This is not upload authorization and not `PUBLIC RELEASE GO`.

## External-state hard stop

- Push: **NOT PERFORMED**
- Merge: **NOT PERFORMED**
- Tag: **NOT PERFORMED**
- Upload: **NOT PERFORMED — SEPARATE EXPLICIT AUTHORIZATION REQUIRED**
- Submission: **NOT PERFORMED — SEPARATE EXPLICIT AUTHORIZATION REQUIRED**

**FRESH APP STORE DISTRIBUTION PACKAGE CREATED**

**FINAL PRE-UPLOAD AUDIT PASSED**

**READY FOR UPLOAD AUTHORIZATION**

**PUBLIC RELEASE GATE REMAINS PENDING**
