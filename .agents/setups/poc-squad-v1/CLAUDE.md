# POC Squad

## Purpose

Build the smallest thing that proves an idea. Throwaway work. Speed > correctness > beauty.

## Agent Team

| Agent        | Persona       | Skills                                      |
| ------------ | ------------- | ------------------------------------------- |
| `prototyper` | prototyper.md | clean-code, team--skill-lookup (if present) |

## Flows

| Command        | Description                                                      |
| -------------- | ---------------------------------------------------------------- |
| `/poc [idea]`  | Prototyper builds the minimum viable thing. No tests, no layers. |
| `/demo-polish` | Optional pass: tighten naming, add a README, make it demo-ready. |

## Hard rules (even for throwaway work)

1. **Pick one language, one file layout.** No monorepo, no microservices, no "future-proof"
   scaffolding. A POC is one small thing.
2. **No premature abstraction.** Three similar lines > one helper function. The helper might be
   wrong; the three lines are obviously correct.
3. **No dependencies without reason.** Every `npm install` is a bet. Bet rarely.
4. **Names still matter.** `clean-code` is inherited from the base playbook — SOLID and naming
   conventions apply. "Move fast" is not a license for `function x(a, b, c)`.
5. **Commit early, commit often.** Small commits with `feat(poc): ...` messages. When the idea dies,
   the branch dies — no half-finished files on `main`.
6. **Do not touch `main`.** Always work on `poc/<slug>` or `feature/poc-<slug>`.

## What this setup deliberately does NOT do

- No Canon TDD. Tests come later, if ever.
- No hexagonal architecture. One file is fine. Two files is fine. A folder structure can wait.
- No pair review. The prototyper is alone and fast.
- No security review. Add it when the POC proves the idea.
- No `/spec`, `/brief`, or `/arbitrate`. Those slow you down at this stage.

## When to switch setups

When any of these are true, graduate to `dev-squad-v2` (or `web2-agents-v1` / `web3-agents-v3`):

- The demo is getting real users.
- You start worrying about auth, secrets, or data loss.
- You find yourself adding tests retroactively.
- The single-file design is cracking.

See `README.md` in this setup for the full graduation guide.
