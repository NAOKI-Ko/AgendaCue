# Project State

- Phase: **WU-10 Release Gate — Phase A.2**
- Current Work: **Production Identity Integration + Signing / Archive Readiness**
- Status: **AUTOMATED IDENTITY GATE PASS / ARCHIVE BLOCKED BY LOCAL SIGNING**
- Automated Gate: **PASS**
- Human Gate: **PENDING — REQUIRED / CANNOT BE WAIVED**
- Submission: **NOT STARTED**
- Main Merge: **NOT STARTED**
- Phase B: **NOT STARTED**
- Production Brand: **AgendaCue — OWNER APPROVED / INTEGRATED**
- Customer Display Name: **AgendaCue**
- Production Bundle ID: **`com.naoki-ko.agendacue` — OWNER APPROVED / INTEGRATED**
- Production BGTask ID: **`com.naoki-ko.agendacue.refresh` — OWNER APPROVED / INTEGRATED**

## Automated evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iOS 26.5 Simulators.

- XCTest: 160 tests passed, 0 failures.
- Specific iPhone 17 Pro Simulator build: succeeded.
- Generic iOS Simulator build: succeeded.
- Generic iOS Device Debug and Release builds with code signing disabled: succeeded.
- Generic iOS Simulator Debug and Release builds: succeeded.
- Production Release app Simulator launch smoke without sample arguments: passed.
- Clean Debug/Release compiler audit: zero warnings after the narrow Sendable fix.
- WU-10 release evidence is indexed in `docs/evidence/WU-10/README.md`.
- Phase A.1 naming evidence is indexed in `docs/evidence/WU-10/PHASE_A_1_NAMING.md`.
- Phase A.1 verification: 160/160 tests; required specific Debug and generic Release Simulator/unsigned Device builds; Release launch; built and installed `CFBundleDisplayName = AgendaCue`.
- Phase A.2 verification: 160/160 tests; all three Debug and both unsigned Release builds; Release launch under `com.naoki-ko.agendacue`; built plist identity and BGTask checks passed.
- Normal signed generic Release build: **BLOCKED** — no valid local signing identities and no provisioning profile for `com.naoki-ko.agendacue`; archive was therefore not attempted.
- Japanese residual audit: app-owned primary UI, permission guidance, state copy, accessibility labels, and purpose strings are Japanese. Product/system names and source-provided calendar/event/source content remain unchanged.
- Scope audit: scheduling dates/identities/lifecycle, reconciliation, background semantics, domain rules, calendar write prohibition, timeline, settings, persistence schema, and event-detail business behavior are unchanged. Phase A changes are release configuration hygiene, privacy manifest, Japanese stop copy, a narrow Sendable fix, and documentation/evidence.

WU-09-05 provides three lightweight first-launch steps: welcome, Calendar rationale/request, and Alarm rationale/request. Each request is made only while authorization is not determined. Denial still permits completion; completion persists independently of permission state, so later revocation does not replay onboarding. Completed users see the existing inline/System Settings recovery path.

AlarmKit presentation receives the unmodified nonblank source event title. Blank or whitespace-only titles use the Japanese fallback `予定`. Alarm date, stable identity, generated UUID, lifecycle, reconciliation, and capacity behavior are unchanged.

Accessibility Inspector, real VoiceOver, real-device permissions/EventKit/AlarmKit/Watch/background behavior, physical usability, and final owner acceptance remain mandatory Human Gate work. No item is passed by Codex.

## Remaining owner inputs

- Final App Icon approval.
- Install a valid Apple Development/Distribution certificate and compatible provisioning profile; verify/register the Production App ID through the owner account.
- Support URL and Privacy Policy URL/status.
- Final metadata, copyright holder, category, screenshots, and App Store Connect decisions.

## Release blockers

- Local keychain contains zero valid code-signing identities.
- No matching provisioning profile for `com.naoki-ko.agendacue` was resolved by a normal Release device build.
- Production identity integration itself is complete; signed archive remains blocked only by signing/App ID/profile availability and final icon approval.
- Actual system-scheduled background execution timing was not tested on a real device; foreground/resume remains authoritative.

## Required Human Review

H01–H46 are defined in `docs/release/HUMAN_GATE_CHECKLIST.md`; the result record is `docs/release/HUMAN_GATE_RESULT.md`. No human item is marked passed. WU-10 Human Gate cannot be waived and final owner decision is PENDING.
