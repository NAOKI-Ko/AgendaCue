# Agent Operating Contract

## Required reading

Before any work, read `docs/START_HERE.md` and `docs/PROJECT_STATE.md`, then follow their links for the active Work Unit (WU). Re-read `PROJECT_STATE.md` immediately before reporting status.

## Source of Truth priority

When instructions conflict, use this priority:

1. Explicit human instruction for the current task.
2. This `AGENTS.md` operating contract.
3. `docs/PROJECT_STATE.md` for current phase, active work, gates, and evidence.
4. Approved product/domain/architecture documents under `docs/`.
5. The active WU specification and its recorded decisions.
6. Implementation and tests.

Do not silently resolve a material contradiction. Stop, record it, and request a human decision.

## Work Unit isolation and Scope Gate

- One WU equals one branch and one PR after bootstrap.
- Before implementation, identify the WU, branch, in-scope files/behaviors, out-of-scope items, automated gates, Human Gate, and expected evidence.
- Pass the Scope Gate by confirming the proposed change is fully contained in the WU. If not, stop and split or obtain explicit approval.
- Do not opportunistically refactor, add products, dependencies, platforms, abstractions, or parked features.
- Scope expansion is prohibited without explicit human approval and an updated Source of Truth.

## Evidence and gates

- Never fabricate build, test, simulator, device, review, or Human Gate results.
- Report commands, environment, outputs, and limitations accurately.
- A Human Device Gate is `PASS` only after explicit human evidence. Codex must never infer or self-assert that pass.
- At a required Human Gate, stop after presenting evidence and wait. Do not continue into the next WU.

## Git and review rules

- `main` is protected by process: Work Units never push directly to it.
- Use a dedicated branch and PR for every post-bootstrap WU; keep commits intentional and scoped.
- Do not rewrite shared/reported history or force-push without explicit approval.
- Preserve unrelated work and existing history.
- A review must name the exact target commit SHA. Evidence and conclusions apply only to that SHA.
- If the reviewed branch changes, record the new SHA and rerun affected gates before approval or merge.
- Merge only after required automated gates, evidence, review, and Human Gate are satisfied.

## Model policy

- Default: GPT-5.6 Sol / Low.
- Escalate to Sol Medium only for non-trivial implementation or debugging.
- Escalate to Sol High only for architecture, lifecycle, or platform ambiguity.
- Max and Ultra are prohibited by default.
- Record why escalation is necessary; do not escalate this bootstrap task beyond Sol Low.
