# Review Log

Reviews and evidence are commit-specific. Never reuse approval after the reviewed content changes.

| Date | Work Unit | Branch | Target SHA | Reviewer | Automated evidence | Human Gate | Decision / notes |
|---|---|---|---|---|---|---|---|
| — | Bootstrap | main | To be filled after bootstrap commit | Codex | Documentation checks only; no implementation/build evidence | PENDING | Initial Source of Truth baseline |
| 2026-08-18 | WU-00 | `wu-00-feasibility-platform-gate` | Final WU-00 commit reported at handoff | Codex automated gate only | Xcode 26.6 / iOS 26.5: XCTest 5/5; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded; Simulator launch smoke succeeded | **PENDING H01–H07** | No human review or merge decision. WU-01 remains NOT STARTED. |
| 2026-08-18 | WU-01 | `wu-01-product-foundation` | Final WU-01 commit reported at handoff | Codex automated gate only | XCTest 11/11; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded | **OWNER WAIVED / DEFERRED TO WU-10** | No device behavior claimed. Owner consolidated intermediate Human Gates into WU-10. |
| 2026-08-18 | WU-02 | `wu-02-calendar-source` | Final WU-02 commit reported at handoff | Codex automated gate only | XCTest 19/19; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded; read-only source audit passed | **OWNER WAIVED / DEFERRED TO WU-10** | Provider/device compatibility not claimed; WU-03 NOT STARTED. |
| 2026-08-18 | WU-03 | `wu-03-alarm-rule-engine` | Final WU-03 commit reported at handoff | Codex automated gate only | XCTest 29/29; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded; purity audit passed | **OWNER WAIVED / DEFERRED TO WU-10** | No scheduling/device behavior claimed; WU-04 NOT STARTED. |
| 2026-08-18 | WU-04 | `wu-04-alarm-scheduling` | Final WU-04 commit reported at handoff | Codex automated gate only | XCTest 42/42; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded; lifecycle scope audit passed | **OWNER WAIVED / DEFERRED TO WU-10** | No device firing claimed; WU-05 NOT STARTED. |
| 2026-08-18 | WU-05 | `wu-05-calendar-reconciliation` | Final WU-05 commit reported at handoff | Codex automated gate only | XCTest 65/65; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded; reconciliation scope audit passed | **OWNER WAIVED / DEFERRED TO WU-10** | No device reconciliation behavior claimed; WU-06 NOT STARTED. |
| 2026-08-18 | WU-06 | `wu-06-event-overrides` | Final WU-06 commit reported at handoff | Codex automated gate only | XCTest 87/87; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded; override scope audit passed | **OWNER WAIVED / DEFERRED TO WU-10** | No device/UI behavior claimed; WU-07 NOT STARTED. |
| 2026-08-18 | WU-07 | `wu-07-production-ux` | Final WU-07 commit reported at handoff | Codex automated gate only | XCTest 98/98; specific Simulator, generic Simulator, unsigned generic Device builds; 11-screen simulator Visual QA | **OWNER WAIVED / DEFERRED TO WU-10** | Codex visual evidence only; no Human Visual QA PASS; WU-08 NOT STARTED. |
| 2026-08-18 | WU-08 | `wu-08-reliability` | Final WU-08 commit reported at handoff | Codex automated gate only | XCTest 111/111; specific Simulator, generic Simulator, unsigned generic Device builds; Production UI launch smoke; BackgroundTasks plist/static and orchestration tests | **OWNER WAIVED / DEFERRED TO WU-10** | Background timing/device launch not claimed; foreground remains authoritative; WU-09 NOT STARTED. |

## Entry requirements

Record the exact full SHA, commands/evidence locations, unresolved findings, and explicit human gate statement. If a new commit is added, create a new review entry and rerun affected gates.

The WU-00 row is intentionally not a review approval: its exact final commit SHA is emitted in the handoff report after the single intentional commit is created. Automated conclusions apply only after confirming that commit's tree matches the tested worktree. A human review entry must record that exact SHA before merge.

The same SHA-binding rule applies to WU-01. Owner waiver allows the pipeline to continue after automated evidence; it does not convert deferred device checks into PASS results.
