# Start Here

AgendaCue is a local-only iOS 26+ SwiftUI app that reads selected device calendars through EventKit and schedules prominent alarms through AlarmKit. It does not write calendar data and has no account, backend, analytics, advertising, or in-app purchases.

## Current release state

- Production source lineage: `d6423938dedb17df3aaa0f925c30636efc61f948` (`WU-15 localize AgendaCue and package build 2`).
- WU-16 reviewed implementation: `c06b4c38b0ece0e2010b8505c9bcfee86b232fc1`.
- WU-16 closure / WU-17 branch baseline: `ac138b1b6f7260f0841c5c81e5c66d4213511e8c`.
- Build 3 source / Packaging Commit: `620296af562afd37eda7a59263371c51cd64b046`.
- App Store version/build release candidate: **1.0 (3)**.
- WU-17 Phase A status: **CHATGPT RELEASE CANDIDATE REVIEW PASS — CLOSURE SYNC**.
- Build 3 upload and App Review resubmission: **NOT STARTED**.
- Public release: **not completed**.

## App Review history

- 2026-08-29: Apple rejected Build 2 under Guideline 5.1.1(iv), submission `1fad3077-c612-45aa-9f65-bc99102a671b`.
- 2026-08-30: the owner accidentally Developer-Cancelled the rejected submission. This does not erase the rejection history.
- WU-16 corrected the Calendar and AlarmKit custom pre-permission CTA to `Continue` in English and `続ける` in Japanese and received ChatGPT Implementation Review PASS.

## Current work

- Current Work Unit: **WU-17 Phase A — AgendaCue 1.0 (3) Release Candidate Packaging Closure**.
- Branch: `wu-17-build3-release-candidate`.
- Scope: build number `2` → `3`, complete regression/build gates, fresh archive/export, package audit, and evidence only.
- Functional production source delta: **0**.
- Formal archive and IPA were generated from clean exact Packaging Commit `620296af562afd37eda7a59263371c51cd64b046`.
- Physical-device Calendar/AlarmKit authorization and H01–H46: **DEVICE_VERIFICATION_DEFERRED / NOT PASS**.
- ChatGPT Release Candidate Review: **PASS** on 2026-08-31 for Build 3 Source SHA `620296af562afd37eda7a59263371c51cd64b046`, with State Snapshot `99d46761df112a8f965746dbc7b5c37c9e59b944` observed.
- Next action: fast-forward Phase A to `main`, then create `wu-17-app-review-resubmission` from the updated `main` for authorized Build 3 upload and App Review resubmission.

## Historical continuity gap

The former portable AI memory stopped at WU-10 even though Git history continued through WU-15. WU-11, WU-12, WU-13, and WU-15 artifacts were recovered from Git history. No WU-14 commit or document was found. Exact historical ChatGPT Review Receipts for WU-11 through WU-15 remain unavailable and must not be inferred.

## Reading order

1. `../AGENTS.md` — operating rules and gates.
2. `PROJECT_STATE.md` — authoritative current state and next action.
3. `PRODUCT_SPEC.md` — Production V1 promise, scope, and exclusions.
4. `DOMAIN_RULES.md` — deterministic calendar-to-alarm rules.
5. `ARCHITECTURE.md` — intended boundaries.
6. `IMPLEMENTATION_PLAN.md` — Work Unit sequence and gates.
7. `QA_CHECKLIST.md` — reusable verification inventory.
8. `REVIEW_LOG.md` — append-only SHA-bound review and recovery record.
9. `CODEX_REPORT.md` — WU-17 Phase A packaging and verification report.
10. `evidence/WU-17/RELEASE_CANDIDATE_PACKAGE.md` — archive/export/package evidence.

## Stop line

The exact-SHA ChatGPT Release Candidate Review gate is **PASS**. The owner has separately authorized a fast-forward-only Phase A closure and continuous WU-17 Phase B execution subject to the recorded integrity, authentication, upload, processing, App Store state, metadata, build-selection, and target-identity stop conditions. Physical-device verification remains **DEVICE_VERIFICATION_DEFERRED — NOT PASS** and public release remains incomplete.
