---
name: team--skill-lookup
description: >
  Codebase exploration and context lookup protocol. Loaded during /research and the EXPLORE phase of
  /spec. Defines how agents check context doc staleness, explore the codebase systematically, and
  use web search effectively for Web3 domain knowledge.
---

# Team Lookup Protocol

## Context Doc Staleness Check

Every agent MUST check `last-verified` before reasoning from any context doc.

```
today - last-verified <= 30 days → FRESH → trust the doc
today - last-verified >  30 days → STALE → explore codebase to verify
```

If a doc is stale:

1. State it explicitly: _"project-architecture.md is STALE (last-verified: [date])"_
2. Explore the codebase directly for the relevant parts
3. Flag discrepancies between doc and reality to the orchestrator
4. Do NOT silently update the doc — flag it, do not fix it mid-task

## Codebase Exploration Order

For Solidity/Web3 projects, explore in this order:

```
1. contracts/src/ or src/    → main contracts, entry points
2. test/                     → understand expected behavior from tests
3. script/                   → understand deployment and upgrade flow
4. foundry.toml              → toolchain config, solc version, optimizer
5. package.json              → frontend/indexer deps and versions
6. .env.example              → required environment variables
7. .claude/                  → context docs, agent team, skills
```

## Web Search for Web3 Domain Knowledge

Use web search for external knowledge not covered by loaded skills:

**Good uses:**

- Protocol documentation (Uniswap, Aave, Compound, Chainlink, OpenZeppelin)
- EIP specifications — `eips.ethereum.org/EIPS/eip-[N]`
- Known exploit post-mortems — `rekt.news`, `blog.openzeppelin.com`
- Audit findings — `code4rena.com`, `sherlock.xyz/audits`
- Library source and changelogs

**Effective query patterns:**

```
"[protocol] documentation [feature name]"
"EIP-[number] specification"
"[vulnerability class] solidity attack example"
"[protocol name] hack post-mortem"
"[library] [function] [version] changelog"
```

**Do NOT use web search for:**

- Anything covered by loaded domain skills
- Implementation details already visible in the codebase
- Questions answerable from fresh context docs

## Exploration Output Format

After exploring, produce a structured findings note:

```markdown
# Exploration: [topic or feature]

## Context Docs Status

- project-architecture.md: FRESH (last-verified: YYYY-MM-DD) / STALE
- data-architecture.md: FRESH / STALE
- constants.md: FRESH / STALE

## Codebase Findings

[key files explored, patterns observed, relevant code snippets]

## External Research

[URLs consulted, key facts extracted — paraphrased, not quoted]

## Discrepancies Found

[anything that contradicts the context docs, with file + line reference]

## Answer to Exploration Task

[direct, structured answer to what was being looked up]

## Open Questions

[what couldn't be answered — needs user clarification or more exploration]
```

## Efficiency Rules

- Read the test file for a contract before reading the contract itself (tests express intent;
  implementation expresses mechanism)
- Stop exploring when you have enough to answer the question (don't read the entire codebase for a
  targeted lookup)
- One web search per distinct external concept — don't repeat
- If a context doc is fresh and directly answers the question → trust it, stop
