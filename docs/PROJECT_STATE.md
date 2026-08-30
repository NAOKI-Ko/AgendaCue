# Project State

## Current state

- Current Work Unit: **WU-17 Phase A — AgendaCue 1.0 (3) Release Candidate Packaging**
- Status: **RELEASE CANDIDATE REVIEW PENDING**
- Branch: `wu-17-build3-release-candidate`
- Branch Baseline / current unchanged `main`: `ac138b1b6f7260f0841c5c81e5c66d4213511e8c`
- WU-16 Reviewed Implementation: `c06b4c38b0ece0e2010b8505c9bcfee86b232fc1`
- Production Source Baseline Lineage: `d6423938dedb17df3aaa0f925c30636efc61f948`
- Build 3 Source SHA: `620296af562afd37eda7a59263371c51cd64b046`
- State Snapshot Commit: **reported after creation because a commit cannot contain its own SHA**
- App Store Version: **1.0**
- Build: **3**
- Upload: **NOT STARTED**
- App Review Resubmission: **NOT STARTED**
- Repository: `https://github.com/NAOKI-Ko/AgendaCue` — **PUBLIC**
- Public Release: **NOT COMPLETED**

## Phase A scope and binary contract

- The only production configuration change is `CURRENT_PROJECT_VERSION = 2` → `3` for Debug and Release.
- The corresponding existing configuration regression test name and expected build value were updated to Build 3.
- Swift production source, permission CTA copy, EventKit, AlarmKit, request timing, reconciliation, scheduling, persistence, UI, identity, entitlements, assets, dependencies, version, and metadata are unchanged.
- Formal archive and IPA were generated while `HEAD == 620296af562afd37eda7a59263371c51cd64b046` and the working tree was clean.
- The binary maps to the Packaging Commit above, not the later docs-only State Snapshot.

## Verification

- Complete XCTest: **PASS — 174 passed, 0 failed, 0 skipped**.
- Release Simulator build: **PASS**.
- Unsigned generic Device Release build: **PASS**.
- Signed Release archive: **PASS**.
- App Store distribution export: **PASS**.
- Strict exported-app codesign verification: **PASS**.
- Release Simulator launch smoke: **PASS**.
- Package identity/configuration/resources/privacy audit: **PASS**.
- Packaged CTA: Calendar and Alarm are `Continue` / `続ける`; old CTA matches are 0.
- Physical Device Gate: **DEVICE_VERIFICATION_DEFERRED / NOT PASS**.
- H01–H46: **PENDING / NOT PASS**.

## App Review state

- 2026-08-29: Apple rejected Build 2 under Guideline 5.1.1(iv), submission `1fad3077-c612-45aa-9f65-bc99102a671b`.
- 2026-08-30: the owner accidentally Developer-Cancelled the rejected submission. Both facts remain preserved.
- WU-16 correction received ChatGPT Implementation Review PASS.
- WU-17 Phase A has not received Release Candidate Review yet.
- App Store Connect was not touched; Build 3 upload, selection, Add for Review, and submission were not started.

## Next action

**ChatGPT Release Candidate Review** of exact Build 3 Source SHA `620296af562afd37eda7a59263371c51cd64b046`, its build-number-only diff, archive/export evidence, distribution identity, IPA hash, and binary-to-Git mapping. WU-17 Phase B is not started.

## Historical unresolved items

- No WU-14 commit or document was found during WU-16A continuity recovery.
- Exact historical Review Receipts for WU-11 through WU-15 remain unavailable in Git.

## Required Phase A state

- Current Work Unit: **WU-17 Phase A — AgendaCue 1.0 (3) Release Candidate Packaging**
- Status: **RELEASE CANDIDATE REVIEW PENDING**
- Build 3 Source SHA: `620296af562afd37eda7a59263371c51cd64b046`
- State Snapshot Commit: **reported after creation**
- App Store Version: **1.0**
- Build: **3**
- Upload: **NOT STARTED**
- App Review Resubmission: **NOT STARTED**
- Physical Device Gate: **DEVICE_VERIFICATION_DEFERRED / NOT PASS**
- Next Action: **ChatGPT Release Candidate Review**
