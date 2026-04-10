---
name: task
description: >
  Universal Web3 entry point. Describe your task in natural language. The orchestrator first checks
  whether it touches contracts (= automatic level 3), then analyzes complexity and spawns the right
  agents.
argument-hint: '[free-form task description]'
---

# /task (Web3)

Update `tasks/current_task.md`: status=ORCHESTRATING, task=$ARGUMENTS

---

## Step 1 — Orchestrator analyzes

```
You are orchestrator.
Load .claude/agents/orchestrator.md.
Load project-architecture.md, data-architecture.md, constants.md.
Load the ## Agent Team table from CLAUDE.md.

Task received: $ARGUMENTS

FIRST QUESTION: does this touch a contract or value?
If yes → immediate level 3, smart-contract-engineer mandatory.
Otherwise → analyze the domains and complexity.

Produce your execution plan.
```

Present the plan. **Gate**: _"Is this plan correct?"_

---

## Step 2 — Execution by level

### Level 1 — Direct (frontend/docs only)

```
You are [AGENT].
Task: $ARGUMENTS
Implement directly. Run the tests.
```

---

### Level 2 — Moderate (frontend + indexer)

**Owning agent → implements** **Reviewer agent → reviews in parallel or just after** Apply
`team--skill-refine` if needed.

---

### Level 3 — Contracts or complex (full flow)

```
Level 3 detected — smart-contract-engineer mandatory.
Launching: /spec → /implement → /review
```

Chain the formal flows automatically.

---

## Step 3 — Completion

Update `tasks/current_task.md`: status=IDLE

---

## Routing Examples

| Task                                                        | Level | Agents                              | Flow               |
| ----------------------------------------------------------- | ----- | ----------------------------------- | ------------------ |
| "fix the Connect Wallet button styling"                     | 1     | frontend-engineer                   | direct             |
| "add a GraphQL query for deposits"                          | 2     | backend-engineer + reviewer         | impl + review      |
| "multi-wallet checkout: MetaMask + WalletConnect + Rainbow" | 2-3   | frontend + backend                  | impl/spec          |
| "new ERC-4626 vault"                                        | 3     | smart-contract-engineer + all       | /spec → /implement |
| "add fees on withdrawals"                                   | **3** | smart-contract-engineer + all       | /spec → /implement |
| "upgrade the UUPS proxy"                                    | **3** | smart-contract-engineer + architect | /spec → /implement |
| "update the subgraph for a new event"                       | 2     | backend-engineer + reviewer         | impl + review      |
| "fix the balance display shown in wei"                      | 1     | frontend-engineer                   | direct             |
