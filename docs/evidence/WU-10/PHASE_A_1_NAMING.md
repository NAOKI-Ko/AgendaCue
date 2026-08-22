# WU-10 Phase A.1 — AgendaCue Naming Evidence

Owner-approved V1 brand: **AgendaCue**.

## Integration

- `CFBundleDisplayName`: `AgendaCue` in the source Info.plist and built Debug/Release app.
- Internal target, Swift module, executable, source paths, and test host remain `CalendarAlarmFeasibility`; these are non-customer-facing implementation identities and were deliberately not broadly renamed.
- Japanese App Store name: `AgendaCue`; subtitle: `予定をアラームで確実にお知らせ`.
- English App Store name: `AgendaCue`; subtitle: `Calendar alerts you won’t miss`.
- Apple App Store Connect limit: App Name and Subtitle are each no more than 30 characters. Counts are 9, 15, and 30 respectively.
- README, current Product Spec, Start Here, Project State, screenshot plan, and current release evidence use AgendaCue where customer-facing/current product naming matters.
- Historical Work Unit evidence and internal identifiers were not rewritten.

Apple reference: [App information — name and subtitle limits](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information).

## Automated verification

- Full regression: **160 tests passed, 0 failures**.
- Specific iPhone 17 Pro Simulator Debug build: **PASS**.
- Generic iOS Simulator Release build: **PASS**.
- Generic iOS Device Release unsigned build: **PASS**.
- Production Release Simulator launch without sample arguments: **PASS**.
- Built Release Info.plist: `CFBundleDisplayName = AgendaCue`.
- Installed Simulator application record: `CFBundleDisplayName = AgendaCue` while internal executable/name remains `CalendarAlarmFeasibility`.

## AlarmKit invariant

The Production AlarmKit presentation path is unchanged. Its custom title remains the exact nonblank event title, with `予定` only for blank/whitespace titles. `AgendaCue` is not prepended or appended. Existing focused title regression tests remain part of the 160-test suite.

## Unresolved identity

- `PRODUCT_BUNDLE_IDENTIFIER`: `com.example.CalendarAlarmFeasibility` — OWNER INPUT REQUIRED.
- BGTask identifier: `com.example.CalendarAlarmFeasibility.refresh` — OWNER INPUT REQUIRED.
- Expected final BGTask form: `<production-bundle-id>.refresh`.

Once supplied, update:

1. App Debug/Release `PRODUCT_BUNDLE_IDENTIFIER` in `CalendarAlarmFeasibility.xcodeproj/project.pbxproj`.
2. Test Debug/Release bundle ID in the same project file after the owner approves its relationship to the Production namespace; test-host executable paths remain internal unless PRODUCT_NAME is separately changed.
3. `ReliabilityPolicy.backgroundTaskIdentifier` in `CalendarAlarmFeasibility/Production/Services/ReliabilityService.swift`.
4. `BGTaskSchedulerPermittedIdentifiers` in `CalendarAlarmFeasibility/Info.plist`.
5. Current release/project-state documentation. Reliability tests reference the policy constant rather than duplicating the placeholder, so they require rerunning but no value replacement.

No Bundle ID or BGTask namespace was fabricated.

## Scope

No domain, AlarmKit scheduling, EventKit, reconciliation, persistence schema, BackgroundTasks semantics, icon artwork, or V1/V1.1 functionality changed.
