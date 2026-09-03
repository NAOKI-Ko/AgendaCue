# WU-20 — Hotfix App Review Submission

Evidence date: **2026-09-03 (Asia/Tokyo)**.

## Result

**SUBMISSION PASS — WAITING FOR REVIEW**. This is submission evidence, not Apple approval, public release, or a ChatGPT final submission-state review receipt.

- App: **AgendaCue - カレンダーアラーム**.
- Platform / submitted candidate: **iOS 1.0.1 (4)**.
- Bundle ID: `com.naoki-ko.agendacue`.
- Actual post-submit status: **審査待ち / Waiting for Review**.
- Submission date shown by App Store Connect: **2026年9月3日 16:58** (JST).
- Current public release remains **1.0 (3) — PUBLICLY RELEASED**.
- Candidate **1.0.1 (4) — SUBMITTED / NOT YET PUBLICLY RELEASED**.
- Release policy: **automatic after approval**, all users, no phased release. Existing automatic policy preserved; no manual release action.
- Warnings: **none observed** in upload/processing/submission completion.
- Unresolved submission blockers: **none observed**. Apple review/approval/release and ChatGPT final submission-state review remain pending.

## Phase 0 — Before App Store Connect mutation

- Branch `main`; HEAD and origin/main both `b6f8a506bf1feef4ecac685e9818b82de352bb5a`.
- Working tree clean; ahead/behind **0/0**; live remote main SHA verified.
- Exact reviewed archive existed; archive Info.plist confirmed version **1.0.1**, build **4**, Bundle ID `com.naoki-ko.agendacue`.
- Reviewed local IPA SHA-256 matched before upload.
- Read-only App Store Connect precheck confirmed public **1.0 (3)**, highest uploaded build **3**, upload history containing only 1.0 builds 3/2/1, no unexpected Build 4, and no draft/in-review version. App Review listed only prior completed/deleted submissions.
- Public version selected **automatic release after approval**.

## Authoritative artifact mapping

- Reviewed Packaging Commit: `e35868b0612d707c476fa51f2e1272bd9797850e`.
- Observed WU-19 State Snapshot: `b210f0bbe6f751435fd307608081f272b81ad6ed`.
- WU-19 Review Sync / main baseline: `b6f8a506bf1feef4ecac685e9818b82de352bb5a`.
- Exact reviewed source archive: `AgendaCue-1.0.1-4-e35868b.xcarchive`.
- Reviewed local export: `CalendarAlarmFeasibility.ipa`.
- Reviewed local IPA SHA-256: `0e974c87797d0c2a1a694f9fd680ea71f0a72994e8f0be6240d0d84f1a808636`.
- Authoritative identity: **Packaging Commit → exact reviewed archive → processed App Store Connect 1.0.1 (4)**.

No rebuild, rearchive, version/build increment, Build 5, or production source/test/project configuration change occurred. The exact reviewed archive was selected in Xcode Organizer and verified as **1.0.1 (4)** with the correct Bundle ID.

Read-only comparison after upload confirmed that the exact reviewed source archive file contents and reviewed local IPA hash remained unchanged. Local filesystem paths and path-derived manifest identifiers are omitted from public evidence.

Organizer performed the explicitly permitted normal App Store distribution packaging/signing steps. The local exported IPA hash remains release evidence; it is **not** asserted to be the hash of the Organizer-generated upload package.

## Phases 1–2 — Upload and processing

- Organizer: **Distribute App → Custom → App Store Connect → Upload**. Custom options were used to explicitly disable **Manage version and build number**.
- **Upload your app's symbols** enabled; **TestFlight internal testing only** disabled.
- Manual signing was inspected but could not use the automatically managed profile/local signing identity. No manual certificate was created. Continuing with automatic signing resolved this using **Cloud Managed Apple Distribution** and the existing app's Store profile, without exposing account-specific signing identifiers.
- Pre-upload summary: version **1.0.1 (4)**, arm64, Bundle ID `com.naoki-ko.agendacue`, `get-task-allow=false`, `beta-reports-active=true`.
- Upload started at approximately **12:13 JST**; Organizer confirmed **CalendarAlarmFeasibility 1.0.1 (4) uploaded** by **12:15 JST**. Upload was performed once.
- App Store Connect upload history initially showed **1.0.1 (4) / 処理中**, created **2026-09-03 12:14**. No version was created while processing remained pending.
- On continuation, upload history showed **終了**; TestFlight showed **1.0.1 / Build 4 / 提出準備完了**.
- Actual metadata: binary **確認済み**, short version **1.0.1**, bundle version **4**, Bundle ID `com.naoki-ko.agendacue`, upload date **2026-09-03 12:21**, non-exempt encryption **いいえ**, symbols **はい**, arm64, minimum iOS **26.0**.
- No invalid-binary, export-compliance, duplicate-build, or unexpected-build-number warning was observed.

