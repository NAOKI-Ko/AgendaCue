# WU-10 Phase A Automated Release Evidence

Audit date: 2026-08-20. Parent: `2f32f35926e13b35fc78698b16c1dccd757c0504`. Environment: Xcode 26.6 (17F113), iOS SDK/Simulator 26.5, iPhone 17 Pro Simulator.

## Automated result

- Full XCTest: **PASS — 160 tests, 0 failures**.
- Specific iPhone 17 Pro Simulator Debug build: **PASS**.
- Generic iOS Simulator Debug build: **PASS**.
- Generic iOS Device Debug unsigned build: **PASS**.
- Generic iOS Simulator Release build: **PASS**.
- Generic iOS Device Release unsigned build: **PASS**.
- Release Simulator launch without arguments: **PASS**; first-launch Japanese welcome rendered and no debug/feasibility UI appeared.
- Clean Debug and Release compiler warning extraction: **0 warnings, 0 errors** after the Sendable fix.

## Warning audit

Baseline warning:

`EventOverrideService.swift:14:132: warning: converting non-Sendable function value to '@Sendable () -> Date' may introduce data races`

Root cause was the default `Date.init` function value being converted to an explicitly Sendable closure type. It was narrowly replaced with `{ Date() }`; no state, isolation, timing, or business behavior changed. Clean Debug and Release rebuilds emit no warning. Existing override/reconciliation regression tests passed.

## Identity and version audit

- App bundle ID: `com.example.CalendarAlarmFeasibility` — **BLOCKED / OWNER INPUT REQUIRED**.
- Test bundle ID: `com.example.CalendarAlarmFeasibilityTests` — development placeholder; update consistently after app identity.
- Internal Product/CFBundleName remains `CalendarAlarmFeasibility`; `CFBundleDisplayName` is the owner-approved customer name `AgendaCue`.
- Marketing version/build: `1.0` / `1`, consistent between build settings and Info.plist.
- Signing: Automatic, team `67BCCSD863` configured; Production App ID/profile/account validity not proven.
- Entitlements: no source `.entitlements`, App Groups, URL schemes, or extra capabilities found. Simulator signature contains only its generated application identifier.

Exact bundle replacement locations: Debug and Release `PRODUCT_BUNDLE_IDENTIFIER` in `CalendarAlarmFeasibility.xcodeproj/project.pbxproj`. BGTask replacement locations: `ReliabilityPolicy.backgroundTaskIdentifier`, `BGTaskSchedulerPermittedIdentifiers` in Info.plist, and matching tests. The BGTask value must use the approved Production bundle namespace.

## BGTask audit

Exactly one logical `BGAppRefreshTask` identifier is registered, permitted, cancelled/replaced, and submitted: `com.example.CalendarAlarmFeasibility.refresh`. Info.plist contains the same single permitted identifier and only the `fetch` background mode. Semantics are unchanged, but the example namespace is **BLOCKED pending Production Bundle ID**.

## AlarmKit audit

- Production composition uses `AlarmKitSystemScheduler`; the WU-00 scheduler/UI is excluded from Release compilation and unreachable from Production navigation.
- Authorization is explicitly requested only from the onboarding action while not determined; denied/revoked states use recovery UI.
- Japanese, nonempty `NSAlarmKitUsageDescription` exists.
- Fixed one-shot `.fixed(date)` scheduling and the standard AlarmKit configuration remain; no snooze, multiple alarms, local-notification fallback, or custom sound system exists.
- Custom title is the exact nonblank event title; blank/whitespace-only uses `予定`. No app/calendar/time/lead prefix or suffix is added. Stop action copy is Japanese `停止`.

## EventKit audit

Production EventKit boundaries expose discovery/fetch only. Source scan found no EventKit `save`, `remove`, `commit`, or mutation call. `requestFullAccessToEvents()` is explicit; the Japanese purpose string says the calendar is not changed. Event/calendar/source titles remain source-provided except the safe blank event-title fallback. There is no Google OAuth, Microsoft Graph, Lifebear API, provider SDK, or external API. Compatibility claim is limited to events registered in iPhone Calendar and visible through EventKit.

## Onboarding audit

Welcome → Calendar rationale/request → Alarm rationale/request is first-launch state. Requests run only for `.notDetermined`; denial can complete; completion is stored separately in UserDefaults; revocation stays in normal recovery UI. There is no account, login, profile, or marketing carousel. Existing light/dark/Large/Accessibility XXXL evidence and semantic order tests remain applicable. Real VoiceOver and device prompts are Human Gate items.

## Unified timeline/live clock audit

Tabs remain exactly `アラーム / 設定`. Presentation window remains past 14 through future 14 days; reconciliation remains `[now, now + 14 days)`. Past items are display-only. The root-owned clock runs while active, refreshes on activation/time signals, does not fetch/reconcile/persist/schedule, scrolls initially once, does not force-scroll on ticks, and retains `現在へ`. All focused regression tests passed.

## Privacy and dependency audit

No URLSession, Network.framework, third-party package, analytics, telemetry, crash SDK, ads, tracking, account system, cloud storage, StoreKit, or external API call was found. EventKit content and app-owned settings/mappings stay local. `PrivacyInfo.xcprivacy` declares no tracking/no collected data and the audited UserDefaults reason `CA92.1`; it is present in the built Release bundle. Recommended App Store privacy answer is “no data collected,” subject to final owner confirmation and archive report.

## App icon audit

Release target points to `AppIcon`. The catalog has one universal iOS 1024×1024 PNG; source is RGB PNG and `hasAlpha: no`. Asset compilation succeeds in Debug/Release. No alternate/test icon asset is present. Artwork is technically valid but not owner-approved: **OWNER INPUT REQUIRED — FINAL APP ICON APPROVAL**.

## Release configuration and leakage audit

- Deployment target iOS 26.0; iPhone family only.
- Release has `ENABLE_TESTABILITY=NO`, whole-module optimization, assertions disabled, product validation enabled, and no DEBUG compilation condition.
- `-UIScenario` samples are gated by `#if DEBUG`; Release executable string audit found no `UIScenario`, `WU-00`, or feasibility alarm copy.
- WU-00 feasibility source remains available for historical Debug tests but seven feasibility-only source files are excluded from Release compilation.
- Shared scheme archives Release. Asset, Info.plist, privacy manifest, EventKit/AlarmKit descriptions, and Background Mode are target-bound.

## Japanese residual audit

Production-visible app copy and permission descriptions are Japanese. Source-owned calendar/event/source names and Apple product/framework names are intentionally unchanged. Internal diagnostics/identifiers are not rendered. The only actionable English AlarmKit action (`Stop`) was changed to `停止`.

## Scope audit

No scheduling date/identity/lifecycle, reconciliation horizon, past-event eligibility, background semantics, persistence schema, lead-time set, navigation structure, or product capability changed. EventKit remains read-only; current divider and past display remain presentation-only; live clock has no scheduling side effects. No snooze, multiple alarms, arbitrary leads, keyword/calendar rules, Widget, watchOS app, AI, backend, login, analytics, ads, subscription/IAP, or custom sound was introduced.

## Archive readiness

**BLOCKED — archive not attempted.** An unsigned generic Release device build passed, but an App Store archive would still contain the forbidden example bundle/BGTask namespace and unapproved icon. Production Bundle ID, matching BGTask ID, owner-approved icon, and valid Production signing/profile must be supplied first. The display identity is now owner-approved and integrated as `AgendaCue`. No archive, upload, or submission occurred.

Human Gate status: **PENDING — REQUIRED**. Phase A result: **HUMAN GATE READY**, not release complete.
