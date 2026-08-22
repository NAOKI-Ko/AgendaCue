# AgendaCue App Store Release Checklist

Status is evidence-based as of WU-10 Phase B.1. `READY` is not an App Store approval or Human Gate PASS.

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
| Privacy Policy URL | PASS — PUBLIC / VERIFIED | `https://naoki-ko.github.io/agendacue-site/privacy/` |
| Support page source | READY | `site/support/index.html` |
| Informational Support page | PASS — PUBLIC / VERIFIED | `https://naoki-ko.github.io/agendacue-site/support/` |
| App Store Support URL compliance | OWNER-ACCEPTED WITH REVIEW RISK | Use `https://naoki-ko.github.io/agendacue-site/privacy/`, the same URL as Privacy Policy. No public personal contact information. Owner accepts the known App Review risk; handle any rejection only from actual reviewer feedback. Not a full-compliance PASS or internal blocker. |
| Japanese screenshot sources | PASS | 7 visually inspected JPEG sources, 1320×2868, RGB/no-alpha |
| Final Japanese screenshot package | PASS | 6 raw captures finalized in `screenshots/final-ja/`; order and factual copy finalized |
| Distribution signing | VALIDATED | Cloud Managed Apple Distribution; team `67BCCSD863`; exact Store profile; `get-task-allow = false` |
| App Store export validation | PASS | Local App Store Connect export produced an inspected IPA; no upload |
| H01–H46 | DEFERRED — POST-REVIEW / PRE-RELEASE OWNER VALIDATION | No item passed by Simulator evidence; not an App Review submission blocker under explicit owner policy |
| Final owner public-release GO / NO-GO | PENDING | Required before manual public release |
| App Store upload | NOT STARTED | Explicit owner-authorized later operation only |
| App Review submission | NOT STARTED | Explicit owner-authorized later operation only |
| Release method | MANUAL RELEASE PREFERRED | Allows owner validation after approval and before public release |

## Category rationale

Utilities is recommended as primary because AgendaCue performs one focused device utility: converting EventKit-visible calendar timing into AlarmKit alarms. Productivity is a suitable secondary category because the result supports schedule preparation and time management without becoming a general calendar editor or project-management suite.
