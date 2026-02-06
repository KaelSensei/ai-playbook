---
name: security-review
description:
  Checklist and reasoning for security review before merge. Use when reviewing a PR, auditing code,
  or before merging a branch.
---

# Security Review Skill

A structured checklist for reviewing code changes from a security perspective.

## When to use this skill

- Before merging any branch into `dev` or `main`.
- When running `/audit-code` or `/review`.
- When the user asks "is this safe to merge?"

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`security-review` skill."

- **Automatic:** The AI loads this skill before any merge or when security concerns arise.
- **Referenced by:** `/merge-branch-into-main`, `/audit-code`, `/feature`, `/fix`, `/refactor` --
  these commands include a security validation step that uses this skill's checklist.

## Checklist

### 1. Secrets and credentials

- [ ] No API keys, tokens, passwords, or private keys in the diff.
- [ ] `.env`, `credentials.json`, `keystore.properties` are in `.gitignore`.
- [ ] No hardcoded secrets in code or config files.

### 2. Network and external calls

- [ ] No new HTTP/fetch calls to undocumented or untrusted domains.
- [ ] Allowed domains are documented (e.g. in `security.mdc` or README).
- [ ] No new `eval()`, `Function()`, or dynamic code execution.
- [ ] No `dangerouslySetInnerHTML` (or equivalent) without sanitization.

### 3. Dependencies

- [ ] No new dependencies added without justification.
- [ ] No known vulnerabilities in new deps (`npm audit`, `pip audit`, etc.).
- [ ] No post-install scripts that run arbitrary code.
- [ ] Prefer well-known, minimal libraries over obscure ones.

### 4. Data handling

- [ ] All user input is validated and sanitized before use.
- [ ] SQL queries use parameterized statements (no string concatenation).
- [ ] File paths are validated (no path traversal).
- [ ] External/scraped data is treated as untrusted.

### 5. File system and permissions

- [ ] No recursive deletes outside the app sandbox.
- [ ] No writes to arbitrary user-provided paths.
- [ ] File operations are scoped to the project directory.

### 6. Git and merge safety

- [ ] No force-push to shared branches (`dev`, `main`).
- [ ] Commit messages use conventional format.
- [ ] No unintended file deletions in the diff.

## How to use

1. Run through each section of the checklist.
2. For each item that **fails**: stop and report it with a clear explanation.
3. For items that **pass**: note them briefly.
4. Summarize: "Security review passed" or "Security review blocked: [reason]".

## When to block the merge

- Any secret in the diff → **block**.
- New untrusted network call → **block** (or require explicit approval).
- Known vulnerability in a new dependency → **block** until resolved.
- Unsafe dynamic execution → **block**.
