# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Translated all French prose in the repository to natural, professional English so the playbook is
  usable by any contributor regardless of language. The translation covered all five multi-agent
  setups under `.agents/setups/`:
  - `legacy-agents-v1` — agents, commands, skills, shell hooks, and docs
  - `web2-agents-v1` — agents, commands, skills, shell hooks, `install.sh`, and docs
  - `web3-agents-v3` — commands, CLAUDE.md, shell hooks, and docs
  - `dev-squad-v2` — skill bodies, references, and YAML `description:` frontmatter
  - `pm-ba-squad-v2` — verified already English
- Replaced French documentation links with their English equivalents:
  - `https://keepachangelog.com/fr/1.0.0/` → `https://keepachangelog.com/en/1.1.0/`
  - `https://cursor.com/fr/docs/context/commands` → `https://cursor.com/docs/context/commands`
- Translated every `description:` field in SKILL.md frontmatter across all setups so skill
  auto-loading metadata is consistent.

### Added

- Root `CHANGELOG.md` following the Keep a Changelog format.
- `CONTRIBUTING.md` — onboarding guide covering ground rules, extension points (rules / commands /
  skills / setups), branch naming, conventional commits, and the quality bar every PR must meet.
- `SECURITY.md` — private vulnerability reporting via GitHub Security Advisories, scope, dual-use
  policy, and coordinated disclosure timeline.
- `.github/PULL_REQUEST_TEMPLATE.md` — structured PR template with scope checkboxes, test plan, and
  pre-merge checklist.
- `.github/ISSUE_TEMPLATE/bug_report.yml` and `feature_request.yml` — structured forms replacing
  blank issues, with a `config.yml` that routes security reports to the private advisory flow and
  questions to Discussions.
- `.github/workflows/ci.yml` — GitHub Actions CI running prettier format check and eslint on every
  push and PR to `main`.

### Fixed

- `package.json` prettier globs and `lint-staged` config still referenced `.cursor/` after the
  `.cursor` → `.agents` rename in commit `ee1399d`, causing every prettier run to error out on
  missing paths.
- `ai-playbook-cli` was broken since the same `.cursor` → `.agents` rename: the build script copied
  a non-existent directory, and every source-path lookup in `cli/src/index.ts` pointed at
  `.cursor/`. Migrated the CLI source-side references: `cli/src/index.ts`,
  `cli/scripts/copy-cursor.js` (renamed to `copy-agents.js`), `cli/package.json` (`copy-cursor`
  script → `copy-agents`), `cli/README.md`, and `cli/PUBLISH.md`. The CLI now builds cleanly
  (`npm run build --prefix cli`) and `install --type copy` populates a fresh project's `.cursor/`
  from the playbook's `.agents/`. Verified end-to-end with a smoke test. The CLI still writes into a
  `.cursor/` directory in the target project (Cursor-native layout); adding a `--target` flag so
  Claude Code users can pick `.claude/` is tracked as a follow-up.
- `cli/package.json` placeholder `YOUR_USERNAME` GitHub URLs replaced with the real
  `KaelSensei/ai-playbook` repository.

### Notes

- Markdown structure, code blocks, YAML keys, file paths, URLs, command names (`/task`, `/spec`,
  `/pr`, etc.), agent identifiers, and technical terms were preserved verbatim — only human prose
  was translated.
- Verified with a repo-wide scan: no French diacritics (`à â ç é è ê î ï ô ù û`) and no common
  French technical vocabulary (`requêtes`, `sécurité`, `métier`, `métriques`, `intégration`,
  `étape`, `règle`, `dépendance`, etc.) remain anywhere under `.agents/`.

---

## [0.2.0] — 2026-03-XX

### Added

- Multi-agent setups under `.agents/setups/` (dev-squad-v2, pm-ba-squad-v2, legacy-agents-v1,
  web2-agents-v1, web3-agents-v3) with per-setup `install.sh`.
- MIT license.
- Token optimization skill and documentation (`TOKEN_OPTIMIZATION.md`).
- `ethskills` Ethereum rule.
- Agent skills bundled with playbook and `CONCEPTS.md` explaining rules, commands, skills, MCP.
- `/export-context` command for AI agent handoff.
- `GAPS_AND_RECOMMENDATIONS.md` and `completion-check` rule.

### Changed

- Renamed `.cursor/` to `.agents/` to reflect multi-tool support (Claude, Cursor, future agents).
- Extracted business logic from commands into dedicated skills to slim down bloated commands.
- Clarified RTK platform support and MCP usage in docs.

[Unreleased]: https://github.com/KaelSensei/ai-playbook/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/KaelSensei/ai-playbook/releases/tag/v0.2.0
