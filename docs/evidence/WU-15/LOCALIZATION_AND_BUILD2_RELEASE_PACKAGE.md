# WU-15 Localization and Build 2 Release Package

Audit date: 2026-08-25 (Asia/Tokyo)

## Release identity and scope

1. Branch: `wu-10-release-gate`.
2. Starting HEAD: `4c4fbff6db84542d95e2b31f0a24d488767bf9dc`.
3. WU-15 commit: this single WU-15 commit; the immutable SHA is reported after commit creation because a commit cannot contain its own hash.
4. Version/build: `CFBundleShortVersionString = 1.0`; `CFBundleVersion = 2` in the final exported app.
5. Customer-facing display name remains `AgendaCue`. Project, target, scheme, module, and executable remain internally named `CalendarAlarmFeasibility`.
6. Supported customer localizations are exactly Japanese (`ja`) and English (`en`). Japanese remains the development language.
7. No upload, TestFlight distribution, submission, push, merge, tag, or public release was performed.

## Localization implementation

Apple String Catalogs are the sole localization architecture:

- `CalendarAlarmFeasibility/Localizable.xcstrings`: 83 semantic UI/accessibility keys, each with complete `ja` and `en` values (166 localized values).
- `CalendarAlarmFeasibility/InfoPlist.xcstrings`: 2 purpose-string keys, each with complete `ja` and `en` values (4 localized values).
- Total: 85 keys / 170 language-specific values.

Production changes are limited to:

- `CalendarAlarmFeasibility.xcodeproj/project.pbxproj`
- `CalendarAlarmFeasibility/Info.plist`
- `CalendarAlarmFeasibility/Localizable.xcstrings`
- `CalendarAlarmFeasibility/InfoPlist.xcstrings`
- `CalendarAlarmFeasibility/Production/Features/ProductionUXModels.swift`
- `CalendarAlarmFeasibility/Production/Features/ProductionUXView.swift`
- `CalendarAlarmFeasibility/Production/Services/AlarmSchedulingService.swift`
- `CalendarAlarmFeasibility/Production/Services/CalendarSourceService.swift`

The complete Production string audit found no untranslated app-owned Release UI strings. Remaining Japanese Swift literals are enclosed in `#if DEBUG` and are synthetic event/calendar fixture content. User-created EventKit titles and calendar names remain unchanged by design. The fallback title resolves to `予定` in Japanese and `Event` in English. AlarmKit stop copy resolves to `停止` / `Stop`.

Foundation locale-aware date/time formatting remains authoritative. English QA showed native English month, weekday, and 12-hour time formatting; Japanese formatting and chronological/domain behavior remain unchanged.

The final IPA contains both `ja.lproj` and `en.lproj`, each with compiled `Localizable.strings` and `InfoPlist.strings`. Runtime inspection found no localization keys rendered in the captured UI.

## Purpose strings and export compliance

Final English purpose strings:

- Calendar: “AgendaCue uses read-only access to your calendar to find events and schedule alarms before they begin.”
- Alarm: “AgendaCue uses alarms to alert you before your calendar events.”

The Japanese Build 1 purpose strings are preserved exactly through the Japanese `InfoPlist` localization.

A source/linkage audit found no CryptoKit, CommonCrypto, OpenSSL, custom encryption, network client, or third-party cryptography. The app uses only platform services required by the product. `ITSAppUsesNonExemptEncryption = false` is therefore present in the final built `Info.plist`.

## Tests and builds

- Focused localization/configuration XCTest: **4 passed, 0 failed**.
- Complete XCTest: **174 passed, 0 failed, 0 skipped** on iPhone 17 Pro Simulator, iOS 26.5. Previous baseline was 170; four focused tests were added.
- Final result bundle: `/private/tmp/AgendaCue-WU15-ReauditTests/Logs/Test/Test-CalendarAlarmFeasibility-2026.08.25_01-43-10-+0900.xcresult`.
- Debug Simulator build: **PASS**.
- Release Simulator build: **PASS**.
- Debug unsigned iphoneos build: **PASS**.
- Release unsigned iphoneos build: **PASS**.
- No new actionable compiler warning was observed. An initial parallel-build `build.db` lock was an orchestration collision; isolated DerivedData reruns passed.

The existing domain suite remains green. Localization did not change EventKit read-only behavior, AlarmKit scheduling, alarm-date calculations, lead-time rules, event overrides, all-day exclusion, reconciliation, duplicate prevention, cleanup, background refresh, timeline ordering, local-only persistence, or privacy behavior.

