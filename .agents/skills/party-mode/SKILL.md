---
name: party-mode
description:
  Multi-agent roundtable for architecture decisions, brainstorming, and design reviews. Spawns 2-4
  agents in parallel for diverse perspectives. Use when a decision benefits from multiple
  viewpoints.
---

# Party Mode Skill — Multi-Agent Roundtable

A methodology for spawning multiple AI agents with distinct perspectives to debate, review, or
brainstorm a topic. Each agent operates independently with its own thinking — responses are
presented unfiltered, not blended. Inspired by BMAD-METHOD's Party Mode pattern.

## When to use this skill

- When making architecture decisions that affect multiple layers.
- When brainstorming where diverse perspectives add value.
- When reviewing a design where blind spots are likely.
- When the user asks for "multiple opinions" or "a second opinion."
- When referenced by `/brainstorm`, `/spec`, or `/review-pr`.

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`party-mode` skill."

- **Automatic:** The AI loads this skill when multiple perspectives would improve a decision.
- **Referenced by:** `/brainstorm --party`, `/spec`, `/review-pr`

---

## Core Concept

Instead of one AI giving one answer, spawn 2-4 agents as **independent subagents**, each with a
distinct role and perspective. The orchestrator presents all responses without synthesizing or
blending them — the user (or a designated arbitrator) decides.

## Agent Selection

Pick 2-4 agents based on the topic. Each agent must bring a **different perspective**, not just a
different name.

### Built-in Perspectives

| Perspective           | Focus                                                         | Good for                          |
| --------------------- | ------------------------------------------------------------- | --------------------------------- |
| **The Pragmatist**    | Simplest working solution, shipping speed, maintenance cost   | Architecture, feature scoping     |
| **The Skeptic**       | What can go wrong, edge cases, failure modes, security        | Design review, risk assessment    |
| **The User Advocate** | User experience, accessibility, real-world usage patterns     | UI/UX decisions, feature design   |
| **The Architect**     | Long-term maintainability, patterns, scalability, consistency | Architecture, tech debt decisions |
| **The Optimizer**     | Performance, efficiency, resource usage, bottlenecks          | Performance decisions, scaling    |
| **The Newcomer**      | Fresh eyes, "why is it done this way?", simplification        | Code review, onboarding, docs     |

### From project setups

If the project uses a multi-agent setup (e.g., `dev-squad-v2`, `pm-ba-squad-v2`), agents from those
setups can participate with their defined personas and skills.

## Orchestration Protocol

### Step 1: Frame the question

The orchestrator (the main AI) formulates a clear, specific question for the roundtable:

```
ROUNDTABLE QUESTION:
<specific question or decision to be made>

CONTEXT:
<relevant background — tech stack, constraints, current approach>

AGENTS SELECTED:
- Agent 1: <name> — <perspective>
- Agent 2: <name> — <perspective>
- Agent 3: <name> — <perspective>
```

### Step 2: Spawn agents in parallel

Each agent receives:

- The roundtable question and context
- Their assigned perspective (role description)
- Instruction to give their honest assessment from that perspective
- Instruction to be specific and concise (under 300 words)

**Critical rules:**

- Spawn agents **in parallel** (not sequentially) for genuine independence.
- Each agent must form its own opinion **before** seeing other agents' responses.
- Never synthesize or blend responses — present them as-is.

### Step 3: Present responses

Format each agent's response clearly:

```markdown
## Roundtable: <question>

### 🔧 The Pragmatist

<response>

### 🔍 The Skeptic

<response>

### 👤 The User Advocate

<response>
```

### Step 4: Identify consensus and conflicts

After presenting all responses, the orchestrator (not an agent) summarizes:

```markdown
## Summary

**Consensus:** <what all agents agree on> **Conflicts:** <where agents disagree and why>
**Recommendation:** <orchestrator's synthesis, or "needs human decision">
```

## Solo Fallback Mode

If the environment doesn't support parallel agent spawning (e.g., Cursor), the orchestrator
roleplays each perspective sequentially. The key rule: **think from each perspective independently**
before comparing.

1. Write Agent 1's perspective completely.
2. Write Agent 2's perspective completely (without revising Agent 1).
3. Write Agent 3's perspective completely (without revising earlier ones).
4. Then summarize consensus/conflicts.

## Context Management

For longer roundtable sessions:

- Keep each agent's response under 300 words.
- After 3+ rounds, create a rolling summary (under 400 words) to replace earlier context.
- Focus on unresolved disagreements, not settled points.

## When NOT to Use Party Mode

- For simple, well-understood decisions (use direct reasoning instead).
- When there's only one viable approach (don't manufacture disagreement).
- For implementation details (party mode is for design decisions, not coding).
- When the user wants speed over thoroughness.

## Anti-patterns

- **Artificial consensus** — Agents should genuinely disagree when their perspectives conflict.
- **Blended responses** — Never synthesize agent outputs into a single voice. Present them
  separately.
- **Too many agents** — 2-4 is the sweet spot. More adds noise, not signal.
- **Vague questions** — "What do you think about this feature?" is too broad. "Should we use
  WebSockets or polling for real-time updates, given our constraint of X?" is specific.
- **Ignoring conflicts** — Disagreements are the most valuable output. Don't smooth them over.
