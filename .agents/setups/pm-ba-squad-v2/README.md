# PM-BA Squad — Multi-Agent Setup

Multi-agent setup for product specification: BDD user stories, business rules, acceptance criteria,
and backlog refinement.

> **Compatibility:** Claude Code first. Cursor can read a reduced version of this setup, but native
> multi-agent orchestration does not carry over 1:1. See
> [`../../docs/AGENTS_COMPATIBILITY.md`](../../docs/AGENTS_COMPATIBILITY.md).

This setup is a **workflow bundle**. It installs personas, commands, and setup-local skills for one
team pattern. It does not replace the base playbook catalog in `.agents/rules/`,
`.agents/commands/`, and `.agents/skills/`.

## Agents

| Agent              | Role                                                             |
| ------------------ | ---------------------------------------------------------------- |
| `product-owner`    | Translates needs into actionable stories, prioritises, validates |
| `business-analyst` | Analyses business rules, writes complete specs                   |
| `spec-reviewer`    | Validates completeness and actionability before dev              |

## Install

```bash
cd your-project/

# For Claude Code (default)
bash /path/to/pm-ba-squad-v2/install.sh

# For Cursor
bash /path/to/pm-ba-squad-v2/install.sh .cursor

# Then fill in constants.md with personas and project context
```

## Workflow

```
1. /story [raw need]     → PO analyses and clarifies, BA enriches ACs
2. /spec [slug]          → BA writes complete spec, Reviewer validates
3. /review-spec [file]   → Independent review if needed
```

## Bundled Setup-Local Skills

These skills belong to this setup bundle. They are separate from the shared base playbook skills in
`.agents/skills/`.

| Skill                 | Content                                                            |
| --------------------- | ------------------------------------------------------------------ |
| `bdd-gherkin`         | Given/When/Then, Scenario Outline, Background, Rule, anti-patterns |
| `spec-writing`        | Spec anatomy, numbered business rules, edge cases, anti-patterns   |
| `acceptance-criteria` | AC formats, quality levels, examples by feature type               |
| `domain-language`     | Ubiquitous language, glossary, vocabulary extraction               |
| `refinement-process`  | DoR criteria, session facilitation, story splitting, estimation    |