## Japanese, English, and Dynamic Type visual QA

Ten Simulator captures under `docs/evidence/WU-15/ui/` cover onboarding, Alarm timeline, event detail, calendar selection, and Settings across iPhone 17e, iPhone 17 Pro, and iPhone 17 Pro Max; Large, XXXL, and Accessibility XXXL; and Light/Dark appearances.

Japanese result: **PASS — no material regression**. English result: **PASS**. Dynamic Type result: **PASS**. English app-owned UI was English, localized dates/times were natural, keys did not leak, controls remained reachable, and large content expanded vertically in scrollable containers without material overlap or horizontal overflow. Japanese DEBUG fixture titles visible in English captures are intentional stand-ins for user-created event/calendar content and are outside localization scope.

Evidence:

- `01-ja-main-large-light-pro.png`
- `02-en-main-xxxl-light-pro.png`
- `03-ja-detail-axxxl-dark-pro.png`
- `04-en-detail-axxxl-dark-pro.png`
- `05-ja-calendars-axxxl-light-small.png`
- `06-en-calendars-axxxl-light-small.png`
- `07-ja-settings-large-light-max.png`
- `08-en-settings-xxxl-dark-max.png`
- `09-ja-onboarding-large-light-pro.png`
- `10-en-onboarding-large-light-pro.png`

VoiceOver, Accessibility Inspector, and UI-010 interactive sticky-header validation remain **PENDING / NOT PASS** because they were not executed in this WU.

## English (U.S.) App Store metadata

Status: **READY FOR OWNER ENTRY — App Store Connect was not modified**.

App Name: `AgendaCue - Calendar Alarm`

Subtitle: `Alarms before calendar events`

Promotional Text:

> Never miss an important calendar event. AgendaCue reads your iPhone calendar and sounds a real alarm before each event at the lead time you choose.

Description:

> AgendaCue is a simple calendar alarm app that reads events from your iPhone calendar and sounds an alarm before they begin.
>
> Have you ever added an important event to your calendar, only to realize too late that it had already started?
>
> AgendaCue is designed to reduce those missed moments.
>
> ■ Alarms before calendar events
>
> Choose when you want the alarm to sound before an event:
>
> • 5 minutes  
> • 10 minutes  
> • 15 minutes  
> • 30 minutes  
> • 60 minutes
>
> ■ Customize alarms for individual events
>
> Use your default alarm timing for most events, then customize important events individually.
>
> For example, you can set one event to alert you 15 minutes before it starts, or turn the alarm off for events that do not need one.
>
> ■ See today and upcoming events
>
> View today's events and upcoming events in a clear chronological timeline.
>
> The current time is displayed so you can quickly see what is coming next.
>
> ■ Choose which calendars to use
>
> Select the calendars you want AgendaCue to display and use for alarms, such as work or personal calendars available through the iPhone Calendar app.
>
> ■ No account required
>
> AgendaCue does not require registration or login.
>
> ■ Your settings stay on your device
>
> App settings are stored locally on your iPhone.
>
> AgendaCue does not send your calendar data to its own server.
>
> ■ Read-only calendar access
>
> AgendaCue only reads calendar events.
>
> It does not create, edit, or delete events in your calendar.
>
> AgendaCue is made for people who use their calendar but want something harder to miss than a standard notification.

Keywords: `reminder,schedule,meeting,planner,event,appointment,work,alarm clock,time management`

- Support URL: `https://naoki-ko.github.io/agendacue-site/support/`
- Marketing URL: `https://naoki-ko.github.io/agendacue-site/`
- Privacy Policy URL: `https://naoki-ko.github.io/agendacue-site/privacy/`

## English store-image variants

Result: **BLOCKED — SOURCE NOT AVAILABLE; image-editing portion stopped only**.

The repository and the available Codex workspace contain no directly editable approved 1242×2688 Japanese store compositions (no PSD/AI/Sketch/Figma/XCF/Affinity source and no final 1242×2688 image set). The only repository set is six 1320×2868 JPEG app screenshots at `docs/release/screenshots/final-ja/`; these are raw Japanese app captures, not editable marketing compositions with separable external copy.

Generating or reconstructing the compositions would risk changing the embedded app screenshot, AppIcon, placement, background, or hierarchy and is explicitly prohibited. Image generation was therefore not used. No fabricated English replacements were created.

