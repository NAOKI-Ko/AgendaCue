# Start Here

AgendaCue is a local-only iOS 26+ SwiftUI app that reads selected device calendars through EventKit and schedules alarms through AlarmKit. It does not write calendar data and has no account, backend, analytics, advertising, or in-app purchases.

## Current release state

- Active WU: **WU-20 — Hotfix Upload / App Review Submission**.
- WU branch: `wu-20-hotfix-app-review-submission`; baseline main: `b6f8a506bf1feef4ecac685e9818b82de352bb5a`. Owner-authorized main closure is fast-forward-only.
- WU-20: **PASS / REVIEWED / SUBMISSION COMPLETE**.
- Reviewed Evidence Commit: `691403c5613d6d47f30363d4043c92b290736834`.
- Current public release: **1.0 (3) — PUBLICLY RELEASED**.
- Candidate: **1.0.1 (4) — SUBMITTED / NOT YET PUBLICLY RELEASED**.
- App Store Connect: **審査待ち / Waiting for Review**, submitted **2026-09-03 16:58 JST**.
- Release method: **automatic after approval**, all users, no phased release.
- Upload/processing, 1.0.1 creation, Build 4 selection, Japanese/English What's New, Review Notes, Add/Submit for Review, and post-submit verification: **PASS**.
- Warnings / unresolved submission blockers: **none observed**; Apple review and release remain pending.
- WU-20 ChatGPT final submission-state review: **PASS**, exact receipt in `REVIEW_LOG.md`.
- Submission workflow: **COMPLETE**; Apple review: **PENDING**; public release 1.0.1: **NOT YET COMPLETE**.
- External state above is confirmed by the owner's final review receipt, not a new App Store Connect inspection during this docs-only Review Sync.

## Exact artifact contract

- WU-19: **CLOSED / PASS / REVIEWED**.
- Reviewed Packaging Commit: `e35868b0612d707c476fa51f2e1272bd9797850e`.
- Observed State Snapshot: `b210f0bbe6f751435fd307608081f272b81ad6ed`.
- Exact archive: `AgendaCue-1.0.1-4-e35868b.xcarchive`.
- Packaging Commit → exact reviewed archive → processed App Store Connect **1.0.1 (4)**.
- No rebuild/rearchive or version/build changes. Reviewed local IPA remains unchanged; its hash is local release evidence, not an assertion of byte identity with Organizer's upload package.
- WU-19 automated gates passed (182/0/0 XCTest, four builds, archive/export/audits). WU-18 Physical Device Gate was previously PASS on reviewed lineage. WU-20 claims no new test/build/device run.

## Reading order

1. `../AGENTS.md`
2. `PROJECT_STATE.md`
3. `evidence/WU-20/HOTFIX_APP_REVIEW_SUBMISSION.md`
4. `CODEX_REPORT.md`
5. `REVIEW_LOG.md`
6. `evidence/WU-19/PUBLIC_HOTFIX_RELEASE_CANDIDATE.md` (historical packaging evidence)
7. `evidence/WU-18/PHYSICAL_PERMISSION_RECOVERY.md`

## Stop line

Push one docs-only Review Sync commit to the WU-20 branch normally, then fast-forward-only merge into main and push main normally. Verify equality / ahead-behind 0/0 / clean working tree and evidence/review-sync reachability. No merge commit, squash, rebase, or force push.

After closure, **STOP — wait for Apple App Review**. Do not cancel the submission, replace Build 4, create Build 5, rebuild/rearchive, modify 1.0.1 metadata, or manually release. Candidate 1.0.1 (4) remains submitted, not publicly released.
