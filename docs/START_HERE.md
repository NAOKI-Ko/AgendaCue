# Start Here

AgendaCue is a local-only iOS 26+ SwiftUI app that reads selected device calendars through EventKit and schedules alarms through AlarmKit. It does not write calendar data and has no account, backend, analytics, advertising, or in-app purchases.

## Current release state

- Active WU: **WU-20 — Hotfix Upload / App Review Submission**.
- Branch: `wu-20-hotfix-app-review-submission`; unchanged main: `b6f8a506bf1feef4ecac685e9818b82de352bb5a`.
- Current public release: **1.0 (3) — PUBLICLY RELEASED**.
- Candidate: **1.0.1 (4) — SUBMITTED / NOT YET PUBLICLY RELEASED**.
- App Store Connect: **審査待ち / Waiting for Review**, submitted **2026-09-03 16:58 JST**.
- Release method: **automatic after approval**, all users, no phased release.
- Upload/processing, 1.0.1 creation, Build 4 selection, Japanese/English What's New, Review Notes, Add/Submit for Review, and post-submit verification: **PASS**.
- Warnings / unresolved submission blockers: **none observed**; Apple review and release remain pending.
- WU-20 ChatGPT final submission-state review: **PENDING**.

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

Push one docs-only evidence commit to the WU-20 branch normally, verify equality / ahead-behind 0/0 / clean working tree, and **STOP for ChatGPT final submission-state review**. Do not merge main, rebuild/rearchive, increment build, cancel/replace the submission, or manually release. Candidate 1.0.1 (4) is submitted, not publicly released.
