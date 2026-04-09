# PM-BA Squad

## Working language

English (specs, stories, ACs, rules — everything in English)

## ID conventions

- Features: FEAT-XXX
- User stories: US-XXX
- Business rules: BR-XX

## Agent Team

| Agent              | Role                                        | Skills                                                          |
| ------------------ | ------------------------------------------- | --------------------------------------------------------------- |
| `product-owner`    | Needs → stories, prioritisation, validation | bdd-gherkin, spec-writing, acceptance-criteria                  |
| `business-analyst` | Analysis + complete specs + business rules  | bdd-gherkin, spec-writing, acceptance-criteria, domain-language |
| `spec-reviewer`    | Spec validation before dev                  | bdd-gherkin, spec-writing, acceptance-criteria                  |

## Flows

| Command               | Description                        |
| --------------------- | ---------------------------------- |
| `/story [raw need]`   | PO analyses, BA enriches the ACs   |
| `/spec [slug]`        | BA writes, Spec Reviewer validates |
| `/review-spec [file]` | Independent review of a spec       |

## Definition of Ready

A story is ready for dev when:

- Gherkin ACs complete (happy path + errors + edge cases)
- Business rules numbered BR-XX
- Out of scope explicit
- No "TBD" in ACs
- A dev can implement without calling you back

## Foundation docs to fill in

- `.claude/project-architecture.md` → project context
- `.claude/constants.md` → key personas, initial glossary
- `docs/specs/` → destination folder for specs
