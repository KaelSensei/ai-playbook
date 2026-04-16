# Tool Compatibility

This document is the **honest** answer to "does this playbook work with my AI tool?"

The short version:

- **Base playbook** (`.agents/rules/`, `.agents/commands/`, `.agents/skills/`) — works with Claude
  Code and Cursor. Tool-agnostic content.
- **Multi-agent setups** (`.agents/setups/*`) — **Claude Code is primary**. Cursor is partial. Other
  tools can read the markdown but lose the "agent team" concept and any shell hooks.

Read on for per-feature and per-setup detail.

Mental model:

- **Base playbook** = reusable primitives
- **Setup bundle** = opinionated install package for one workflow

---

## 1. What each tool actually supports

Not every tool has every concept. This table is the physical reality, not a marketing promise.

| Concept                                      | Claude Code                                           | Cursor                                      | Other MCP clients           |
| -------------------------------------------- | ----------------------------------------------------- | ------------------------------------------- | --------------------------- |
| **Rules** (persistent context)               | `.claude/` markdown loaded as context                 | `.cursor/rules/*.mdc` with YAML frontmatter | Read as plain markdown      |
| **Slash commands**                           | `/command` reads `.claude/commands/*.md`              | `/command` reads `.cursor/commands/*.md`    | Manually invoked as scripts |
| **Skills** (on-demand domain knowledge)      | Auto-loaded by agent when matching task is detected   | Loaded as reference context                 | Read on request             |
| **Sub-agents** (multiple specialized agents) | Native — `.claude/agents/*.md` define personas        | **Not supported** — no sub-agent concept    | **Not supported**           |
| **Hooks** (run shell on tool-use events)     | Native — `hooks/{pre,post}-tool-use.sh`, `on-stop.sh` | **Not supported**                           | **Not supported**           |
| **MCP servers**                              | `.claude/mcp.json`                                    | `.cursor/mcp.json`                          | Standard `mcp.json`         |
| **Model switching / session control**        | Native                                                | Native                                      | Varies                      |

**Takeaway:** rules, commands, and skills are markdown and portable. **Agents and hooks are Claude
Code features with no Cursor equivalent** — they degrade gracefully (the content is still readable)
but the automation around them does not run.

---

## 2. Per-setup compatibility

Each `.agents/setups/*` bundles its own `.claude/` layout, agent personas, and optional hooks. Here
is what actually works where.

Important: any `skills/` folder inside a setup is a **setup-local skill pack** for that bundle. It
is separate from the shared base playbook skill catalog in `.agents/skills/`.

| Setup                  | Agents | Hooks | Claude Code | Cursor                    | Notes                                                                  |
| ---------------------- | ------ | ----- | ----------- | ------------------------- | ---------------------------------------------------------------------- |
| **`dev-squad-v2`**     | 3      | No    | ✅ Full     | ⚠️ Commands + skills only | No hooks; agent personas become reference docs in Cursor.              |
| **`pm-ba-squad-v2`**   | 3      | No    | ✅ Full     | ⚠️ Commands + skills only | No hooks; spec-writing workflows translate cleanly to Cursor prompts.  |
| **`legacy-agents-v1`** | 14     | Yes   | ✅ Full     | ⚠️ Commands only          | Hooks enforce legacy safety rails — **Cursor loses those guardrails**. |
| **`web2-agents-v1`**   | 13     | Yes   | ✅ Full     | ⚠️ Commands only          | Hooks enforce security rails — **Cursor loses those guardrails**.      |
| **`web3-agents-v3`**   | 10     | Yes   | ✅ Full     | ⚠️ Commands only          | Hooks enforce smart-contract safety checks — **Cursor loses them**.    |

Legend:

- ✅ **Full** — every feature works as designed.
- ⚠️ **Partial** — the content installs and is readable, but some automation does not run.

**What "⚠️ Partial" means concretely for Cursor:**

- The `.claude/agents/*.md` persona files install into the target directory. Cursor does not invoke
  them as distinct agents, so the multi-agent workflow collapses into "one AI reading everything".
  For `dev-squad-v2` this means the pair-review pattern (Dev A writes, Dev B reviews) is lost.
