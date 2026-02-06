# Magic Wand Command – Deep Expert-Level Problem Solving

When `/magic-wand [issue description]` is invoked, perform comprehensive root-cause analysis and fix
a persistent issue that standard debugging has not resolved.

**Skills used:** `debugging-methodology` (root-cause analysis steps and common root causes),
`security-review` (if security is suspected).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read `README.md`, progress docs, architecture docs
4. Check current git status and branch
5. Review conversation history if available

---

## Step 2: Understand the Issue

1. Parse the issue description from `/magic-wand`
2. Clarify: What should happen vs. what actually happens?
3. Note prior fix attempts and why they failed
4. Set expert mindset: think root causes, not symptoms

---

## Step 3: Deep Investigation

Follow the **`debugging-methodology` skill** systematically:

1. **Gather evidence** -- exact symptom, reproduction steps, timeline.
2. **Review recent history** -- `git log --oneline -30`; look for config changes, dependency
   updates, refactors.
3. **Widen the search** -- check config files, state management, navigation, database, middleware
   (not just the reported file).
4. **Trace execution end-to-end** -- read ALL related files completely, follow data flow, verify
   async operations.
5. **Check common root causes** from the skill (configuration, state, async/timing, navigation,
   database).

---

## Step 4: Identify Root Cause

1. Determine the ACTUAL root cause (not the symptom)
2. Document reasoning:
   - What is wrong and why
   - Why previous fixes missed it
   - Which files are affected
3. Verify the root cause explains all observed behavior

---

## Step 5: Implement Fix

1. Fix the root cause in all affected files
2. Update configuration if needed
3. Add defensive checks where appropriate
4. Do not patch symptoms -- fix the real problem

---

## Step 6: Validate

1. Trace through execution to confirm the fix
2. Check for regressions and edge cases
3. Verify related functionality is unaffected

---

## Step 7: Document and Update Docs

1. Explain: root cause, why previous fixes failed, what was changed
2. Update progress docs and troubleshooting docs if applicable

---

## Step 8: Commit & Push

```bash
git add -A
git commit -m "fix: [root cause description] - deep investigation"
git push origin $(git branch --show-current)
```

---

## Cursor Behavior Rules

- **Thoroughness over speed** -- this command is for persistent issues
- Search the entire codebase, not just the reported file
- Check configuration -- often the real issue is in config, not code
- Document reasoning so future debugging is easier
- Higher token usage is acceptable for deep analysis
- Consult `debugging-methodology` skill for systematic steps

---

## Usage

- `/magic-wand user profile not refreshing` -- Deep analysis of refresh issue
- `/magic-wand images not loading` -- Comprehensive image loading investigation
- `/magic-wand app crashes on startup` -- System-wide startup analysis

## Magic Wand vs. Standard Fix

| Standard `/fix`              | `/magic-wand`                       |
| ---------------------------- | ----------------------------------- |
| Quick fix for obvious issues | Deep analysis for persistent issues |
| Focuses on reported file     | Searches entire codebase            |
| Fixes symptoms               | Fixes root causes                   |
| Fast iteration               | Thorough investigation              |
