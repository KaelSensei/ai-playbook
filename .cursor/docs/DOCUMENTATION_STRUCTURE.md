# Recommended Documentation Structure

This document outlines suggested folders and markdown files to enhance AI comprehension and
development efficiency. Projects should adapt this structure to their specific needs.

## 📁 Suggested Folder Structure

```
.cursor/
├── commands/          # ✅ AI commands (see COMMANDS_STRUCTURE.md for subfolders: bootstrap/, git/, workflow/, etc.)
├── rules/             # ✅ AI rules (security, technical-stack, etc.)
└── docs/             # 🆕 NEW: Project-specific documentation
    ├── architecture/
    ├── components/
    ├── data-models/
    ├── patterns/
    ├── decisions/
    └── troubleshooting/
```

## 📄 Recommended Documentation Files

### 1. Architecture & Design (`docs/architecture/`)

#### `database-schema.md` (if applicable)

- **Purpose**: Detailed database schema documentation
- **Contents**:
  - Table structures with all columns
  - Indexes and their purposes
  - Foreign key relationships
  - Migration history
  - Query patterns and performance notes

#### `data-flow.md`

- **Purpose**: How data moves through the application
- **Contents**:
  - Data import pipeline (external sources → storage → UI)
  - Search/query flow (User input → Query → Results)
  - Caching strategies
  - Offline vs online states

#### `component-hierarchy.md` (for UI projects)

- **Purpose**: Component tree and relationships
- **Contents**:
  - Screen/components and their children
  - Shared components and where they're used
  - Navigation structure
  - State management patterns

### 2. Components (`docs/components/`)

#### `screens/` or `pages/` (for UI projects)

- Document each major screen/page component
- Include: Props, state, key functions, dependencies

#### `shared-components.md` (for UI projects)

- Reusable components
- Component props and usage examples
- Styling patterns

### 3. Data Models (`docs/data-models/`)

#### `external-apis.md`

- **Purpose**: External API structure and usage patterns
- **Contents**:
  - API endpoints used
  - Response structures
  - Authentication requirements
  - Error handling
  - Rate limiting considerations

#### `database-models.md` (if applicable)

- **Purpose**: Type definitions and database row types
- **Contents**:
  - Data structures
  - Type relationships
  - Validation rules
  - Default values

#### `data-sources.md`

- **Purpose**: External data source documentation
- **Contents**:
  - Data source patterns
  - Caching strategy
  - Fallback mechanisms
  - Data formats supported

### 4. Patterns & Conventions (`docs/patterns/`)

#### `code-patterns.md`

- **Purpose**: Common code patterns used in the project
- **Contents**:
  - How to add a new feature
  - How to add a new database query
  - How to add theme/styling support
  - Error handling patterns
  - Loading state patterns

#### `naming-conventions.md`

- **Purpose**: File, function, and variable naming
- **Contents**:
  - File naming conventions
  - Function naming patterns
  - Database naming (if applicable)
  - Constant naming

#### `testing-patterns.md`

- **Purpose**: How to write tests
- **Contents**:
  - Unit test structure
  - Integration test patterns
  - Mocking strategies
  - Test data setup

### 5. Decisions (`docs/decisions/`)

#### `adr-*.md` (Architecture Decision Records)

- **Purpose**: Document why certain decisions were made
- **Examples**:
  - `adr-001-why-database-choice.md` - Why a specific database was chosen
  - `adr-002-why-framework-choice.md` - Why a specific framework was chosen
  - `adr-003-why-architecture-pattern.md` - Why a specific architecture pattern was chosen

### 6. Troubleshooting (`docs/troubleshooting/`)

#### `common-issues.md`

- **Purpose**: Known issues and solutions
- **Contents**:
  - Build errors and fixes
  - Runtime errors
  - Database migration issues (if applicable)
  - Common configuration problems

#### `debugging-guide.md`

- **Purpose**: How to debug common problems
- **Contents**:
  - Logging strategies
  - Debug tools
  - How to inspect application state
  - How to check cache/storage

### 7. Development Workflows (`docs/workflows/`)

#### `feature-development.md`

- **Purpose**: Step-by-step guide for adding features
- **Contents**:
  1. Plan the feature
  2. Update data models/schema (if needed)
  3. Create/update components
  4. Add tests
  5. Update documentation
  6. Commit and push

#### `bug-fixing.md`

- **Purpose**: How to fix bugs systematically
- **Contents**:
  1. Reproduce the bug
  2. Identify root cause
  3. Write test case
  4. Fix the bug
  5. Verify fix
  6. Update docs if needed

## 📋 Root-Level Documentation

### Recommended Files:

- ✅ `README.md` - Project overview
- ✅ `CHANGELOG.md` - Version history (automated from commits)
- ✅ `CONTRIBUTING.md` - How to contribute (if applicable)
- ✅ Architecture documentation - High-level architecture
- ✅ Deployment documentation - Deployment guide
- ✅ Testing documentation - Testing overview
- ✅ Troubleshooting documentation - General troubleshooting

## 🎯 Priority Recommendations

### High Priority (Most Impact):

1. **`docs/data-models/database-models.md`** (if applicable) - Helps understand data structures
2. **`docs/patterns/code-patterns.md`** - Shows how to extend the codebase
3. **`docs/components/screens/*.md`** (for UI projects) - Component documentation
4. **`docs/architecture/data-flow.md`** - Understand application flow

### Medium Priority:

5. **`docs/data-models/external-apis.md`** - External data source details
6. **`docs/troubleshooting/common-issues.md`** - Known problems
7. **`docs/workflows/feature-development.md`** - Development process

### Low Priority (Nice to Have):

8. **`docs/decisions/adr-*.md`** - Historical context
9. **`docs/patterns/naming-conventions.md`** - Consistency
10. **`docs/architecture/component-hierarchy.md`** - Visual structure

## 💡 Quick Start Template

For each new component/feature, create a simple markdown file with:

```markdown
# Component/Feature Name

## Purpose

What this does and why it exists.

## Key Files

- `src/path/to/file.tsx` - Main component
- `src/path/to/file.ts` - Utilities

## Props/Parameters

- `propName` (type): Description

## State

- `stateName`: What it tracks

## Key Functions

- `functionName()`: What it does

## Dependencies

- Uses: Other components/utilities
- Used by: Where it's consumed

## Notes

Any important implementation details or gotchas.
```

## 🔄 Maintenance

- Update docs when code changes (per documentation.mdc rule)
- Keep examples current
- Remove outdated information
- Link related docs together

---

**Note**: Start with high-priority docs and add others as needed. Even partial documentation is
better than none!
