# Start Here

AgendaCue is a local-only iOS 26+ SwiftUI app that reads selected device calendars through EventKit and schedules alarms through AlarmKit. It does not write calendar data and has no account, backend, analytics, advertising, or in-app purchases.

## Current release state

- Current WU: **WU-19 — Public Hotfix Release Packaging — PASS / REVIEWED**.
- Branch: `wu-19-public-hotfix-release`.
- Baseline main before WU-19 closure: `ad25b3ea513c481bb27b7345cb272c183395d104`.
- Current app: **PUBLICLY RELEASED — 1.0 (3)**, read-only App Store Connect verification 2026-09-03.
- Highest uploaded build: **3**; no draft/in-review app version observed.
- Candidate: **1.0.1 (4) — NOT YET RELEASED**.
- Reviewed Packaging Commit: `e35868b0612d707c476fa51f2e1272bd9797850e`.
- Observed State Snapshot: `b210f0bbe6f751435fd307608081f272b81ad6ed`.
- WU-18 reviewed implementation: `31d4cf71060e1e6e05acba6b1d2d576966046f22`.
- WU-18 reviewed snapshot: `9ec89202408dd153c8eff398933f33f97efd24aa`.
- WU-18 is **CLOSED / PASS / REVIEWED**. WU-19 production functional delta is **0**.

## Gates

- Full XCTest: **182 passed / 0 failed / 0 skipped**.
- Debug/Release Simulator and unsigned Debug/Release Device builds: **PASS**.
- Fresh signed Release archive and local App Store IPA export: **PASS**.
- Package/signing/privacy/CTA/source identity audit: **PASS**.
- Physical WU-18 Gate: **previously PASS on exact reviewed implementation lineage**; no new physical test result is claimed.
- WU-19 ChatGPT Release Candidate Review: **PASS**; exact receipt in `REVIEW_LOG.md`.
- App Store Connect: **READ ONLY / NOT MUTATED**.
- Upload / submission: **NOT STARTED**.

## Reading order

1. `../AGENTS.md`
2. `PROJECT_STATE.md`
3. `evidence/WU-19/PUBLIC_HOTFIX_RELEASE_CANDIDATE.md`
4. `CODEX_REPORT.md`
5. `QA_CHECKLIST.md`
6. `REVIEW_LOG.md`
7. `evidence/WU-18/PHYSICAL_PERMISSION_RECOVERY.md`

## Stop line

The owner authorized docs-only Review Sync, normal WU-19 branch push, then fast-forward-only main merge and normal main push, with clean working tree and local/remote equality (ahead/behind 0/0). No merge commit, squash, rebase, or force push.

After main closure, **STOP**. Next phase: separate hotfix upload/submission. App Store Connect remained read-only during WU-19 packaging; upload/submission are **NOT STARTED**. No upload, App Store version mutation, build selection, Review Notes edit, Add/Submit for Review, or release.

Build 4 remains bound to Packaging Commit `e35868b0612d707c476fa51f2e1272bd9797850e` and the exact reviewed archive `/private/tmp/AgendaCue-WU19-uyonHi/AgendaCue-1.0.1-4-e35868b.xcarchive`. Do not recreate/rebuild the archive, modify the reviewed IPA, or change version/build. Current public release is **1.0 (3)**; candidate **1.0.1 (4) is NOT YET RELEASED**.