- Shell hooks (`hooks/*.sh`) are never triggered because Cursor has no `pre-tool-use` /
  `post-tool-use` event hooks. Any guardrails the hooks enforce — like blocking `rm -rf`,
  `git push --force`, or risky SQL — are **silently disabled**.
- Commands (`.claude/commands/*.md`) mostly still work as `/command` slash invocations in Cursor if
  you install to `.cursor/commands/`, because Cursor supports slash commands that read markdown
  files.
- Skills (`.claude/skills/*/SKILL.md`) install to the target directory and can be loaded as
  reference knowledge, but Cursor does not auto-load them — you reference them manually.

---

## 3. Installing for your tool

Every setup ships an `install.sh` that defaults to `.claude/` and accepts any target directory as
its first argument.

### Claude Code (default)

```bash
bash .agents/setups/dev-squad-v2/install.sh
# → installs into ./.claude/
```

### Cursor

```bash
bash .agents/setups/dev-squad-v2/install.sh .cursor
# → installs into ./.cursor/
```

After installing into `.cursor/`, you need to do one extra step for the rules to load as Cursor
project context: copy or symlink the base playbook's `.mdc` rules into `.cursor/rules/`:

```bash
mkdir -p .cursor/rules
cp .ai-playbook/.agents/rules/*.mdc .cursor/rules/
# or symlink if the playbook is a submodule:
ln -s ../.ai-playbook/.agents/rules .cursor/rules
```

This is needed because the multi-agent setups do **not** ship `.mdc` rule files — the base playbook
does.

### Other MCP clients

```bash
bash .agents/setups/dev-squad-v2/install.sh .your-tool
# → installs into ./.your-tool/
```

The installer just copies files. Your tool needs to know how to read markdown and (optionally)
handle `mcp.json`.

---

## 4. Decision guide

**"Which setup should I use if I'm on Cursor?"**

Prefer **`dev-squad-v2`** or **`pm-ba-squad-v2`** — they have no hooks, so nothing is silently
disabled. You lose the multi-agent pair-review workflow (Cursor runs one AI) but get the full
benefit of the commands, skills, and templates.

Avoid **`legacy-agents-v1`**, **`web2-agents-v1`**, and **`web3-agents-v3`** on Cursor unless you
are comfortable losing the shell-hook guardrails. These setups were designed with Claude Code's hook
system as part of their safety model.

**"Can I use the base playbook (rules/commands/skills) on any tool?"**

Yes. The base playbook in `.agents/rules/`, `.agents/commands/`, and `.agents/skills/` is pure
markdown with no shell dependencies. Install via:

```bash
npx ai-playbook-cli@latest install          # current: installs into .cursor/
# or manually:
ln -s ../.ai-playbook/.agents/rules .claude/rules
ln -s ../.ai-playbook/.agents/commands .claude/commands
ln -s ../.ai-playbook/.agents/skills .claude/skills
```

See [INSTALLATION.md](../../INSTALLATION.md) for the full setup options.

**"I'm building a custom MCP client. Can I consume this playbook?"**

Yes, as long as your client can read markdown files and (optionally) parse YAML frontmatter for
`.mdc` rule metadata. The playbook deliberately avoids tool-specific formats beyond `.mdc` — see
section 5 below.

---

## 5. Reliability invariants

These properties are maintained intentionally so the playbook stays portable:

- **All content is plain markdown or JSON.** No proprietary formats.
- **Rules are `.mdc`** — markdown with YAML frontmatter. Cursor consumes this natively; any other
  tool can read it as markdown and ignore the frontmatter.
- **Commands describe _what_ to do as numbered steps**, not _how_ the tool should execute them. Any
  AI agent can follow them as a checklist.
- **Skills are knowledge modules** with clear "when to use" triggers. Tools with auto-loading can
  use the triggers; tools without can load skills manually.
- **Hooks are opt-in.** Setups that use hooks are clearly marked (see the matrix above), and the
  hook files are plain bash scripts — they fail cleanly on tools that do not invoke them.
- **`install.sh` accepts any target directory.** No setup hard-codes `.claude/` or `.cursor/`.

This keeps `.agents/` as the **single source of truth** for AI behavior, while accepting that
different tools support different subsets of the feature set.
