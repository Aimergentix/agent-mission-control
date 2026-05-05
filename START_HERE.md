# Agent Mission Control

A folder you copy into any software project to give an AI coding assistant
structure, rules, and a quality gate.

---

# Table of Contents

- [Step 0 — Audit first](#step-0--audit-first-optional-existing-codebases-only)
- [Step 1 — Copy](#step-1--copy)
- [Step 2 — Bootstrap](#step-2--bootstrap-one-time-fresh-ai-session)
- [Step 3 — Daily work](#step-3--daily-work)
- [File map](#file-map)

---

## Step 0 — Audit first (optional, existing codebases only)

If you are adopting an existing codebase — not a blank project — run this
audit before doing anything else. It is read-only: it produces a report and
a fix plan, and changes nothing.

Open a **fresh AI session** in your project folder. Paste this prompt:

## ––––– ––––– ––––– ––––– ––––– ––––– ––––– –––––
```
You are auditing this codebase. This is a read-only task.
Do NOT edit any file. Do NOT run any command that writes to disk.

## What to do

Scan every file in the repository. Then produce two outputs:

### Output 1 — Audit Report

For each problem found, use this format:

[FINDING-NN] Short title
- File: <path and line number or function name>
- Observation: <what you saw, quoted or precisely described>
- Category: Correctness | Risk | Maintainability | Clarity | Style
- Severity: Critical | Major | Minor | Suggestion
- Confidence: 0–100%
- Recommended fix: <one specific action>

Categories:
- Correctness: wrong output, broken logic, unhandled edge cases
- Risk: correct today but fragile — missing error handling, hidden side effects
- Maintainability: hard to change safely — naming, coupling, duplication
- Clarity: intent not readable — misleading names, unexplained magic values
- Style: formatting or convention only, no correctness impact

Rules:
- Every finding must cite a file and location. No finding without evidence.
- If you are uncertain whether a pattern is intentional, note it but cap
  severity at Major.
- Do not invent APIs, versions, or line numbers. Quote verbatim or omit.

### Output 2 — Fix Plan

A flat prioritized list of the findings, ordered by impact:

Priority | Finding ID | File | One-line action
---------|------------|------|----------------
1        | FINDING-NN | ...  | ...

Then a short paragraph: what to fix first and why.
```
## ––––– ––––– ––––– ––––– ––––– ––––– ––––– –––––


The AI will scan the codebase, write `audit-report.md`, and stop.
Read the report. Decide which fixes to act on before proceeding to Step 1.

---

## Step 1 — Copy

Copy this folder's contents into your project root:

```bash
cp -r ./. /path/to/your/project/
```

If your project already has a file with the same name, check for conflicts
before overwriting.

---

## Step 2 — Bootstrap (one-time, fresh AI session)

Open a **fresh AI session** in your project folder.
Paste the prompt below as your first message.
The AI will scan your codebase and fill in the `docs/` files.

## ––––– ––––– ––––– ––––– ––––– ––––– ––––– –––––
```
You are bootstrapping an agentic Mission Control for this codebase.

Scan the repository. Fill in the stub fields in each file in docs/:

- docs/ARCHITECTURE.md — system overview, component map, data flow,
  external dependencies, key constraints
- docs/PRODUCT.md — purpose, user goals, key behaviors
- docs/QUALITY.md — what linters, test runners, and build tools exist
  in this repo and whether they are configured
- docs/CONSTRAINTS.md — only hard constraints enforced by the code
  (pinned language versions, required env vars, license checks in CI).
  Do not invent policy rules.

Rules:
- Cite the source file for every claim (file path, config key, import,
  shebang line, package manifest entry).
- For each value you fill in, add a comment:
    <!-- INFERRED from <file> — confirm before trusting -->
- If you cannot determine a value from code alone, write:
    <!-- REQUIRES HUMAN INPUT -->
- Do not remove existing headings or add new sections.

After filling the docs:
- Check scripts/validate-agent-work. If you can identify the project's
  toolchain with certainty (linter, test runner, build), uncomment the
  matching block and set CHECKS_WIRED=true. If unsure, leave it unchanged.

Return:
- One sentence per doc file: what was filled, what needs human input,
  and the primary evidence source.
- A flat list of every REQUIRES HUMAN INPUT field so I can fill them
  in one pass.
- Risks: any field you were uncertain about that could mislead a future
  agent if wrong.
```

### ––––– ––––– ––––– ––––– ––––– ––––– ––––– –––––



After the AI responds:
1. Read the filled docs.
2. Confirm each `INFERRED` field — correct anything wrong.
3. Fill each `REQUIRES HUMAN INPUT` field yourself.
4. Delete all `<!-- ... -->` annotation comments.

That's it. The Mission Control is ready.

---

## Step 3 — Daily work

For each task you give the AI:

1. Fill in `tickets/TICKET_TEMPLATE.md` with the goal and acceptance criteria.
2. Give the agent: the ticket + `AGENTS.md` + the relevant `docs/` files.
3. The agent works, runs `./scripts/validate-agent-work`, and hands off.
4. Review the handoff output. Merge or request fixes.

If the agent makes the same mistake twice, record it in `docs/KNOWN_FAILURES.md`.

---

## File map

```
START_HERE.md              ← you are here
AGENTS.md                  ← agent reads this every session (rules + workflow)

docs/
  ARCHITECTURE.md          ← filled by AI in Step 2
  PRODUCT.md               ← filled by AI in Step 2
  QUALITY.md               ← filled by AI in Step 2
  CONSTRAINTS.md           ← filled by AI in Step 2, confirmed by you
  DECISIONS.md             ← fill as you go (non-obvious decisions)
  KNOWN_FAILURES.md        ← fill as you go (repeated agent mistakes)

scripts/
  validate-agent-work      ← the "done" gate — agent must pass this
  bump-version.sh          ← version bumper (bash)

tickets/
  TICKET_TEMPLATE.md       ← copy and fill for each task

.version                   ← current version (used by bump-version.*)
.gitignore
```
