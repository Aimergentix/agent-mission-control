# Agent Mission Control

*A proposal for retiring "agent harness" as the main metaphor for AI-agent infrastructure.*

---

## 1. The problem with "harness"

We currently call the software around an AI agent a *harness*. Inner harness, outer harness — the tools, runtime state, memory, policies, evaluators, approval gates, and recovery procedures that surround the model.

The word made sense when an agent was an LLM, a prompt, a small set of tools, and a loop. A working agent system today looks more like:

```text
LLM + runtime + memory + tools + policies + evals + workflows + logs + human control + environment
```

That outer layer chooses what the agent sees, decides which tools exist, limits which actions execute, runs tests against outputs, records traces, escalates to humans, aborts, retries, and updates memory. It is the part of the system that turns stochastic generation into operational behaviour — the part that decides, every few seconds, whether the next token becomes a side effect.

Calling that a harness is like calling an air traffic control tower a seatbelt. The name decides where engineers look for responsibility. If we call it a harness, we look for straps; if we call it something else, we might look for telemetry, authority, abort conditions, and the on-call rota.

---

## 2. Agent Mission Control, defined

> **Agent Mission Control** is the orchestration and oversight layer around an AI agent. It defines the mission, routes context and tools, monitors execution, enforces policy, receives telemetry, triggers correction loops, and escalates uncertain or risky actions to humans or human teams.

The core model does inference; it is the cognitive engine, not the agent. The agent runtime is the execution machinery — the loop, the state, the tool calls, the sandbox, the retries. Mission Control sits above the runtime and answers a different class of question. What is the mission. What is allowed. What must be logged. What counts as success. When does a human approve. When does the agent stop.

Three working labels carry the load below. They are role names, not brand names: keep them, replace them, refine them — but keep the distinctions they mark.

- **Command Nexus** — routing and coordination
- **Aegis Layer** — policy and protection
- **Agentic Helm** — steering and operator control

---

## 3. Three subsystems

### 3.1 Command Nexus — routing and coordination

The Command Nexus binds model, tools, memory, policies, evaluators, and operators into one routed, stateful execution. It picks the next move from a space of moves: which tool, in which order, with which context, under which evaluator.

A typical run flows through it like this:

```text
user request -> planner -> retrieval -> tool call -> evaluator -> correction -> answer
```

What is *not* a Command Nexus: a tool registry (inventory without coordination); a fixed `retrieve → generate → return` chain (a script, not a chooser); an LLM router that selects models by topic (one input to a Nexus, not the Nexus itself); a message bus that moves bytes without policy; a deterministic workflow engine such as Temporal or Airflow, which assumes the graph the Nexus must select at runtime; a multi-agent swarm whose peers exchange messages without a coordinating layer above them. A pipeline executes a known plan. The Nexus chooses which plan to run, against which evaluator, with which tools, given the state of the mission.

### 3.2 Aegis Layer — policy and protection

The Aegis Layer enforces, at execution time, the gap between what the model can produce and what the system is permitted to do. *Capability ≠ permission.* A model may draft a `DROP TABLE`. The Aegis Layer is the only place in the system where the architecture, rather than the prompt, decides whether that statement reaches the database.

What is *not* an Aegis Layer: a system prompt that requests good behaviour (conversation, not enforcement); an output filter that classifies text without authority over actions; a sandbox alone, which limits the blast radius after a decision but does not govern the decision; IAM or RBAC on the underlying APIs, which is necessary substrate but cannot reason about evaluator scores or approval state; a test suite without authority to block; rate limits, which constrain volume but not meaning; a human reviewer in a chat channel whose approval is requested but not required by the runtime. A "guardrails" library that only logs and warns belongs in the telemetry box, not this one.

### 3.3 Agentic Helm — steering and operator control

The Agentic Helm is the surface through which an operator — human or supervising controller — issues, redirects, constrains, or aborts the mission while it runs. The form is incidental: a CLI, a chat command, an IDE button, a dashboard, a mission file edited mid-run. What matters is that the operator can say `pause`, `abort`, `retry with constraint X`, or `require approval for the next action`, and that the runtime honours it within bounded latency.

