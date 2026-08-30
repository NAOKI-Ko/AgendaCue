# Project State

## Current state

- Current Phase: **App Review Correction / WU-16 Closed**
- Completed Work Unit: **WU-16 — App Review 5.1.1(iv) Permission CTA Correction**
- Status: **PASS / REVIEWED**
- Next Work Unit: **WU-17 — AgendaCue 1.0 (3) Release Candidate / App Review Resubmission — NOT STARTED**
- Branch: `wu-16-permission-cta-correction`
- Branch Baseline: `3b06f919889cbc8e56c4f71b0208aa5e0dfa23b7`
- Production Source Baseline Lineage: `d6423938dedb17df3aaa0f925c30636efc61f948`
- App Store Version/Build: **1.0 (2)**
- Repository: `https://github.com/NAOKI-Ko/AgendaCue` — **PUBLIC**
- Public Release: **NOT COMPLETED**

## App Review state

- 2026-08-29: Apple rejected Build 2 under Guideline 5.1.1(iv), submission `1fad3077-c612-45aa-9f65-bc99102a671b`, because the Calendar and AlarmKit custom pre-permission CTAs directly encouraged permission grant.
- 2026-08-30: the owner accidentally Developer-Cancelled the rejected submission in App Store Connect. This does not erase or replace the rejection history and does not change WU-16 scope.
- WU-16 correction: Calendar and Alarm custom pre-permission CTAs become English `Continue` and Japanese `続ける`.
- Next release action: after WU-16 ChatGPT Implementation Review PASS only, create Build 3 and resubmit in separate **WU-17**.

## WU-16 scope contract

- Change only the two localized custom pre-permission CTA values and the focused existing localization expectations.
- Preserve the custom explanation → neutral CTA → native system request flow.
- Preserve EventKit/AlarmKit request timing, authorization refresh, denial handling, and Settings recovery.
- No EventKit fetch/reconciliation, AlarmKit scheduling/identity/cleanup, calendar selection, timeline, event detail, persistence, architecture, dependency, version/build, signing, archive, upload, or submission change.

## Review target

- Latest Reviewed Implementation Commit: `c06b4c38b0ece0e2010b8505c9bcfee86b232fc1`
- WU-16 State Snapshot: `5cce155a4c79e6a2e354b7a3db5321e776436cd3`
- Review Date: **2026-08-31**
- Reviewer: **ChatGPT**
- Decision: **PASS**
- Review Sync Commit: **reported after commit creation because a commit cannot contain its own SHA**

## Verification

- Build: **PASS — Debug/Release Simulator and unsigned Device**
- Complete XCTest: **PASS — 174 passed, 0 failed, 0 skipped**
- Functional request/recovery path inspection: **PASS — unchanged CTA action/provider/recovery wiring; complete tests green**
- Japanese/English Calendar/Alarm Visual QA: **PASS — four inspected iPhone 17 Pro Simulator captures under `docs/evidence/WU-16/ui/`**
- Physical device/system authorization behavior: **DEVICE_VERIFICATION_DEFERRED — must not be inferred from Simulator**

## Next action

Close WU-16 by pushing its docs-only Review Sync Commit and fast-forwarding it to `main`. Then stop. WU-17 is the next Work Unit and remains **NOT STARTED**.

## Historical unresolved items

- No WU-14 commit or document was found during WU-16A continuity recovery.
- Exact historical Review Receipts for WU-11 through WU-15 remain unavailable in Git.
