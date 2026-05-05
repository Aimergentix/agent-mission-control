# AGENTS.md

## Mission

This repository must remain understandable, testable, and safe for agent-assisted development.

## Required reading before edits

1. Read `docs/ARCHITECTURE.md`.
2. Read `docs/PRODUCT.md` if behavior or UX changes.
3. Read `docs/CONSTRAINTS.md`.
4. Read the current ticket or spec.

## Work rules

- Implement the smallest coherent change that satisfies the ticket.
- Do not expand scope.
- Do not add dependencies without explicit justification.
- Do not remove tests to make validation pass.
- Do not bypass `scripts/validate-agent-work`.
- Prefer clear boring code over clever abstractions.
- Update docs when behavior, architecture, or workflow changes.

## Steps

1. Restate the goal in one sentence.
2. List assumptions.
3. Identify affected files.
4. Implement the smallest coherent change.
5. Run validation.
6. Fix failures.
7. Stop when validation passes or when blocked.

## Failure policy

If validation fails:

1. Read the exact error.
2. Identify the likely cause.
3. Make the smallest fix.
4. Re-run validation.

Repeat at most 3 times. If still failing, stop and report:

- Failing command
- Error summary
- Attempted fixes
- Suspected root cause

## Validation

> **Note:** `validate-agent-work` must be wired to at least one real check
> before it is a meaningful safety gate. See `START_HERE.md` Step 2.

Before handoff, run:

```bash
./scripts/validate-agent-work
```

If validation fails, fix the issue or report the blocker.

## Handoff format

Return:

- Goal
- Summary
- Files changed
- Validation run
- Remaining risks
- Open questions
- Suggested follow-up tickets
