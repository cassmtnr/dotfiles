# Write a PROMPT.md for Ralph Orchestrator

You are writing a `PROMPT.md` file that will be consumed by **ralph-orchestrator** (`ralph run`). Ralph reads `PROMPT.md` as the task specification and runs an iterative event loop where an AI agent (Claude Code) executes it autonomously across multiple iterations.

## How ralph-orchestrator works

- Config lives in `ralph.yml` at the project root (backend: claude, prompt_file: PROMPT.md, completion_promise: LOOP_COMPLETE)
- The agent executes autonomously across up to 100 iterations
- Progress is documented in `.ralph/agent/scratchpad.md`
- The loop ends when the agent writes `LOOP_COMPLETE` to the scratchpad
- The user reviews and handles git operations manually after the loop completes

## Documentation (local — read files directly, no web fetch needed)

Local clone: `~/Dev/ralph-orchestrator/docs/`

Key docs to consult:

- **Configuration**: `~/Dev/ralph-orchestrator/docs/guide/configuration.md`
- **Writing prompts**: `~/Dev/ralph-orchestrator/docs/guide/prompts.md`
- **Presets**: `~/Dev/ralph-orchestrator/docs/guide/presets.md`
- **CLI reference**: `~/Dev/ralph-orchestrator/docs/guide/cli-reference.md`
- **Backends**: `~/Dev/ralph-orchestrator/docs/guide/backends.md`
- **Best practices**: `~/Dev/ralph-orchestrator/docs/03-best-practices/best-practices.md`
- **Event system**: `~/Dev/ralph-orchestrator/docs/advanced/event-system.md`
- **Task system**: `~/Dev/ralph-orchestrator/docs/advanced/task-system.md`
- **Memory system**: `~/Dev/ralph-orchestrator/docs/advanced/memory-system.md`
- **Examples**: `~/Dev/ralph-orchestrator/docs/examples/`
- **FAQ**: `~/Dev/ralph-orchestrator/docs/reference/faq.md`
- **Troubleshooting**: `~/Dev/ralph-orchestrator/docs/reference/troubleshooting.md`

Remote: https://github.com/mikeyobrien/ralph-orchestrator

Read these local files directly when you need to verify ralph-orchestrator behavior, configuration options, or prompt conventions. No web fetch required.

## What the user will provide

The user will describe what they want built or changed. Use `$ARGUMENTS` as their input. Ask clarifying questions if the description is vague before writing.

## PROMPT.md structure

Write the PROMPT.md following this structure (adapt sections as needed for the project):

```markdown
# [Project Title] - [Brief Description] for Ralph Orchestrator

## Critical Safety Rules

[Include the mandatory safety rules section below]

## Project Overview / Context

[What is being built, tech stack, architecture decisions]

## Requirements / Tasks

[Detailed requirements, task breakdown with priorities]

## Architecture / File Structure

[Directory layout, data flow, key patterns]

## Implementation Details

[Specific technical requirements, APIs, data models, conventions]

## Completion Criteria

When ALL tasks are complete and verified, write LOOP_COMPLETE to the scratchpad.
```

## Mandatory Safety Rules Section

EVERY PROMPT.md MUST include a "Critical Safety Rules" section near the top. To generate it:

1. Read the complete safety rules from `~/.claude/CLAUDE.md` (the global rules file)
2. Copy the entire "Critical Safety Rules" section into a fenced markdown code block
3. Add this line to the "What you SHOULD do instead" list: `- Document progress in .ralph/agent/scratchpad.md`
4. Add this line: `- The user will review and handle git operations manually after the loop completes`

## Additional conventions

1. **Completion signal**: Always end the PROMPT.md with instructions to write `LOOP_COMPLETE` to the scratchpad when all tasks are done and verified.

2. **Task execution rules** (include when there are multiple tasks):
   - Skip tasks marked as DONE
   - Check if new tasks affect completed tasks' code
   - Update affected code to stay consistent
   - Focus forward on incomplete work

3. **Scratchpad**: Remind the agent to document progress, decisions, and blockers in `.ralph/agent/scratchpad.md`.

4. **Testing**: Include test commands and expectations. The agent should verify its work compiles/passes before marking tasks complete.

5. **Phase boundaries**: If the project has multiple phases, clearly mark what is in scope vs out of scope. Use the pattern: 'Build this (Phase 1)' vs 'NOT in scope - do not build (Phase 2+)'.

## Now write the PROMPT.md

Based on the user's input (`$ARGUMENTS`), write a complete PROMPT.md file. Place it at `./PROMPT.md` in the current working directory. If a PROMPT.md already exists, read it first and ask the user if they want to replace or extend it.
