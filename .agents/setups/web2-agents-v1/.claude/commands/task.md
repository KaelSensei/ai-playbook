---
name: task
description: >
  Universal entry point. Describe your task in natural language. The orchestrator analyzes the
  complexity, decides which agents to spawn and in what order, then runs the execution. A CSS fix or
  a full new feature — same command.
argument-hint: '[free-form task description]'
---

# /task

Update `tasks/current_task.md`: status=ORCHESTRATING, task=$ARGUMENTS

---

## Step 1 — Orchestrator analyzes the task

```
You are orchestrator.
Load .claude/agents/orchestrator.md.
Load project-architecture.md, data-architecture.md, constants.md.
Load the ## Agent Team table from CLAUDE.md.

Task received: $ARGUMENTS

Analyze:
1. Which domains are affected?
2. What is the complexity (level 1, 2, or 3)?
3. Which agents should be spawned?
4. Which flow should be used?

Produce your full execution plan before spawning anything.
```

Present the plan to the user. **Gate**: _"Is this plan correct?"_ Wait for confirmation before
executing — unless it's an obvious level 1 task.

---

## Step 2 — Execute per the level

### Level 1 — Direct

Spawn the single identified agent:

```
You are [AGENT].
Load context docs and skills per the Agent Team table.

Task: $ARGUMENTS

Implement directly. No formal spec required.
Run the tests after each change.
Output: diff + passing tests.
```

---

### Level 2 — Implementation + Review

**2a. Owner agent implements:**

```
You are [OWNER_AGENT].
Task: $ARGUMENTS

Implement. TDD if applicable.
Output: diff + tests.
```

**2b. Reviewer agent in parallel or right after:**

```
You are [REVIEWER_AGENT].
Load team--skill-review.
Review the diff for: $ARGUMENTS
```

Apply `team--skill-refine` if APPROVE_WITH_CHANGES.

---

### Level 3 — Full flow

Redirect to the formal flows:

```
Level 3 complexity detected.
Launching the full flow:

→ /spec [feature] to produce the spec + test list
→ /build [spec] for the TDD implementation
→ /review for the final review

Running /spec now.
```

Chain `/spec` → `/build` → `/review` automatically.

---

## Step 3 — Completion

Update `tasks/current_task.md`: status=IDLE

```
✅ Task complete: $ARGUMENTS
Level: [1/2/3]
Agents used: [list]
Flow: [direct / review / spec+build]
```

---

## Examples of Automatic Routing

| Task                                                  | Level | Agents                        | Flow           |
| ----------------------------------------------------- | ----- | ----------------------------- | -------------- |
| "fix the padding on the submit button"                | 1     | frontend-engineer             | direct         |
| "add a `bio` field to the profile"                    | 2     | dev-senior-a + data-engineer  | impl + review  |
| "new JWT authentication system"                       | 3     | everyone                      | /spec → /build |
| "fix the VAT calculation bug"                         | 2     | dev-senior-a + dev-senior-b   | impl + review  |
| "migrate PostgreSQL to UUIDs"                         | 3     | data-engineer + everyone      | /spec → /build |
| "update the Dockerfile from Node 18→20"               | 1     | devops-engineer               | direct         |
| "multi-wallet checkout with MetaMask + WalletConnect" | 3     | frontend + backend + security | /spec → /build |