What is *not* an Agentic Helm: the initial prompt, which is the launch order; a read-only dashboard, which is a window without actuators; the agent's own chat UI, which lives inside the loop and competes with the agent's reasoning for the same channel; logs and traces, which inform a Helm but cannot steer; a static `AGENTS.md` at rest; a post-hoc PR review, which gates artifacts rather than the running process; an LLM "manager agent" supervising worker agents without a human-reachable surface, which is hierarchical autonomy under another name. The Helm presupposes an operator outside the agent system, with authority to interrupt it.

---

## 4. The wrong villain, and an older lesson

*Agent Master Control* sounds powerful and is the wrong target. A single all-knowing controller dictating behaviour to every agent from a monolithic centre is the architecture of the antagonist in every credible story about systems of this kind. Mission Control is the opposite shape: observable, bounded, auditable, interruptible, distributed where useful, human-accountable, explicit about mission and risk.

The lesson is older than agents. Early computers were enormous, expensive, shared, and institutionally serious; the machine alone was insufficient. It needed job control, batch systems, terminals, shells, permissions, time-sharing, audit logs, and a profession of operators around it. Operations in those environments meant concrete things: an operator who could kill a job, a queue with priorities, a printed log of what ran and at whose request, a procedure for restarting after a crash, a permission system that distinguished a user from the system account. Mainframe culture treated the control surface as load-bearing engineering rather than as a wrapper around the real work.

Agents bring this requirement back at a higher level of stochasticity. A large agent system shares the operational profile — expensive, high-stakes, multi-tenant, consequential — without inheriting the discipline that mainframe operators had to develop in order to keep their machines useful. The interface and the control system are first-class engineering again, and the people building them are doing operations work whether they call it that or not.

---

## 5. Design principles

Five principles fall out of taking Mission Control seriously.

**Make the mission explicit.** "Be helpful" is a mood. "Diagnose the failing tests in `payments/` and propose a minimal patch without changing public APIs; stop after one attempt and request review" is a mission, with goal, scope, constraint, and an exit condition a reviewer can check.

**Separate capability from permission.** The model knows how to delete the branch. The runtime must still refuse, until an Aegis rule and an approval gate both clear. A prompt that asks for restraint is a request, and the runtime cannot tell whether the request was honoured.

**Prefer telemetry over trust.** A serious agent system exposes traces — context retrieved, tools called, diffs produced, tests run, policy checks fired, retries attempted, points of remaining uncertainty — at a granularity that lets a reviewer reconstruct a run six weeks later. Trust accrues to systems that produce this material on every run, not to vendors who promise it in slides.

**Make interruption normal.** The Helm should support pause, abort, rollback, summarise-state, continue-from-checkpoint, and require-approval-before-next-action as ordinary operations rather than emergencies. A system that can only be stopped by killing the process has not been designed to be stopped.

**Use feedback loops, not just prompts.** A prompt is feedforward control. Tests, evaluators, log scans, reviewers, and approval gates close the loop:

```text
prompt -> action -> observation -> evaluation -> correction -> action
```

Reliability comes from the loop, not from cleverer prompts inside the first arrow.

---

## 6. What will change

The practical test of this vocabulary is small and immediate. Open the architecture diagram, the runbook, or the `AGENTS.md` for an agent system currently in production or close to it, and find the box labelled *harness*, *orchestration*, or *agent framework*. Three questions follow. Where is the mission written down in a form a reviewer can check, and which file owns it. Where, in code, does the boundary between what the model may draft and what the runtime may execute live, and which on-call engineer is paged when an Aegis rule denies an action in production. Which control surface lets a human pause, redirect, or abort a run already in flight, and what is its measured latency from operator intent to runtime effect. If the answers live in prompts, comments, Slack threads, or institutional memory rather than in code paths, deployment manifests, and pager rotations, the system has a harness, not Mission Control, and the difference will surface the first time a model drafts something the operator would not have signed.
