# Audit Code Command – Code Quality and Security Analysis

When `/audit-code [target]` is invoked, analyze code quality, security, and adherence to project
standards.

**Skills used:** `security-review` (security checklist), `code-audit` (quality and architecture
checklist).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read `README.md`, progress docs, architecture docs
4. Determine audit scope:
   - No target: audit entire codebase
   - Target provided: audit specific files/directories (e.g. `src/screens/`)

---

## Step 2: Security Audit

Run the **`security-review` skill** checklist against the target scope:

1. Secrets and credentials
2. Network and external calls
3. Dependencies
4. Data handling
5. File system and permissions

If any critical security issue is found: **stop and alert immediately**.

---

## Step 3: Code Quality Audit

Run the **`code-audit` skill** checklist against the target scope:

1. Patterns and style
2. Dead code and clutter
3. Common bugs (race conditions, missing awaits, memory leaks)
4. Architecture adherence
5. Database patterns (if applicable)
6. External data handling (if applicable)
7. Documentation completeness

---

## Step 4: Generate Report

Compile findings using the report format from the `code-audit` skill:

1. **Critical** -- Security vulnerabilities, data loss risks
2. **High** -- Bugs, performance issues, architecture violations
3. **Medium** -- Code quality issues, technical debt
4. **Low** -- Style issues, minor improvements
5. **Positive** -- Good patterns worth noting

For each finding: file path, description, severity, suggested fix.

---

## Step 5: Present Results

1. Display the report, critical and high items first
2. Provide actionable recommendations with priority order
3. If critical security issues exist, emphasize they must be fixed before merge

---

## Step 6: Optional -- Auto-Fix Safe Issues

If requested by the user:

1. Fix low-priority style issues (formatting, unused imports)
2. Fix simple code quality issues (dead code, obvious bugs)
3. **Never auto-fix**: security issues, architecture changes, logic changes

---

## Step 7: Commit & Push (If Changes Made)

If auto-fixes were applied:

```bash
git add -A
git commit -m "fix: apply code audit fixes"
git push origin $(git branch --show-current)
```

---

## Cursor Behavior Rules

- Security is non-negotiable -- always prioritize security findings
- Verify all findings by reading the code (don't guess)
- Use `security-review` skill for security, `code-audit` skill for quality
- Every audit produces a structured report
- Stop and alert on critical issues

---

## Usage

- `/audit-code` -- Audit entire codebase
- `/audit-code src/screens/` -- Audit screen components
- `/audit-code src/db/` -- Audit database layer
- `/audit-code security` -- Focus on security audit only
