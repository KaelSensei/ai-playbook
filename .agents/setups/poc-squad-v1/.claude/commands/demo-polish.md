---
name: demo-polish
description: >
  Make an existing POC presentable for a live demo without expanding its scope. Better names, a
  short README, dead-code removal, one screenshot or GIF hint. No new features. No tests. No
  refactors.
---

# /demo-polish

You are `prototyper`. Load the `clean-code` skill.

This runs **after** `/poc` has already produced a working thing. The goal is to make that thing
demoable — readable, runnable by someone else, nice enough to show a stakeholder.

## What you DO

1. **Names.** Walk the code and upgrade vague identifiers (`x`, `data`, `temp`) to ones that
   describe intent. Apply the `clean-code` naming rules.
2. **README.** Create or update a one-page `README.md` with: what it is (one sentence), how to run
   it (one command), and a list of what is deliberately missing ("no auth", "local JSON storage
   only"). Keep it under 40 lines.
3. **Dead code.** Remove commented-out blocks, unused imports, stub functions the prototyper left
   behind.
4. **Consistent formatting.** Run the project's formatter if one exists (`prettier`, `black`,
   `gofmt`). Do not install one if none is configured.
5. **Entry point.** Confirm the single command from the `/poc` summary still works. If it no longer
   does, fix it and say so.
6. **Demo aid (optional).** If the POC is visual, add a `demo.md` with one screenshot path or a
   three-step GIF capture script. Skip this if the POC is a CLI or library.

## What you DO NOT do

- **No new features.** If the user wants a feature, that is a separate `/poc` run.
- **No tests.** Polish is not "retrofit correctness".
- **No architectural refactors.** Do not split the one file into three files because it feels "more
  professional". It is a POC.
- **No dependency additions.** No `npm install prettier` to "help with formatting". Use what is
  already there or skip that step.
- **No CI, Dockerfile, or deploy config.** Those live in a real setup.

## Output

Commit as `chore(poc): polish for demo`. Print:

```
demo-polish — READY
readme:   README.md
entry:    <the single run command>
files:    <short list>
notes:    <one line — anything the human should know before the demo>
```

If the POC has grown beyond "throwaway" territory (tests appearing, auth logic, multiple modules),
say so explicitly and recommend graduating to `dev-squad-v2` or another full setup.
