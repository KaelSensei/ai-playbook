# Audit Code Command – Code Quality and Security Analysis

When `/audit-code [target]` is invoked, immediately execute the following steps to analyze code
quality, security, and adherence to project standards.

---

## Step 1: Load Project Context

1. Assume the project root as the working directory
2. **Load and strictly follow ALL Cursor rules** from `.cursor/rules/*.mdc`:
   - `security.mdc` - Security requirements
   - `technical-stack.mdc` - Technical stack patterns
   - `documentation.mdc` - Documentation update requirements
   - `version-management.mdc` - Git commit/push workflow
3. Read relevant documentation:
   - `README.md`
   - Project progress documentation (e.g., `PROGRESS.md`, `CHANGELOG.md`)
   - Architecture documents
   - Security guidelines
4. Identify the current Git branch
5. Determine the audit scope:
   - If no target specified: audit entire codebase
   - If target specified: audit specific files/directories (e.g., `src/screens/`, `src/db/`)

---

## Step 2: Understand the Audit Scope

1. Parse the target provided after `/audit-code` (if any)
2. Determine audit focus:
   - **Security**: Check for vulnerabilities, unsafe patterns, backdoors
   - **Code Quality**: Check for bugs, anti-patterns, technical debt
   - **Architecture**: Check adherence to project patterns
   - **Performance**: Check for performance issues
   - **Documentation**: Check for missing or outdated docs
3. Identify files to analyze:
   - TypeScript/JavaScript files
   - Database schemas and queries
   - Configuration files
   - Test files (if applicable)

---

## Step 3: Security Audit (Mandatory)

1. **Check for security vulnerabilities**:
   - SQL injection risks in database queries
   - Unsafe external API calls (respect project-defined allowed domains)
   - File system access issues
   - Prototype pollution vectors
   - Unsafe object merging
   - Dynamic code execution (`eval`, `Function`, dynamic imports)
   - Hidden logic or obfuscated code

2. **Verify allowed domains**:
   - Only project-defined allowed domains should be called
   - No unknown or undocumented endpoints
   - No background tracking or telemetry

3. **Check data handling**:
   - Local data storage is single source of truth (when applicable, no unauthorized remote sync)
   - Local file caching is secure
   - No sensitive data leakage
   - Input validation and sanitization

4. **Review dependencies**:
   - Check for known vulnerabilities
   - Verify all dependencies are necessary and well-known
   - No suspicious packages

---

## Step 4: Code Quality Audit

1. **Check code patterns**:
   - Follows project-specific best practices
   - Uses TypeScript properly (no excessive `any` types) if applicable
   - Follows project's coding style
   - Proper error handling
   - No magic numbers or hardcoded values

2. **Check architecture adherence**:
   - Separation of concerns (UI, data layer, external sources, etc.)
   - Project-specific architectural constraints maintained
   - Data storage remains single source of truth (when applicable)
   - No shortcuts or hacks introduced

3. **Check for common issues**:
   - Unused imports or variables
   - Dead code
   - Inconsistent naming
   - Missing error handling
   - Race conditions
   - Memory leaks (platform-specific considerations)

4. **Check database patterns**:
   - Proper use of transactions
   - Indexes for performance-critical queries
   - No SQL injection risks
   - Proper migration handling

---

## Step 5: Technical Stack Compliance

1. **Framework/Platform patterns** (project-specific):
   - Follows project-specific best practices
   - Proper use of framework features
   - Proper cleanup and resource management
   - No unnecessary re-renders or performance issues

2. **TypeScript/JavaScript usage**:
   - Proper type definitions (if TypeScript)
   - No `any` types unless absolutely necessary (if TypeScript)
   - Type safety maintained (if TypeScript)

3. **Database usage** (if applicable):
   - Proper transaction handling
   - Error handling for database operations
   - Proper schema migrations

4. **External data sources** (if applicable):
   - Handles unreliable data gracefully
   - Validates and normalizes external data
   - Proper error handling for network failures

---

## Step 6: Documentation Audit

1. **Check documentation completeness**:
   - Code comments for complex logic
   - Function/class documentation
   - Architecture documentation up to date
   - Progress documentation reflects current state
   - `CHANGELOG.md` is maintained (if present)

2. **Verify documentation accuracy**:
   - Code matches documentation
   - No outdated information
   - Examples are correct

---

## Step 7: Generate Audit Report

1. Compile findings into a structured report:
   - **Critical Issues**: Security vulnerabilities, data loss risks
   - **High Priority**: Bugs, performance issues, architecture violations
   - **Medium Priority**: Code quality issues, technical debt
   - **Low Priority**: Style issues, minor improvements
   - **Positive Findings**: Good patterns, well-implemented features

2. For each finding, include:
   - File path and line number (if applicable)
   - Description of the issue
   - Severity level
   - Suggested fix (if applicable)
   - Reference to relevant rule or standard

3. Format the report clearly with:
   - Summary statistics
   - Detailed findings
   - Recommendations
   - Priority order for fixes

---

## Step 8: Present Audit Results

1. Display the audit report to the user
2. Highlight critical and high-priority issues first
3. Provide actionable recommendations
4. If critical security issues are found:
   - **Stop and alert immediately**
   - Do not proceed with other tasks until resolved
   - Provide clear remediation steps

---

## Step 9: Optional - Auto-Fix Safe Issues

If explicitly requested and issues are safe to auto-fix:

1. Fix low-priority style issues (formatting, unused imports)
2. Fix simple code quality issues (dead code, obvious bugs)
3. **Never auto-fix**:
   - Security issues
   - Architecture changes
   - Logic changes
   - Database schema changes

---

## Step 10: Commit & Push (If Changes Made)

If any auto-fixes were applied:

```bash
git add .
git commit -m "fix: apply code audit fixes"
git push origin $(git branch --show-current)
```

- Never push directly to `main` or `master`
- Always push to the current branch
- Only commit if safe auto-fixes were applied

---

## Cursor Behavior Rules

- **Security is non-negotiable** - Always prioritize security findings
- Do not guess - verify all findings by reading the code
- Be thorough but efficient
- If critical issues are found, **stop and alert immediately**
- Provide actionable, prioritized recommendations
- Every audit should result in a clear, structured report

---

## Usage

Use `/audit-code [target]` to:

- Analyze code quality and security
- Identify bugs and vulnerabilities
- Check adherence to project standards
- Generate actionable improvement recommendations
- Audit specific files or directories

**Examples:**

- `/audit-code` - Audit entire codebase
- `/audit-code src/screens/` - Audit only screen components
- `/audit-code src/db/` - Audit database layer
- `/audit-code security` - Focus on security audit only

---

## Audit Checklist

When performing an audit, check:

### Security

- [ ] No SQL injection risks
- [ ] Only allowed domains are called (project-defined)
- [ ] No unsafe code execution
- [ ] Proper input validation
- [ ] No sensitive data leakage
- [ ] Secure file system access
- [ ] No hidden or obfuscated logic

### Code Quality

- [ ] Follows project-specific patterns
- [ ] Proper TypeScript usage
- [ ] No anti-patterns
- [ ] Proper error handling
- [ ] No memory leaks
- [ ] Proper cleanup in effects

### Architecture

- [ ] Separation of concerns
- [ ] Project-specific architectural constraints maintained
- [ ] Data storage as single source of truth (when applicable)
- [ ] No shortcuts or hacks

### Documentation

- [ ] Code is documented
- [ ] Architecture docs up to date
- [ ] Progress documentation current
- [ ] CHANGELOG.md maintained
