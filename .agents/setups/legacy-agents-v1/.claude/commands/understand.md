---
name: understand
description: >
  Map a legacy module before any change. legacy-analyst + archaeologist in parallel. Updates
  legacy-map.md. Mandatory before /characterize, /refactor, or /strangler on an unknown module.
argument-hint: '[module or file to map]'
---

# /understand

Update `tasks/current_task.md`: status=UNDERSTAND, module=$ARGUMENTS

**Golden rule**: we do not touch what we have not mapped.

---

## Phase 1 — Spawn legacy-analyst and archaeologist in parallel

The two agents work simultaneously on different angles.

**legacy-analyst prompt:**

```
You are legacy-analyst.
Load .claude/agents/legacy-analyst.md.
Load project-architecture.md, legacy-map.md.
Load legacy-patterns, technical-debt skills.

Map this module: $ARGUMENTS

Explore in this order:
1. git blame — who touched it, when, how many times
2. File size and structure
3. All incoming dependencies (who calls this module)
4. All outgoing dependencies (what this module calls)
5. Existing tests (yes/no/partial)
6. Identify available seams
7. Estimate the risk level

Produce a complete module card in legacy-map.md format.
Identify dangerous couplings and risk zones.
```

**archaeologist prompt:**

```
You are archaeologist.
Load .claude/agents/archaeologist.md.
Load project-architecture.md, legacy-map.md.
Load legacy-patterns, team--skill-lookup skills.

Understand the history of this module: $ARGUMENTS

Explore:
1. git log --follow -p — evolution over time
2. git log --grep="fix\|hotfix\|hack\|quick" — emergency patches
3. Comments and TODO in the code — inherited decisions
4. Implicit business rules in the code
5. Identifiable workarounds (hacks that became permanent)
6. Odd decisions with probable reason

Produce the archaeology report in archaeologist format.
```

---

## Phase 2 — Synthesis

Collect both reports. Build a unified view:

```markdown
# Mapping: $ARGUMENTS

## Executive Summary

[3-5 sentences: what the module does, its state, overall risk]

## Module Card (for legacy-map.md)

[complete card in legacy-map.md format]

## History (Archaeology)

[archaeologist findings]

## Risk Zones

Red [description] — [why dangerous] Yellow [description] — [caution]

## Available Seams

- [seam 1]: [how to exploit it]
- [seam 2]: [how to exploit it]

## Recommendation

- [ ] Ready for /characterize (seams available)
- [ ] Seams to create first (Sprout/Wrap method)
- [ ] Too risky — discuss with tech-lead before touching
```

---

## Phase 3 — Update legacy-map.md

Add the module card to `.claude/legacy-map.md`. Update the "Unexplored Zones" section (remove this
module). Update `last-verified` in `legacy-map.md`.

Update `tasks/current_task.md`: status=IDLE

```
Mapping complete: $ARGUMENTS
Risk level: green / yellow / red
Available seams: [N]
Existing tests: yes/no/partial
Ready for: /characterize $ARGUMENTS
```
