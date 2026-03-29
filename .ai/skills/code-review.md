---
name: code-review
description: Critically review changed code for bugs, security, logic errors, and quality issues — then fix everything found
---

# Critical Code Review & Fix

Review all recently changed code with extreme scrutiny. Assume every line contains
a latent bug until proven otherwise. The goal is to catch what humans miss: subtle
logic errors, off-by-one bugs, race conditions, security holes, and inconsistencies
that accumulate into production incidents.

## Step 1: Identify What Changed

1. Run `git diff HEAD` to see unstaged changes
2. Run `git diff --cached` to see staged changes
3. If both are empty, run `git diff HEAD~1` to review the last commit
4. Build a list of all changed files and their change type (added/modified/deleted)

## Step 2: Read Full Context

For EVERY changed file:

1. Read the **entire file** — not just the diff. Bugs hide in how changes interact
   with surrounding code, not in the changed lines alone
2. Read any files that import from or are imported by the changed files
3. Read any test files that correspond to the changed files
4. Read any configuration files referenced by the changed code

## Step 3: Critical Review — Question Everything

For each changed file, systematically check every category below. Do NOT skip
categories — silent "no issues" is how bugs ship.

### 3a. Correctness & Logic

- Does the code do what the author intended? Trace every code path mentally
- Are there off-by-one errors in loops, slices, or range checks?
- Are boolean conditions correct? Check for inverted logic, missing negations,
  wrong operators (`&&` vs `||`, `==` vs `===`, `<` vs `<=`)
- Are null/undefined/empty checks present where needed? What happens with
  unexpected input types?
- Are return values checked? Are errors swallowed silently?
- Are there implicit type coercions that could cause surprises?
- Are regex patterns correct? Test them mentally against edge-case inputs
- Are mathematical operations correct? Check for integer overflow, division
  by zero, floating-point precision issues

### 3b. Security

- Any user input flowing into commands, queries, file paths, or HTML without
  sanitization? (command injection, SQL injection, path traversal, XSS)
- Are secrets, tokens, or credentials hardcoded or logged?
- Are permissions checked before privileged operations?
- Are cryptographic operations using secure algorithms and proper randomness?
- Are file operations using safe paths (no symlink following, no `..` traversal)?
- Are HTTP responses setting appropriate security headers?
- Is sensitive data being exposed in error messages or stack traces?

### 3c. Concurrency & State

- Are there race conditions? Can two callers reach the same mutable state?
- Are shared resources properly locked/synchronized?
- Are async operations awaited? Any missing `await` that would cause silent
  fire-and-forget?
- Are there potential deadlocks from lock ordering?
- Is state being mutated when it should be immutable (or vice versa)?

### 3d. Error Handling & Resilience

- Are all error paths handled? What happens when external calls fail?
- Are try/catch blocks too broad (swallowing unexpected errors)?
- Are error messages helpful for debugging? Do they include context?
- Are resources cleaned up on failure (file handles, connections, temp files)?
- Are retries implemented correctly (with backoff, with limits)?
- Can partial failures leave the system in an inconsistent state?

### 3e. Performance & Resource Leaks

- Are there N+1 query patterns or unnecessary loops over large datasets?
- Are database queries missing indexes for the filters/sorts used?
- Are there memory leaks (event listeners not removed, caches growing unbounded)?
- Are files/connections/streams being closed after use?
- Are there unnecessary allocations in hot paths?

### 3f. API & Contract Compliance

- Do function signatures match their callers' expectations?
- Are return types consistent with what callers expect?
- Are API request/response shapes matching the documentation or spec?
- Are breaking changes properly versioned or flagged?
- Are new public APIs consistent with existing conventions in the codebase?

### 3g. Code Quality & Maintainability

- Is there duplicated logic that should be extracted?
- Are variable/function names accurate and descriptive?
- Are there stale comments that no longer match the code?
- Are magic numbers or strings used where named constants should be?
- Is the code unnecessarily complex? Could it be simpler?
- Are there dead code paths or unreachable branches?

### 3h. Test Quality (if tests were changed/added)

- Do tests actually test the behavior they claim to? Read assertions carefully
- Are there false positives — tests that pass even if the code is broken?
- Are edge cases tested (empty input, boundary values, error conditions)?
- Are mocks/stubs realistic? Do they match real API behavior?
- Is test setup creating a realistic scenario or a trivially-passing one?
- Are there missing test cases for new code paths?

## Step 4: Report Findings

Present findings grouped by severity, most critical first:

```
## Code Review Findings

### CRITICAL (must fix — bugs, security, data loss)
1. **[file:line]** Description of the issue, why it's dangerous,
   and what the correct behavior should be

### HIGH (likely to cause problems — logic errors, missing checks)
1. **[file:line]** ...

### MEDIUM (code quality — duplication, unclear names, stale comments)
1. **[file:line]** ...

### LOW (style, minor improvements)
1. **[file:line]** ...

**Total: N findings (X critical, Y high, Z medium, W low)**
```

If zero findings in a category, omit that category. If truly zero findings
across all categories, state explicitly: "Clean review — no findings." But be
suspicious of your own clean review — re-check the most complex changed function
one more time before declaring it clean.

## Step 5: Fix ALL Findings

Fix every finding from Step 4 — critical through low. No exceptions, no deferrals.

For each fix:
1. Make the code change
2. Verify the fix doesn't break surrounding code
3. If the fix changes behavior, update or add tests accordingly
4. If the fix changes an API/interface, update callers

## Step 6: Verify After Fixes

1. Run the project's linter — must pass clean
2. Run the project's test suite — all tests must pass
3. If either fails, fix the failure and re-run
4. Do a final scan of the fixed code to confirm no regressions were introduced

## Step 7: Summary

```
## Review Complete

**Files reviewed:** <list>
**Findings:** <N> total (<breakdown by severity>)
**All findings fixed:** Yes
**Tests pass:** Yes
**Linter clean:** Yes
```
