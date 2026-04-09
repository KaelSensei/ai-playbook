---
name: research
description: >
  2 specialist agents research in parallel with web access. Findings merged into a single report.
  Use for "how does X work", protocol investigation, attack surface research, or any deep-dive
  before writing a spec.
argument-hint: '[topic to research]'
---

# /research

Update `tasks/current_task.md`: status=RESEARCH, task=$ARGUMENTS

---

## Step 1 — Resolve agent pair

Read the `## Agent Team` table in `CLAUDE.md`. Select the 2 agents most relevant to the topic.

Default pairs by topic type: | Topic | Agent A | Agent B | |---|---|---| | Security / vulnerability
| smart-contract-engineer | architect | | DeFi mechanics | smart-contract-engineer |
backend-engineer | | Frontend + contracts | frontend-engineer | smart-contract-engineer | |
Infrastructure | infra-engineer | devops-engineer | | Data / indexing | backend-engineer |
smart-contract-engineer | | New protocol design | architect | spec-writer | | Rust / Solana |
rust-reviewer | architect |

---

## Step 2 — Spawn both agents in parallel

Send both agents their prompts simultaneously. Do not wait for one before sending the other.

**Prompt template for each agent:**

```
You are [AGENT_PERSONA].
Load your persona from .claude/agents/[agent].md.
Load context docs: project-architecture.md, data-architecture.md.
Load team--skill-lookup skill.
Load [agent's domain skills from Agent Team table].

Check staleness of all context docs per team--skill-lookup protocol.

Research task: $ARGUMENTS

Go deep on your discipline's angle. You have web access — use it for:
- External protocol documentation and EIP specs
- Known exploit post-mortems and audit findings
- Reference implementations

Produce a structured research report:

## Findings
[key facts, data, patterns — specific and citable]

## Domain-Specific Concerns
[what your discipline notices that a generalist would miss]

## Relevant Code / References
[specific files in codebase, or external URLs, that are relevant]

## Open Questions
[what you couldn't determine — needs more investigation or user clarification]
```

---

## Step 3 — Merge findings

After both agents return, synthesize into a single report:

```markdown
# Research: $ARGUMENTS

Date: [today]

## Summary

[3-5 sentences: what we learned, key decision points, recommended next step]

## Findings: [Agent A discipline]

[agent A output — key facts, condensed, no duplication with agent B]

## Findings: [Agent B discipline]

[agent B output — key facts, condensed]

## Conflicts & Open Questions

[where agents disagreed or couldn't answer — explicit, not papered over]

## Recommended Next Step

- [ ] Write spec → `/spec [description]`
- [ ] Proof of concept → `/implement [description]`
- [ ] More research needed on: [topic]
```

Update `tasks/current_task.md`: status=IDLE
