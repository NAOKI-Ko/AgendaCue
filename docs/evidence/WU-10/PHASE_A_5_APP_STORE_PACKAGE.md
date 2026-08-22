# WU-10 Phase A.5 — App Store Package Preparation

Audit date: 2026-08-22. Parent: `17ae16d2b4dbf344ef57da0fc1c528ff31892c82`.

## Package status

- Japanese metadata: **FINALIZED / READY FOR OWNER ENTRY**.
- English metadata: **DRAFT ONLY — DO NOT PUBLISH YET**; Production UI is Japanese-only.
- Category recommendation: Primary Utilities / Secondary Productivity.
- Copyright: `© 2026 Naoki Kondo`; no conflicting legal name was found in repository source-of-truth, and the existing signing identity uses Naoki Kondo.
- App Review Notes: finalized with read-only EventKit, AlarmKit, permission/recovery, event-selection/lead-time, exact title, no-login/backend, and all-day exclusion instructions.
- App privacy recommendation: **No data collected**; existing privacy/source audit and bundled `PrivacyInfo.xcprivacy` remain unchanged.

Static, mobile-friendly Japanese sources were created at `docs/release/site/privacy/index.html` and `docs/release/site/support/index.html`, with hosting READMEs. No external dependency, analytics, tracking resource, or invented email exists. Both public URLs remain **OWNER INPUT REQUIRED — PUBLIC HOSTING URL**, and the contact method remains owner input.

## Device family and screenshots

`TARGETED_DEVICE_FAMILY = 1` in app Debug and Release settings: AgendaCue ships as iPhone-only under the current configuration. No iPad target support was changed and no iPad screenshot set is required by that configuration.

Screenshot source device: iPhone 17 Pro Max Simulator, iOS 26.5, 6.9-inch class. Actual files are portrait 1320×2868 JPEG, RGB/no-alpha, an accepted size in Apple's current screenshot specification:

1. `01_alarm_timeline.jpg`
2. `02_alarm_timeline_dates.jpg`
3. `03_event_detail_default.jpg`
4. `04_event_detail_custom.jpg`
5. `05_calendar_selection.jpg`
6. `06_settings.jpg`
7. `07_onboarding.jpg`

All seven were visually inspected. They use only deterministic DEBUG-only controlled sample data, contain no personal calendar contents, fake permission dialog, fake AlarmKit screen, marketing overlay, debug control/status, unsupported feature, or clipping. The custom detail image was recaptured from a fresh install after initial scroll restoration caused clipping. Files have a controlled 9:41 status bar. `SCREENSHOT_COPY_JA.md` keeps factual headlines separate from raw captures.

## Release checklist and scope

`APP_STORE_RELEASE_CHECKLIST.md` records ready, draft, blocked, pending, and not-started states without converting unresolved work to PASS. Remaining blockers include public Privacy Policy and Support URLs/contact, screenshot owner composition/order, App Store distribution signing/export validation, H01–H46, final owner GO/NO-GO, and explicit later upload/submission.

Phase A.5 changes only docs and marketing source images. No Production Swift, Xcode project, behavior, identity, privacy manifest, or AppIcon changed. A dedicated Debug Simulator build and Production UI launch were used for controlled capture; the unchanged normal Release Simulator product was also installed/launched without sample arguments and passed. Per the WU instruction, the full 160-test suite was not rerun for docs/assets-only additions.

Human Gate: **PENDING / OWNER EXECUTION**. No merge, push, upload, distribution, App Store Connect mutation, or submission occurred.
