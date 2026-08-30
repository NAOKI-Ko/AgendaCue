# Start Here

AgendaCue is a local-only iOS 26+ SwiftUI app that reads selected device calendars through EventKit and schedules prominent alarms through AlarmKit. It does not write calendar data and has no account, backend, analytics, advertising, or in-app purchases.

## Current release state

- Production baseline: `d6423938dedb17df3aaa0f925c30636efc61f948` (`WU-15 localize AgendaCue and package build 2`)
- App Store version/build: **1.0 (2)**
- Production implementation: **complete and frozen at the baseline above**
- App Review submission: **completed**
- App Review result: **Rejected on 2026-08-29**
- App Store Connect state: **owner accidentally Developer-Cancelled the rejected submission on 2026-08-30**
- Submission ID: `1fad3077-c612-45aa-9f65-bc99102a671b`
- Guideline: **5.1.1(iv) — Legal — Privacy — Data Collection and Storage**
- Public release: **not completed**

Apple identified the Calendar and AlarmKit custom pre-permission CTA wording as directly encouraging permission grant. The WU-16 correction is `Continue` in English and `続ける` in Japanese. The rejection remains part of the review history even though the owner later Developer-Cancelled the submission.

## Current work

- Completed Work Unit: **WU-16 — App Review 5.1.1(iv) Permission CTA Correction — ChatGPT Implementation Review PASS**
- Branch baseline: `3b06f919889cbc8e56c4f71b0208aa5e0dfa23b7`
- Production source lineage: `d6423938dedb17df3aaa0f925c30636efc61f948`
- Current repository: `https://github.com/NAOKI-Ko/AgendaCue` — **PUBLIC** after an owner visibility change made after the reviewed WU-16A snapshot; WU-16A originally bootstrapped it as PRIVATE.
- Scope: neutralize only the Calendar and AlarmKit custom pre-permission CTA wording while preserving request timing, permission flow, and denied recovery.
- Status: **PASS / REVIEWED**
- Latest Reviewed Implementation Commit: `c06b4c38b0ece0e2010b8505c9bcfee86b232fc1`
- Reviewed State Snapshot: `5cce155a4c79e6a2e354b7a3db5321e776436cd3`
- Next Work Unit: **WU-17 — AgendaCue 1.0 (3) Release Candidate / App Review Resubmission — NOT STARTED**

## Historical continuity gap

The former portable AI memory stopped at WU-10 even though Git history continued through the WU-15 production baseline. WU-11, WU-12, WU-13, and WU-15 artifacts can be recovered from Git history. No WU-14 commit or document was found. Exact historical ChatGPT Review Receipts for WU-11 through WU-15 are unavailable in Git, so this recovery does not infer or recreate any historical Review Gate PASS.

## Reading order

1. `../AGENTS.md` — operating rules and gates.
2. `PROJECT_STATE.md` — authoritative current state and next action.
3. `PRODUCT_SPEC.md` — Production V1 promise, scope, and exclusions.
4. `DOMAIN_RULES.md` — deterministic calendar-to-alarm rules.
5. `ARCHITECTURE.md` — intended boundaries.
6. `IMPLEMENTATION_PLAN.md` — Work Unit sequence and gates.
7. `QA_CHECKLIST.md` — reusable verification inventory.
8. `REVIEW_LOG.md` — append-only SHA-bound review and recovery record.
9. `CODEX_REPORT.md` — WU-16 implementation, verification, and review receipt.

## Stop line

WU-16 is closed after its Review Sync Commit is fast-forwarded and pushed to `main`. Do not begin WU-17, change version/build, create Build 3, archive, export, upload, modify App Store Connect, or resubmit during this closure step.
