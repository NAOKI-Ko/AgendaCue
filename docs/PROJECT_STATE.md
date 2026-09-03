# Project State

## Current state

- Current Work Unit: **WU-19 — Public Hotfix Release Packaging**
- Status: **RELEASE CANDIDATE PACKAGE PASS — CHATGPT REVIEW PENDING**
- Branch: `wu-19-public-hotfix-release`
- Baseline / unchanged main: `ad25b3ea513c481bb27b7345cb272c183395d104`
- Current app: **PUBLICLY RELEASED — 1.0 (3)**, verified read-only in App Store Connect on 2026-09-03.
- Highest uploaded build: **3**; no draft or in-review app version observed.
- Candidate: **1.0.1 (4) — NOT YET RELEASED**
- Packaging Commit: `e35868b0612d707c476fa51f2e1272bd9797850e`
- State Snapshot: this docs-only commit
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
- IPA: `/private/tmp/AgendaCue-WU19-uyonHi/Export/CalendarAlarmFeasibility.ipa`
- IPA SHA-256: `0e974c87797d0c2a1a694f9fd680ea71f0a72994e8f0be6240d0d84f1a808636`
- Distribution identity, Team, Bundle ID, 1.0.1 (4), get-task-allow=false, encryption=false, privacy manifest, and Continue / 続ける CTA: **PASS**.
- Exact evidence and archive mapping: `docs/evidence/WU-19/PUBLIC_HOTFIX_RELEASE_CANDIDATE.md`.

## Stop line

Push the WU-19 branch, verify exact local/remote equality and 0/0 ahead/behind, then **STOP for ChatGPT Release Candidate Review**. Do not merge main, upload, create/edit an App Store version, select a build, edit Review Notes, add/submit for review, or release.
