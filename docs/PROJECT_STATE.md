# Project State

## Current state

- Current Work Unit: **WU-20 — Hotfix Upload / App Review Submission**.
- Status: **PASS / REVIEWED / SUBMISSION COMPLETE**.
- WU branch: `wu-20-hotfix-app-review-submission`; owner-authorized closure into `main` is fast-forward-only.
- WU-20 baseline main: `b6f8a506bf1feef4ecac685e9818b82de352bb5a`.
- Reviewed Evidence Commit: `691403c5613d6d47f30363d4043c92b290736834`.
- ChatGPT final submission-state review: **PASS**; exact receipt in `docs/REVIEW_LOG.md`.
- Submission workflow: **COMPLETE**. Apple review: **PENDING**. Public release 1.0.1: **NOT YET COMPLETE**.
- Current public release: **PUBLICLY RELEASED — 1.0 (3)**.
- Candidate: **1.0.1 (4) — SUBMITTED / NOT YET PUBLICLY RELEASED**.
- External state: **WAITING FOR REVIEW / 審査待ち**, as confirmed in the owner's final review receipt; no new App Store Connect inspection or mutation during this docs-only Review Sync.
- Submission date: **2026-09-03 16:58 JST**.
- Upload, processing, version creation, Build 4 selection, metadata, Review Notes, Add/Submit for Review, and post-submit verification: **PASS**.
- Release method: **automatic after approval**, all users, no phased release; existing intended automatic policy preserved.
- Warnings / unresolved submission blockers: **none observed**. Apple review/approval/release is pending.
- Evidence: `docs/evidence/WU-20/HOTFIX_APP_REVIEW_SUBMISSION.md`.

## Reviewed release identity

- WU-19: **CLOSED / PASS / REVIEWED**.
- Reviewed Packaging Commit: `e35868b0612d707c476fa51f2e1272bd9797850e`.
- Observed WU-19 State Snapshot: `b210f0bbe6f751435fd307608081f272b81ad6ed`.
- WU-19 Review Sync / baseline main: `b6f8a506bf1feef4ecac685e9818b82de352bb5a`.
- Exact reviewed archive: `AgendaCue-1.0.1-4-e35868b.xcarchive`.
- Authoritative identity: Packaging Commit → this exact reviewed archive → App Store Connect **1.0.1 (4)**.
- Processed binary: **確認済み**, non-exempt encryption **いいえ**, Bundle ID `com.naoki-ko.agendacue`.
- Reviewed local export: `CalendarAlarmFeasibility.ipa`.
- Reviewed IPA SHA-256: `0e974c87797d0c2a1a694f9fd680ea71f0a72994e8f0be6240d0d84f1a808636` (unchanged local evidence, not a claimed hash of the Organizer upload package).
- No rebuild, rearchive, version/build increment, Build 5, production source/test/project-setting change. Organizer performed permitted distribution packaging/signing from the exact reviewed archive with version/build management disabled.

## Prior gates and scope

- WU-18: **CLOSED / PASS / REVIEWED**, Implementation `31d4cf71060e1e6e05acba6b1d2d576966046f22`, State Snapshot `9ec89202408dd153c8eff398933f33f97efd24aa`.
- Physical WU-18 Gate: **previously PASS on exact reviewed implementation lineage**. WU-19/WU-20 claim no new physical run.
- WU-19 XCTest: **182 passed / 0 failed / 0 skipped**; four builds, signed archive, local distribution export, signing/privacy/identity/CTA audits **PASS**. No new build/test run in WU-20.
- WU-19 App Store Connect access was read-only. WU-20 separately authorized upload, version metadata, and final submission.
- Japanese/English What's New and Review Notes match owner-provided text. Existing screenshots, descriptions, keywords, URLs, pricing/availability, privacy declarations, and age rating were preserved.

## Stop line

Owner-authorized closure: one docs-only Review Sync commit, normal WU-20 branch push, fast-forward-only merge into main, and normal main push. Verify local/remote equality, evidence/review-sync reachability, ahead/behind 0/0, and clean working tree. No merge commit, squash, rebase, or force push.

After main closure, **STOP — wait for Apple App Review**. Do not cancel the submission, replace Build 4, create Build 5, rebuild/rearchive, change version/build or 1.0.1 metadata, or manually release. Do not claim 1.0.1 is public.
