# App Privacy Audit

Audit date: 2026-08-22. Scope: source and built Release Simulator product from WU-10 Phase A.2 (`com.naoki-ko.agendacue`).

## Recommended App Store Connect answer

**Data Collection: No, this app does not collect data.**

This recommendation is based on the audited implementation:

- Calendar events and calendar/source names are read through EventKit and processed on device.
- Settings, calendar selections, event overrides, alarm mappings, and onboarding completion are stored locally with SwiftData/UserDefaults.
- No calendar content is written, uploaded, sold, shared, or used for tracking.
- There is no account, login, backend, analytics, advertising, telemetry, crash-reporting SDK, cloud storage, or external API integration.
- There is no `URLSession`, Network.framework use, third-party package, advertising identifier, or tracking-domain declaration.
- Opening the app's page in iOS Settings uses the system `UIApplication.openSettingsURLString`; it is not an external data transfer.

App Store Connect wording must describe developer collection, meaning transmission off the device for developer/third-party access. EventKit access is sensitive local processing but, as implemented, is not developer data collection.

## Privacy manifest

`CalendarAlarmFeasibility/PrivacyInfo.xcprivacy` is included at the root of the built app. It declares:

- tracking: false;
- collected data types: none;
- UserDefaults required-reason API: `CA92.1`, because app-only onboarding completion is stored and read locally.

No tracking domains are declared. The Production identity is integrated; recheck the generated archive privacy report after signing becomes available and before submission. Apple requires covered required-reason APIs to be declared in a privacy manifest; the declaration here is limited to audited use. References: [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [Describing use of required-reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).

## Owner inputs

- Public Privacy Policy URL/status must be decided for metadata/support use.
- The owner must verify that App Store Connect answers remain accurate if code, dependencies, or business practices change.