- Required English output count: 6.
- Actual English output count: 0.
- Required dimensions: 1242×2688 PNG, RGB/sRGB, no alpha.
- Actual dimensions: **N/A — no compliant source/output**.
- To unblock: provide the six approved directly editable Japanese compositions or layered source with the embedded screenshot and external copy independently addressable.

## Fresh Build 2 distribution package

- Final archive: `/private/tmp/AgendaCue-WU15-Build2-20260825T014332.xcarchive`.
- Archive creation: `2026-08-25T01:43:48+0900`; **ARCHIVE SUCCEEDED**.
- Final export directory: `/private/tmp/AgendaCue-WU15-Build2-Export-20260825T014332/`.
- IPA: `/private/tmp/AgendaCue-WU15-Build2-Export-20260825T014332/CalendarAlarmFeasibility.ipa`.
- IPA export/sign time: `2026-08-25T01:44:10+0900`; **EXPORT SUCCEEDED**.
- IPA SHA-256: `00b3867181ddaa6c478750de87b88f272c29d883bd427d09f501b27bc931c060`.
- IPA size: `2,010,318` bytes.
- Xcode 26.6 (`17F113`), iPhoneOS 26.5 SDK, minimum deployment iOS 26.0.

The earlier `20260825T014036` WU-15 package failed the DEBUG-string audit and is **STALE — DO NOT USE**. The final `20260825T014332` package is the only Build 2 upload candidate. WU-13 Build 1 is also **STALE — DO NOT USE FOR THE FINAL ENGLISH-LOCALIZED RELEASE**.

## Final package audit

- Exported authority: `Apple Distribution: Naoki Kondo (67BCCSD863)`.
- Team ID: `67BCCSD863`.
- Explicit application identifier: `67BCCSD863.com.naoki-ko.agendacue`.
- Bundle ID: `com.naoki-ko.agendacue`.
- Store provisioning profile: `iOS Team Store Provisioning Profile: com.naoki-ko.agendacue`; UUID `2085a254-5677-48a9-8199-8115dec074ad`; expiration `2027-05-06T07:22:49Z`.
- `get-task-allow = false` in the exported effective entitlements and Store profile.
- `codesign --verify --deep --strict`: **PASS**, valid on disk and satisfies designated requirement.
- Effective entitlements are only application identifier, team identifier, `get-task-allow = false`, and `beta-reports-active = true`.
- `UIDeviceFamily = [1]` (iPhone only), platform `iPhoneOS`, minimum OS 26.0.
- Nonempty `Assets.car`, compiled no-alpha RGB AppIcons, `PrivacyInfo.xcprivacy`, both localization directories, and the Store profile are present.
- Privacy manifest: tracking false, collected-data list empty, UserDefaults accessed API only with reason `CA92.1`; consistent with No Data Collected.
- Purpose strings: Japanese and English compiled resources both present and exact.
- Export compliance: `ITSAppUsesNonExemptEncryption = false` in the exported product.
- Background configuration: only `com.naoki-ko.agendacue.refresh` and background mode `fetch`.
- Linkage: Apple system frameworks and Swift runtime only. No third-party SDK, analytics, ads, tracking, backend, account system, StoreKit, AI, or unexpected network framework.
- Runtime structure contains no embedded `Frameworks` or `PlugIns`, so no test bundle is packaged.
- Final signed runtime payload has zero matches for `UIScenario`, DEBUG scenario/fixture names, XCTest/WU markers, local `/Users/naoki` paths, credential markers, or private calendar/customer data.
- The export's separate Xcode symbol metadata may contain normal compilation source paths; it is outside the signed runtime payload and contains no source contents or credentials.

Final package result: **FINAL BUILD 2 PACKAGE AUDIT PASSED**. The binary/package is ready for upload authorization, but the complete WU-15 release bundle remains blocked only on the unavailable editable English store-image source.

## Remaining manual and external gates

- Physical-device validation: **PENDING / NOT PASS**.
- H01–H46: **PENDING / NOT PASS**.
- VoiceOver: **PENDING / NOT PASS**.
- Accessibility Inspector: **PENDING / NOT PASS**.
- UI-010 interactive sticky-header validation: **PENDING / NOT PASS**.
- App Store Connect upload: **NOT PERFORMED**.
- App Review submission: **NOT PERFORMED**.
- TestFlight distribution: **NOT PERFORMED**.
- Public release: **NOT AUTHORIZED / NOT PERFORMED**.
- Push/merge/tag: **NOT PERFORMED**.

Working tree is required to be clean after the single WU-15 commit.
