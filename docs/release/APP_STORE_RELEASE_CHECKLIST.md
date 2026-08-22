# AgendaCue App Store Release Checklist

Status is evidence-based as of WU-10 Phase A.6. `READY` is not an App Store approval or Human Gate PASS.

| Item | Status | Evidence / next action |
|---|---|---|
| App name | READY | `AgendaCue` |
| Bundle ID | READY | `com.naoki-ko.agendacue` |
| Version/build | READY | `1.0 / 1` |
| Final AppIcon | READY | Owner-approved, integrated, technical validation PASS |
| Japanese metadata | READY FOR OWNER ENTRY | Finalized in `APP_STORE_METADATA_JA.md` |
| English metadata | DRAFT ONLY — DO NOT PUBLISH | Production UI is Japanese-only |
| Category | RECOMMENDED | Primary Utilities / Secondary Productivity; owner must set in App Store Connect |
| Copyright | READY | `© 2026 Naoki Kondo` |
| App privacy answers | READY FOR OWNER CONFIRMATION | Recommended: No data collected |
| PrivacyInfo.xcprivacy | READY | Present in signed archive |
| Privacy Policy page source | READY | `site/privacy/index.html` |
| Privacy Policy URL | BLOCKED — OWNER INPUT | Publish stable HTTPS URL |
| Support page source | READY | `site/support/index.html` |
| Support URL | BLOCKED — OWNER INPUT | Publish stable HTTPS URL |
| Japanese screenshot sources | READY FOR OWNER REVIEW | 7 JPEGs, 1320×2868, RGB/no-alpha |
| Screenshot marketing compositions/order | PENDING — OWNER | Raw sources contain no baked headline |
| Distribution signing | VALIDATED | Cloud Managed Apple Distribution; team `67BCCSD863`; exact Store profile; `get-task-allow = false` |
| App Store export validation | PASS | Local App Store Connect export produced an inspected IPA; no upload |
| H01–H46 | PENDING — OWNER EXECUTION | No item passed by Simulator evidence |
| Final owner GO / NO-GO | PENDING | Requires current candidate and Human Gate evidence |
| App Store upload | NOT STARTED | Explicit owner-authorized later operation only |
| App Review submission | NOT STARTED | Explicit owner-authorized later operation only |

## Category rationale

Utilities is recommended as primary because AgendaCue performs one focused device utility: converting EventKit-visible calendar timing into AlarmKit alarms. Productivity is a suitable secondary category because the result supports schedule preparation and time management without becoming a general calendar editor or project-management suite.
