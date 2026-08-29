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

- Completed Work Unit: **WU-16A — Continuity Recovery / Git State Sync — ChatGPT State Review PASS**
- Review target: `623af3fc3a37fcb8a9a217dfc5c41f22d1fed463`
- Reviewed State Snapshot: `ff10b057ced4ff1343bdb0810f2cb679b2292724`
- Current repository: `https://github.com/NAOKI-Ko/AgendaCue` — **PUBLIC** after an owner visibility change made after the reviewed WU-16A snapshot; WU-16A originally bootstrapped it as PRIVATE.
- Production source: **frozen at `d6423938dedb17df3aaa0f925c30636efc61f948`**
- Next Work Unit: **WU-16 — App Review 5.1.1(iv) Permission CTA Correction**
- Correction status: **not implemented**

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

WU-16A is closed after its exact Review Receipt is synchronized and fast-forwarded to `main`. Start WU-16 only as a separate Work Unit. Do not change permission CTA/localization, create Build 3, archive, upload, or resubmit during this closure step.
