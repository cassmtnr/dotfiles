---
description: "CRAFT — Code, Review, Audit, Fix, Test — artisan-quality implementation"
argument-hint: "<sub-phase id or task description>"
---

# CRAFT: Code, Review, Audit, Fix, Test — $ARGUMENTS

Implement **$ARGUMENTS** from the project's roadmap/spec using the CRAFT workflow:
build it with care, then refine it through 3 rounds of expert review, fixing
all findings between rounds. Like an artisan — measure twice, cut once, then
polish until it shines. No task ships until it's craftsmanship-quality.

## Step 1: Read the Spec

1. Find the task/sub-phase matching `$ARGUMENTS` in the project's roadmap, spec,
   or issue tracker
2. Read the full spec: goal, dependencies, files to build/modify, schemas, settings,
   test cases, verification steps
3. Check dependencies — confirm prerequisite tasks are complete
4. Read relevant documentation and architecture files for current context

## Step 2: Explore & Design

1. Spawn the `feature-dev:code-explorer` agent to trace relevant existing code —
   execution paths, patterns, abstractions, and dependencies that the new code
   must integrate with
2. Spawn the `feature-dev:code-architect` agent to design the implementation —
   files to create/modify, component responsibilities, data flow, and build order
3. Summarize the implementation plan to the user before starting

## Step 3: Code

1. Follow the spec and the architecture design from Step 2
2. Use the `spec-writing` skill patterns if the spec needs interpretation
3. Create/modify files as specified
4. Write all test cases listed in the spec
5. Add any obvious tests the spec missed
6. Follow all project conventions from CLAUDE.md (style, patterns, conventions)

## Step 4: Initial Verification

1. Run the project's linter — fix any errors
2. Run the project's test suite — all tests must pass (new AND existing)
3. If any failures, fix them before proceeding to Round 1

## Step 5: Round 1 — Review (Structural)

Spawn the `code-reviewer` agent to perform a deep review. Focus areas:

- **Correctness:** Does the implementation match the spec? Any missing edge cases?
- **Architecture:** Does it follow project patterns? Any circular imports?
- **Conventions:** Style, documentation, type safety, error handling
- **Security:** No secrets exposed, no injection, input validation at boundaries
- **Tests:** Do tests actually test the right thing? Any false positives?

Fix ALL findings. Then:

1. Run linter
2. Run tests
3. Report: "Round 1 complete — N findings refined"

## Step 6: Round 2 — Audit (Regression & Consistency)

Spawn a SECOND `code-reviewer` agent (fresh context). Focus areas:

- **Regressions from Round 1 fixes:** Did fixing Round 1 findings break anything?
- **Consistency:** Do new patterns match existing code in the same module?
- **Stale references:** Did any comments, docstrings, or documentation become outdated?
- **Integration:** Are new methods properly wired into callers? Any dead code?
- **Test quality:** Are mocks realistic? Do assertions check the right values?

Fix ALL findings. Then:

1. Run linter
2. Run tests
3. Report: "Round 2 complete — N findings refined"

## Step 7: Round 3 — Fix & Polish (Final Pass)

Spawn a THIRD `code-reviewer` agent (fresh context). Focus areas:

- **Clean bill of health:** This round should find 0-2 minor issues at most
- **Documentation accuracy:** Do docstrings match the actual implementation?
- **Edge cases under stress:** What happens with empty data? Concurrent access?
  Timeouts? Malformed input?
- **Test coverage completeness:** Any untested branches? Any error paths
  without tests?

Fix any remaining findings. Then:

1. Run linter
2. Run tests
3. Report: "Round 3 complete — N findings refined (expected: 0-2)"

## Step 8: Simplify

Spawn the `code-simplifier` agent on all files changed during this task.
It will refine the code for clarity, consistency, and maintainability while
preserving exact functionality — eliminating unnecessary complexity, redundancy,
and overly nested structures.

After simplification:

1. Run linter
2. Run tests
3. Report: "Simplification complete — N refinements applied"

## Step 9: Test, Document & Ship

1. Update changelog with what was built (date, files, summary)
2. Update architecture docs if new services, methods, or schemas were added
3. Update roadmap/spec — mark the task as complete
4. Report final summary:

```
## CRAFTED: $ARGUMENTS

**Implemented:** <what was built>
**Files changed:** <list>
**Tests added:** <count>
**Total test count:** <count>

**Explore & Design:** codebase traced, architecture designed
**Round 1 (Review):**  <N> findings → all refined
**Round 2 (Audit):**   <N> findings → all refined
**Round 3 (Polish):**  <N> findings → all refined
**Simplification:**    <N> refinements applied

**Status:** Artisan quality. Ready for next task.
```
