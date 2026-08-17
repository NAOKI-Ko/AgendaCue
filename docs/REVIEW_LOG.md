# Review Log

Reviews and evidence are commit-specific. Never reuse approval after the reviewed content changes.

| Date | Work Unit | Branch | Target SHA | Reviewer | Automated evidence | Human Gate | Decision / notes |
|---|---|---|---|---|---|---|---|
| — | Bootstrap | main | To be filled after bootstrap commit | Codex | Documentation checks only; no implementation/build evidence | PENDING | Initial Source of Truth baseline |
| 2026-08-18 | WU-00 | `wu-00-feasibility-platform-gate` | Final WU-00 commit reported at handoff | Codex automated gate only | Xcode 26.6 / iOS 26.5: XCTest 5/5; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded; Simulator launch smoke succeeded | **PENDING H01–H07** | No human review or merge decision. WU-01 remains NOT STARTED. |
| 2026-08-18 | WU-01 | `wu-01-product-foundation` | Final WU-01 commit reported at handoff | Codex automated gate only | XCTest 11/11; specific Simulator, generic Simulator, and unsigned generic Device builds succeeded | **OWNER WAIVED / DEFERRED TO WU-10** | No device behavior claimed. Owner consolidated intermediate Human Gates into WU-10. |

## Entry requirements

Record the exact full SHA, commands/evidence locations, unresolved findings, and explicit human gate statement. If a new commit is added, create a new review entry and rerun affected gates.

The WU-00 row is intentionally not a review approval: its exact final commit SHA is emitted in the handoff report after the single intentional commit is created. Automated conclusions apply only after confirming that commit's tree matches the tested worktree. A human review entry must record that exact SHA before merge.

The same SHA-binding rule applies to WU-01. Owner waiver allows the pipeline to continue after automated evidence; it does not convert deferred device checks into PASS results.
