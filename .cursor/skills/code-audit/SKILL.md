---
name: code-audit
description:
  Code quality and architecture checklist for auditing a codebase. Use when running /audit-code or
  reviewing code for quality issues.
---

# Code Audit Checklist

Structured checklist for evaluating code quality, architecture adherence, and documentation
completeness. For security-specific checks, see the `security-review` skill.

## When to use this skill

- When running `/audit-code`.
- When reviewing a PR for code quality (not just security).
- When the user asks "is this code clean?" or "what should I improve?"

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`code-audit` skill."

- **Automatic:** The AI loads this skill when auditing code or reviewing a PR.
- **Referenced by:** `/audit-code` -- the command delegates the quality checklist to this skill (and
  uses `security-review` for security checks).

## Code quality checks

### Patterns and style

- [ ] Follows project coding conventions (from `technical-stack.mdc`).
- [ ] No excessive `any` types (TypeScript) -- use proper types/interfaces.
- [ ] Consistent naming (variables, functions, files).
- [ ] No magic numbers or hardcoded strings -- use constants.
- [ ] Proper error handling (try/catch, error boundaries, fallback UI).

### Dead code and clutter

- [ ] No unused imports or variables.
- [ ] No commented-out code blocks left behind.
- [ ] No unreachable code paths.
- [ ] No debug logs (`console.log`, `print`, `debugger`) in production code.

### Common bugs

- [ ] No race conditions in async code.
- [ ] No missing `await` on promises.
- [ ] No memory leaks (event listeners not cleaned up, subscriptions not cancelled).
- [ ] No off-by-one errors in loops or array access.
- [ ] Proper null/undefined checks before property access.

## Architecture checks

- [ ] Separation of concerns (UI, data layer, business logic, external sources).
- [ ] Project architectural constraints are maintained (from `technical-stack.mdc`).
- [ ] Data storage remains single source of truth where applicable.
- [ ] No shortcuts, hacks, or "temporary" workarounds without a TODO.
- [ ] New code follows existing patterns (don't introduce a second way to do the same thing).

### Database (if applicable)

- [ ] Queries use parameterized statements (no string concatenation).
- [ ] Indexes exist for performance-critical queries.
- [ ] Transactions used where atomicity is needed.
- [ ] Migrations handle both up and down.

### External data (if applicable)

- [ ] External/scraped data treated as untrusted.
- [ ] Input validated and normalized before storage.
- [ ] Network failures handled gracefully (retry, fallback, offline).

## Documentation checks

- [ ] Complex logic has inline comments explaining **why**.
- [ ] Public functions/classes have doc comments.
- [ ] Architecture docs match current code structure.
- [ ] Progress/changelog docs reflect recent changes.
- [ ] README is accurate (build, run, test instructions).

## Report format

After running the checklist, group findings by severity:

1. **Critical** -- Security vulnerabilities, data loss risks (use `security-review` skill).
2. **High** -- Bugs, performance issues, architecture violations.
3. **Medium** -- Code quality issues, technical debt.
4. **Low** -- Style issues, minor improvements.
5. **Positive** -- Good patterns worth noting.

For each finding include: file path, description, severity, and suggested fix.
