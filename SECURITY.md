# Security Policy

The AI Playbook ships behavior-shaping content (rules, commands, skills) that multiple projects
depend on. A compromised playbook can influence every AI session that loads it. We take security
reports seriously.

---

## Reporting a vulnerability

**Do not open a public issue for security vulnerabilities.**

Instead, report privately via one of:

1. **GitHub Security Advisories** — preferred. Open
   [a new advisory](https://github.com/KaelSensei/ai-playbook/security/advisories/new) on this
   repository. Only repository maintainers can see it.
2. **Direct contact** — if you cannot use GitHub advisories, open a
   [discussion](https://github.com/KaelSensei/ai-playbook/discussions) titled "security contact
   request" and a maintainer will reach out privately.

Please include:

- A clear description of the issue and its impact
- Steps to reproduce or a proof-of-concept
- The affected file(s), setup(s), or CLI version
- Your disclosure timeline, if any

You can expect an acknowledgment within **72 hours** and an initial assessment within **7 days**.

---

## Scope

In scope:

- **Prompt injection or instruction smuggling** in rules, commands, or skills that could cause an AI
  agent loading the playbook to take unintended actions
- **Malicious payloads** embedded in shell hooks (`.agents/setups/*/hooks/*.sh`), install scripts
  (`install.sh`), or CLI code (`cli/src/`)
- **Supply-chain issues** in the published `ai-playbook-cli` npm package (tampered artifacts,
  typosquat-friendly names, etc.)
- **Credential or secret exposure** — any rule, skill, or example that causes an AI to leak
  environment variables, tokens, or file contents outside the project sandbox
- **Write-outside-project** behavior — rules, commands, or CLI code that can write to paths outside
  the target repository without explicit consent
- **Backdoor patterns** — commands or skills that instruct the AI to introduce persistent access,
  data exfiltration, or evasion of security reviews

Out of scope:

- Vulnerabilities in third-party AI tools (Claude Code, Cursor, etc.) — report those to the tool
  vendor.
- Generic best-practice suggestions without a concrete exploit or impact statement.
- Theoretical issues in example code unless they also affect the playbook's runtime behavior.

---

## Dual-use considerations

This playbook contains content that discusses offensive-security topics (OWASP Top 10, injection
patterns, access control, proxy patterns, etc.) for **defensive and educational purposes**.
Contributions that primarily enable attacks — credential stuffing, mass targeting, detection
evasion, supply-chain compromise for malicious ends — will be rejected.

When in doubt, file a draft PR and ask.

---

## Disclosure policy

We prefer **coordinated disclosure**:

1. You report the issue privately.
2. We acknowledge, investigate, and develop a fix on a private branch.
3. We release the fix and credit you (unless you prefer to stay anonymous).
4. Public disclosure happens after users have had a reasonable window to update — typically **30
   days** from the release, or sooner if the issue is already public.

If the issue is being actively exploited or already public, the timeline compresses. Tell us.

---

## What we ask of you

- Do not exploit the vulnerability beyond what is necessary to demonstrate it.
- Do not access, modify, or delete data you do not own.
- Do not run automated scanners or fuzzers against infrastructure you do not own.
- Give us a fair chance to fix the issue before disclosing publicly.

Thank you for helping keep the playbook and its users safe.
