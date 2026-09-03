# Project State

## Current state

- Current Work Unit: **WU-19 — Public Hotfix Release Packaging**
- Status: **PASS / REVIEWED — RELEASE CANDIDATE REVIEW PASS**
- Branch: `wu-19-public-hotfix-release`
- Baseline main before WU-19 closure: `ad25b3ea513c481bb27b7345cb272c183395d104`
- Current app: **PUBLICLY RELEASED — 1.0 (3)**, verified read-only in App Store Connect on 2026-09-03.
- Highest uploaded build: **3**; no draft or in-review app version observed.
- Candidate: **1.0.1 (4) — NOT YET RELEASED**
- Reviewed Packaging Commit: `e35868b0612d707c476fa51f2e1272bd9797850e`
- Observed State Snapshot: `b210f0bbe6f751435fd307608081f272b81ad6ed`
- Review Sync: this docs-only commit; exact ChatGPT receipt recorded in `docs/REVIEW_LOG.md`.
- App Store Connect: **READ ONLY / NOT MUTATED**
- Upload / submission: **NOT STARTED**

## Reviewed implementation lineage

- WU-18: **CLOSED / PASS / REVIEWED**
- Reviewed Implementation: `31d4cf71060e1e6e05acba6b1d2d576966046f22`
- Reviewed State Snapshot: `9ec89202408dd153c8eff398933f33f97efd24aa`
- WU-18 Review Sync / baseline main: `ad25b3ea513c481bb27b7345cb272c183395d104`
- Production source tree is byte-identical across the reviewed implementation, baseline main, and WU-19 Packaging Commit.
- Functional production delta: **0**. Only Debug/Release version/build settings and focused version/build test expectations changed.
- Physical WU-18 Gate: **previously PASS on the exact reviewed implementation lineage**. No new PD-01..PD-06 run is claimed in WU-19.

## Verification and artifacts

- Complete XCTest: **182 passed / 0 failed / 0 skipped**.
- Debug Simulator, Release Simulator, unsigned Device Debug, unsigned Device Release: **PASS**.
- Fresh signed Release archive from clean Packaging Commit: **PASS**.
- Local App Store distribution export and strict archive/IPA codesign: **PASS**.
- Exact reviewed archive: `/private/tmp/AgendaCue-WU19-uyonHi/AgendaCue-1.0.1-4-e35868b.xcarchive`.
- Release identity: Packaging Commit `e35868b0612d707c476fa51f2e1272bd9797850e` → this exact reviewed archive → future App Store Connect Build 4. Review Sync does not recreate the archive or modify the IPA.
- IPA: `/private/tmp/AgendaCue-WU19-uyonHi/Export/CalendarAlarmFeasibility.ipa`
- IPA SHA-256: `0e974c87797d0c2a1a694f9fd680ea71f0a72994e8f0be6240d0d84f1a808636`
- Distribution identity, Team, Bundle ID, 1.0.1 (4), get-task-allow=false, encryption=false, privacy manifest, and Continue / 続ける CTA: **PASS**.
- Exact evidence and archive mapping: `docs/evidence/WU-19/PUBLIC_HOTFIX_RELEASE_CANDIDATE.md`.

## Stop line

The owner accepted the exact-SHA ChatGPT Release Candidate Review as **PASS**. Closure is this docs-only Review Sync, normal WU-19 branch push, then fast-forward-only merge into `main` and normal main push. Verify equality, 0/0 ahead/behind, clean working tree, and reachability of Packaging, State Snapshot, and Review Sync commits. No merge commit, squash, rebase, or force push.

After main closure, **STOP**. The next phase is separate hotfix upload/submission, not authorized by this closure. App Store Connect remained read-only during WU-19 packaging; upload/submission remain **NOT STARTED**. Do not rebuild/recreate the archive, modify the IPA, change version/build, upload, create version 1.0.1, select Build 4, edit Review Notes, Add/Submit for Review, or release.
