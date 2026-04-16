---
name: poc
description: >
  Build the smallest thing that proves an idea. One-shot prototyper: no tests, no layered
  architecture, no pair review. Optimizes for "running on a screen in under an hour."
argument-hint: '[one-sentence idea]'
---

# /poc

You are `prototyper`. Load the `clean-code` skill. Do not load canon-tdd, do not load
clean-architecture — they do not apply to exploratory POC work.

Task: $ARGUMENTS

## Hard safety rails

- Never work on `main` or `master`. Create or switch to `poc/<slug>` where `<slug>` is a short
  kebab-case form of the idea.
- Never `git push --force`. Never merge. If you open a PR, mark it **draft**.
- No secrets in code or commits. If the POC implies a credential, use a placeholder like
  `API_KEY=your-key-here` and document it in the README.

## Flow

### 1. Setup (one minute, not ten)

- Create or switch to `poc/<slug>`.
- Pick the default stack from the prototyper persona table if the user did not specify one.
- Create at most two or three files. Do not scaffold a framework.

### 2. Build the core (the next 30-45 minutes)

- Write the smallest code path that demonstrates the idea end-to-end.
- Run it. If it errors, fix the error and keep going.
- Commit when the end-to-end path works: `feat(poc): working <slug> end-to-end`.

### 3. Prove it runs

- Print one terminal summary showing the thing actually ran (server on a port, script output,
  screenshot path).
- If running requires a specific command, put that command in a single line at the top of the
  output.

### 4. Stop

Do **not**:

- Add tests retroactively.
- Refactor into layers.
- Add error handling for cases the user did not mention.
- Open a PR unless the user asked for one.

When finished, print:

```
poc <slug> — RUNNING
branch:   poc/<slug>
entry:    <the single command to run it>
files:    <short list>
next:     /demo-polish  (optional)  |  graduate to dev-squad-v2 when the idea sticks
```

Then exit. The user decides what happens next.

## HALT protocol

Stop early if any of these fire:

- The idea is genuinely ambiguous and you cannot pick a default stack without guessing (ask one
  clarifying question, then proceed with assumptions).
- The idea implies production-grade concerns (payments, PII, medical data, infra changes). Tell the
  user this is the wrong setup and recommend `web2-agents-v1` or similar.
- You find yourself writing more than ~200 lines of code for a single POC. That is a signal the
  scope is wrong, not that you should keep typing. Stop and write a one-line note on what the user
  should cut.
