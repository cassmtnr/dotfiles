---
description: "CRAFT — Code, Review, Audit, Fix, Test — quality implementation with smart token use"
argument-hint: "<sub-phase id or task description>"
---

# CRAFT: Code, Review, Audit, Fix, Test — $ARGUMENTS

Implement **$ARGUMENTS** using the CRAFT workflow. Scale review depth to
change complexity — don't burn tokens on mechanical changes.

## Step 1: Read the Spec + Assess Complexity

1. Find `$ARGUMENTS` in the project's ROADMAP.md
2. Read the full spec: goal, files, exit criteria
3. **Classify the change:**
   - **Mechanical** (config changes, renames, threshold adjustments, dep upgrades):
     Skip Steps 2-3, do Step 4 directly, skip Rounds 2+3
   - **Moderate** (new script, service wiring, parameter extraction):
     Do Step 2 with direct Grep/Read (no subagents), 1 review round
   - **Complex** (new service, file splits, architecture changes):
     Full workflow with explore agents and 2+ review rounds

## Step 2: Explore & Design (skip for Mechanical)

For **Moderate** changes: use Grep/Read/Glob directly — no subagents.
For **Complex** changes: spawn explore + architect agents.
Summarize the plan to the user before coding.

## Step 3: Code

1. Implement per the spec
2. Follow repository instructions (`AGENTS.md` and shared AI instructions)
3. Write tests if the spec requires them

## Step 4: Verify

1. `ruff check .` — fix any errors
2. `pytest tests/ -q` — all tests must pass
3. If the spec has an audit target: `python -m audit` and verify

## Step 5: Review (scale to complexity)

**Mechanical changes:** No review agent. Ruff + tests are sufficient.

**Moderate changes:** ONE review pass — use the current CLI's review capability.
If a dedicated review agent or review command is available, use it. Otherwise do a self-review, fix findings, and re-run tests.

**Complex changes:** Up to 3 rounds if needed:
- Round 1: Structural review (correctness, architecture)
- Round 2: Only if Round 1 found critical bugs — check for regressions
- Round 3: Only if Round 2 found issues — should find 0-2 at most

**Always skip a round if the previous round found 0 issues.**

## Step 6: Document & Ship

1. Update `docs/CHANGELOG.md` with what was built
2. Update `ROADMAP.md` — mark the task `[DONE]`
3. Report summary:

```
## CRAFTED: $ARGUMENTS

**Implemented:** <what was built>
**Complexity:** Mechanical / Moderate / Complex
**Files changed:** <list>
**Review rounds:** <N> (findings: <count>)
**Tests:** <pass count>
```
