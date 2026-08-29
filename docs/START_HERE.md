# Start Here

AgendaCue is a local-only iOS 26+ SwiftUI app that reads selected device calendars through EventKit and schedules prominent alarms through AlarmKit. It does not write calendar data and has no account, backend, analytics, advertising, or in-app purchases.

## Current release state

- Production baseline: `d6423938dedb17df3aaa0f925c30636efc61f948` (`WU-15 localize AgendaCue and package build 2`)
- App Store version/build: **1.0 (2)**
- Production implementation: **complete and frozen at the baseline above**
- App Review submission: **completed**
- App Review result: **Rejected on 2026-08-29**
- Submission ID: `1fad3077-c612-45aa-9f65-bc99102a671b`
- Guideline: **5.1.1(iv) — Legal — Privacy — Data Collection and Storage**
- Public release: **not completed**

Apple identified the Calendar and AlarmKit custom pre-permission CTA wording as directly encouraging permission grant. The future correction is `Continue` in English and `続ける` in Japanese. WU-16A must not make that production change.

## Current work

- Current Work Unit: **WU-16A — Continuity Recovery / Git State Sync**
- Phase: **App Review Correction / Continuity Recovery**
- Scope: Git documentation, portable AI memory, and repository bootstrap only
- Production source: **frozen at `d6423938dedb17df3aaa0f925c30636efc61f948`**
- Next action: **ChatGPT State Review of the exact WU-16A recovery target**
- After review PASS only: start **WU-16 — App Review 5.1.1(iv) Permission CTA Correction** as a separate Work Unit

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
9. `CODEX_REPORT.md` — current WU-16A execution report.

## Stop line

Stop after the WU-16A recovery branch is pushed for ChatGPT State Review. Do not change permission CTA/localization, create Build 3, archive, upload, resubmit, merge to `main`, or begin WU-16.
