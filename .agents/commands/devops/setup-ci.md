# Setup CI Command – Scaffold a minimal GitHub Actions CI workflow

When `/setup-ci` is invoked, immediately execute the following steps to scaffold a minimal
`.github/workflows/ci.yml` in the **consumer project** based on its detected stack.

This is a focused, opinionated scaffold: build + test + lint/typecheck on push and pull requests. It
is **not** a deployment pipeline. For broader DevOps work (deploy, Docker, Kubernetes), use
`/devops` instead.

**Skills used:** `conventional-commits` (commit message), `security-review` (no secrets in YAML).

---

## Step 1: Load Context

1. Assume the project root is the working directory.
2. Identify the current Git branch. If on `main` or `master`, **stop** and ask the user to create a
   branch first (e.g. `chore/setup-ci`).
3. Check whether `.github/workflows/ci.yml` already exists.
   - If it exists and the user did not pass `--force`: **stop and report**. Show the existing file
     path and ask if they want to overwrite or pick a different filename.
   - If `--force` was passed: proceed and overwrite.

---

## Step 2: Detect the Stack

Inspect manifest files at the project root, in this priority order. Pick the first match.

| Manifest           | Stack           | Build/test commands                                       |
| ------------------ | --------------- | --------------------------------------------------------- |
| `package.json`     | Node / TS       | `npm ci`, `npm run build`, `npm test`, optional typecheck |
| `pyproject.toml`   | Python (modern) | `pip install`, `pytest`, optional `ruff` / `mypy`         |
| `requirements.txt` | Python (legacy) | `pip install -r requirements.txt`, `pytest`               |
| `Cargo.toml`       | Rust            | `cargo build --verbose`, `cargo test --verbose`           |
| `go.mod`           | Go              | `go build ./...`, `go test ./...`                         |

If **none** match, stop and report which manifests were searched. Do not guess.

For Node specifically, also detect the package manager from lockfiles (`pnpm-lock.yaml` → `pnpm`,
`yarn.lock` → `yarn`, otherwise `npm`) and inspect `package.json` scripts to decide which optional
steps to include:

- `scripts.build` → include build step
- `scripts.test` → include test step
- `scripts.lint` → include lint step
- `scripts.typecheck` or `tsconfig.json` present → include typecheck step (`tsc --noEmit` if no
  script)

Skip steps that don't apply. Do not invent scripts that aren't there.

---

## Step 3: Security Check

Run the **`security-review` skill** mindset against the workflow you are about to write:

- No hardcoded secrets, tokens, or credentials in the YAML.
- Pin third-party actions to a major version (`actions/checkout@v4`, not `@main`).
- Do not enable `pull_request_target` unless the user explicitly asked for it (privilege escalation
  risk on forks).
- `permissions:` should default to read-only at the workflow level.

---

## Step 4: Write the Workflow

Create `.github/workflows/ci.yml`. Use the template that matches the detected stack. Strip steps
that don't apply (e.g. no `lint` script → drop the lint step).

### Node / TypeScript

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm # or pnpm / yarn based on detection
      - run: npm ci
      - run: npm run lint --if-present
      - run: npm run typecheck --if-present
      - run: npm run build --if-present
      - run: npm test --if-present
```

For pnpm, replace setup with `pnpm/action-setup@v4` then `actions/setup-node@v4` with `cache: pnpm`,
and use `pnpm install --frozen-lockfile` + `pnpm <script>`.

For yarn, use `cache: yarn` and `yarn install --frozen-lockfile` + `yarn <script>`.

### Python

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip
      - run: pip install -e .[dev] # or: pip install -r requirements.txt
      - run: pytest
```

### Rust

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo build --verbose
      - run: cargo test --verbose
```

### Go

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - run: go build ./...
      - run: go test ./...
```

---

## Step 5: Validate

1. Confirm the file is valid YAML (no tabs, consistent indentation).
2. Confirm every `run:` command corresponds to something the project actually has (a script, a
   manifest target, etc.). If a step references a missing script and `--if-present` isn't used,
   remove the step.
3. Confirm `permissions:` is read-only.
4. Confirm no secret-looking strings were inlined.

---

## Step 6: Commit & Push

Use the **`conventional-commits` skill** for the message:

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add minimal GitHub Actions build/test workflow"
git push origin $(git branch --show-current)
```

Do not add unrelated files. Do not commit to `main`.

---

## Behavior Rules

- Refuse to run on `main` / `master`.
- Refuse to overwrite an existing `ci.yml` without `--force`.
- One workflow file per run. Don't generate `deploy.yml`, `release.yml`, etc. — that's `/devops`.
- Stack-opinionated, not configurable. If the user wants a custom matrix or extra jobs, point them
  at `/devops`.
- If the stack can't be detected, stop and report. Don't guess.

---

## Usage

```
/setup-ci            # detect stack and scaffold .github/workflows/ci.yml
/setup-ci --force    # overwrite an existing ci.yml
```

Examples:

- In a Node/TS repo with `package.json` + `tsconfig.json`: produces a workflow with checkout,
  setup-node, `npm ci`, `npm run lint`, `npm run typecheck`, `npm run build`, `npm test` (only the
  scripts that exist).
- In a Rust crate: produces a workflow with checkout, rust-toolchain, rust-cache, `cargo build`,
  `cargo test`.
- If `.github/workflows/ci.yml` already exists: stops and reports — re-run with `--force` to
  overwrite.
