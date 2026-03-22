---
name: spec-writing
description: Write implementation specs, phase plans, and retroactive documentation following proven quality patterns
---

# Spec Writing — Phase & Task Documentation

Use this skill when writing new phase/task specs, improving existing ones,
or documenting what was built retroactively. These patterns produce specs that
are implementation-ready — a developer can pick one up and build it without
asking questions.

## Phase/Epic Header Template

Every phase or epic must have these sections in order:

```markdown
## Phase N: Name `[STATUS]`

**Goal:** One sentence — what this phase delivers.

**Why now:** 2-3 sentences explaining the concrete urgency. Reference specific
problems, data, or constraints. Never generic ("improve quality") — always
specific ("rate limiting is already impacting production, making dozens of
calls per cycle across 6 service files").

**When:** Prerequisite conditions (e.g., "After Phase X is stable").

**Depends on:** Specific tasks or phases that must be complete.

### Architecture
(ASCII diagram showing how this phase's additions fit into the existing system)

### Sub-Phases / Tasks
(Table with #, Name, Description columns)
```

## Task/Sub-Phase Template — For PLANNED Work

```markdown
### Sub-Phase N-X: Name `[PENDING]`

**Goal:** What this task delivers and why it matters.

**Depends on:** Which task must be done first.

**Build these files:**
(File tree showing new files to create)

**What to modify:**
(Existing files that change, with specific guidance)

**New schemas / interfaces:**
(Exact field definitions with types, comments explaining each field,
and notes about edge cases or field mappings)

**New settings / configuration:**
(Exact names, types, default values, and which file they go in)

**Implementation details:**
(Method signatures, algorithm descriptions, API endpoint URLs with
request/response shapes, error handling behavior)

**Edge cases:**
(Bulleted list of what happens when things go wrong)

**Test cases:**
(Numbered list: test_name — Input → Expected output. Concrete values,
not vague descriptions)

**Verify:**
(Commands to run after implementation — both automated tests
and manual verification steps)
```

## Task/Sub-Phase Template — For DONE Work (Retroactive)

When documenting work that's already implemented:

```markdown
### Sub-Phase N-X: Name `[DONE]`

**Goal:** (Keep original goal)

**Delivered:** 2-3 sentences summarizing what was actually built. Include
concrete numbers (lines of code, number of methods, number of tests added).
Note any deviations from the original spec (e.g., "timeout changed from
60s to 5 minutes during implementation").

**What was built:**
(Settings added with exact names and values, methods created with
signatures, files changed, database migrations, new endpoints)

**Files changed:** (Flat list of files that were modified)

**Test cases:** (Updated to reflect actual test names, not planned ones)
```

## Quality Checklist

Before considering a spec complete, verify:

- [ ] **"Why now" is concrete** — references specific data, bugs, or
  constraints (not "improve quality" or "prepare for future")
- [ ] **Architecture diagram exists** for any phase that adds new services
  or changes data flow
- [ ] **Every new setting has a name, type, default, and file location**
- [ ] **Every schema/interface has field-level comments** explaining what
  each field contains, where it comes from, and edge cases
- [ ] **API endpoints include request params AND response shape** with
  example values
- [ ] **Test cases have concrete inputs → expected outputs** (not just
  "test that X works")
- [ ] **Edge cases are listed** (what happens on empty data, API failure,
  concurrent access, missing config)
- [ ] **Verification section includes both automated and manual steps**
- [ ] **Dependencies are explicit** (which specific task, not just "Phase N")
- [ ] **File tree shows new files AND existing files to modify**

## Proven Patterns

### Replacement Maps (when migrating from one system to another)
Table mapping every usage of the old system to its replacement, with columns:
Data, Current Source, Replacement, Task, Status.

### Decision Tables (when evaluating options)
Table with Option, Verdict (CHOSEN/Rejected), Why columns.

### Delivered Summary Tables (for completed phases)
Table with Component, Files, Lines, Key Additions columns.

### Issue Summary Tables (for bug-fix phases)
Table with Area, Issues Found, Task, Impact Level columns.

### Before/After Diagrams (for architectural changes)
ASCII diagrams showing the system before and after the change.

### Growth Path Tables (for config that scales)
Table showing milestone → what unlocks via configuration change.

## Anti-Patterns to Avoid

- **Vague goals:** "Improve the system" → Instead: "Fix 3 bugs in validation
  that cause limit violations"
- **Missing "Why now":** Starting with just "Goal:" → Always explain urgency
- **Pseudocode instead of real shapes:** `{...some data...}` → Instead: exact
  field names with types and comments
- **Generic test cases:** "test it works" → Instead:
  "test_sharpe_single_trade — 1 trade, std=0 → returns 0.0 (not division error)"
- **Deferred work:** "Phase 3 may add this" → Either build it now or don't
  mention it
- **Undocumented deviations:** Spec says 60s timeout, code uses 5 minutes →
  Always update the spec to match what was built

## TypeScript Interface Guidelines (for Frontend Specs)

When writing TypeScript interfaces for API responses:

1. **Match the actual backend response shape** — read the route handlers and
   query functions for the real field names and types
2. **Document the source** — comment where each field comes from (DB column,
   computed, config value)
3. **Use correct serialization types** — backend tuples serialize as arrays
   (`[string, string][]`), not objects (`{value, label}[]`)
4. **Include all fields** — don't omit fields the backend returns, even if
   the current UI doesn't use them
5. **Note type granularity** — backend may emit specific subtypes (e.g.,
   `"closed_profit"` and `"closed_loss"`) instead of a generic `"closed"`