The upload-history creation time and processed metadata upload date are recorded as separate UI facts; upload-success UI alone was not used as processing evidence.

## Phases 3–6 — Version and metadata

- Created new iOS App Store version **1.0.1**; did not edit public 1.0.
- Build picker offered **4 / 1.0.1**; selected it. Saved version displayed **4 / 1.0.1 / no App Clip**, verified against the processed 1.0.1 (4) build.
- Existing localizations were **Japanese and English (US)** only. No new localization was added.
- Japanese and English What's New below were saved and read back.
- Review Notes below were saved and read back exactly, including line breaks and neutral CTA wording.
- Both localizations retained **six existing screenshots**. Description, keywords, support URL, marketing URL, and copyright matched public 1.0. The new version did not inherit promotional text automatically, so the existing public Japanese/English promotional text was carried forward unchanged.
- Existing support/privacy URL: `https://naoki-ko.github.io/agendacue-site/privacy/`; unchanged.
- Existing pricing/availability was inspected read-only: free pricing, 148 available / 27 unavailable territories at inspection. No changes made.
- Privacy declaration remained **データの収集なし**; age rating remained **4+** with existing regional exceptions. No privacy/age-rating edits or new legal/compliance answers.
- Release method remained **automatic after approval**; new version's all-users/no-phased-release default retained. Existing ratings preserved.
- Contact fields were not changed or invented. App Store Connect accepted Add/Submit for Review without a missing-field error.

### What's New — Japanese

```text
カレンダーへのフルアクセス許可後に、アクセスが必要という画面が表示されることがある問題を修正しました。
あわせて、権限変更後の状態反映を改善しました。
```

### What's New — English (US)

```text
Fixed an issue where the app could incorrectly show that Calendar access was required immediately after Full Access had been granted.
Permission-state updates after access changes are now handled more reliably.
```

### Review Notes

```text
AgendaCue is a local-only calendar alarm app.

This update fixes a Calendar permission-state synchronization issue that could cause the app to incorrectly show the Calendar access recovery screen immediately after the user granted Full Access.

The app now handles the successful native Calendar permission result and subsequent system authorization state consistently before completing onboarding.

The permission pre-prompt CTA remains neutral:
- English: "Continue"
- Japanese: "続ける"

Users independently choose whether to allow or deny access in the native iOS permission dialog.

No calendar data is uploaded or shared. The app has no account, backend, analytics, advertising, or tracking.
```

## Phases 7–9 — Actual submission

- **審査用に追加 / Add for Review: PASS**, draft created at **16:57 JST**.
- Final summary contained exactly one item: **iOSアプリ1.0.1 / 1.0.1 (4)** for AgendaCue. No additional platform/version/item.
- **審査へ提出 / Submit for Review: PASS**, explicitly authorized by the WU-20 request.
- Completion dialog: **1項目が提出されました**.
- Actual submission-detail page: **iOSでの送信 / 審査待ち**, one row **iOSアプリ1.0.1 / 1.0.1 (4) / アプリバージョン / 審査待ち**.
- Actual date: **2026-09-03 16:58 JST**.
- Public version detail still showed **1.0 / Build 3 / 配信準備完了** after submission.
- **1.0.1 (4) is submitted, not publicly released**. No approval date or future release date is asserted.

## Public evidence sanitization

This public evidence intentionally omits App Store Connect submission/internal build identifiers, account-specific opaque identifiers, authenticated deep links, and machine-specific archive/IPA paths. Generalized artifact filenames, the reviewed Packaging Commit, and the approved local IPA SHA-256 retain release identity. No session/cookie/token/auth data, Apple credentials, secrets, or private contact/calendar data are included. The owner authorized replacing the unpublished evidence commit before its first push; this is not a follow-up deletion commit.

## Git evidence and stop

This is one docs-only submission evidence change on `wu-20-hotfix-app-review-submission`, based on unchanged main `b6f8a506bf1feef4ecac685e9818b82de352bb5a`. No source/tests/project settings or binary artifacts are committed. Raw account/session data, private keys, contact information, and calendar titles/content are excluded.

Normal branch push, verify local/remote equality, ahead/behind 0/0, and clean working tree; then **STOP for ChatGPT final submission-state review**. No main merge, force push, squash, or rebase. Apple review/approval/release is outside this completed submission workflow.
