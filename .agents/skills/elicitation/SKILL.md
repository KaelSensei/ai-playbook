---
name: elicitation
description:
  Library of 50+ structured elicitation techniques for requirements gathering, brainstorming, and
  problem exploration. Organized by category. Use when /brainstorm, /spec, or /prfaq need deeper
  requirements extraction.
---

# Elicitation Framework Skill

A curated library of techniques for extracting requirements, exploring problem spaces, and
generating ideas with structured rigor. Each technique has a specific use case — the AI auto-selects
3-5 relevant techniques based on context. Inspired by BMAD-METHOD's elicitation framework.

## When to use this skill

- When running `/brainstorm` and initial ideas feel shallow.
- When running `/spec` and requirements are vague.
- When running `/prfaq` and the customer problem isn't well understood.
- When the user says "dig deeper" or "I need more ideas."

## How this skill is used

**Users do not invoke skills directly.** The AI auto-selects techniques from this library when a
command needs deeper exploration, or when explicitly referenced.

- **Referenced by:** `/brainstorm`, `/spec`, `/prfaq`

---

## How to Use

1. **Assess the situation** — What kind of input do you need? (ideas, requirements, risks, etc.)
2. **Pick 3-5 techniques** from the relevant categories below.
3. **Run each technique** as a structured prompt, capturing output.
4. **Synthesize** — Combine outputs into actionable requirements or decisions.

The AI should auto-select techniques. The user can also request specific ones by name.

---

## Technique Categories

### Core — Start Here

| #   | Technique                  | When to use                  | Method                                                                          |
| --- | -------------------------- | ---------------------------- | ------------------------------------------------------------------------------- |
| 1   | **5 Whys**                 | Root cause is unclear        | Ask "why?" 5 times, each answer feeding the next question                       |
| 2   | **User Story Mapping**     | Feature scope is fuzzy       | Map: actor → goal → steps → stories per step                                    |
| 3   | **Assumption Listing**     | Confidence is low            | List every assumption, rate confidence (high/med/low), flag low-confidence ones |
| 4   | **Stakeholder Interviews** | Multiple perspectives needed | List stakeholders, write 5 questions per role, capture answers                  |
| 5   | **Context Diagram**        | System boundaries unclear    | Draw: system in center, external actors around it, data flows between           |

### Collaborative — Multiple Perspectives

| #   | Technique              | When to use                  | Method                                                              |
| --- | ---------------------- | ---------------------------- | ------------------------------------------------------------------- |
| 6   | **Brainwriting 6-3-5** | Brainstorming stalls         | 6 perspectives, 3 ideas each, 5 rounds of building on others' ideas |
| 7   | **Affinity Mapping**   | Too many ideas, no structure | Generate ideas freely → group by natural themes → name each group   |
| 8   | **Dot Voting**         | Prioritization needed        | List options, each participant gets 3 votes, highest wins           |
| 9   | **Round Robin**        | One voice dominates          | Each perspective contributes one idea in turn, no skipping          |
| 10  | **Reverse Brainstorm** | Stuck on how to succeed      | Ask "how could we make this fail?" → invert each answer             |

### Deep Analysis — Thorough Exploration

| #   | Technique                 | When to use                     | Method                                                               |
| --- | ------------------------- | ------------------------------- | -------------------------------------------------------------------- |
| 11  | **SWOT Analysis**         | Strategic assessment            | Map Strengths, Weaknesses, Opportunities, Threats                    |
| 12  | **Force Field Analysis**  | Change resistance expected      | List driving forces (+) and restraining forces (-), rate strength    |
| 13  | **MoSCoW Prioritization** | Scope needs bounding            | Classify: Must have, Should have, Could have, Won't have             |
| 14  | **Kano Model**            | Feature value is unclear        | Classify: Must-be, One-dimensional, Attractive, Indifferent, Reverse |
| 15  | **Impact/Effort Matrix**  | Prioritization with constraints | Plot features on 2x2: high/low impact × high/low effort              |

### Creative — Generate Novel Ideas

| #   | Technique                | When to use                 | Method                                                                   |
| --- | ------------------------ | --------------------------- | ------------------------------------------------------------------------ |
| 16  | **SCAMPER**              | Improving existing features | Substitute, Combine, Adapt, Modify, Put to other use, Eliminate, Reverse |
| 17  | **Random Entry**         | Thinking is stuck in a rut  | Pick a random word/image → force connections to the problem              |
| 18  | **Worst Possible Idea**  | Group is too cautious       | Generate the worst ideas → extract insights about what actually matters  |
| 19  | **Analogy Thinking**     | Problem feels unique        | "What is this like in another domain?" → transfer solutions              |
| 20  | **Future Press Release** | Vision is unclear           | Write the announcement as if it's done → work backwards (see /prfaq)     |

### Risk & Edge Cases — What Could Go Wrong

| #   | Technique                 | When to use                    | Method                                                                      |
| --- | ------------------------- | ------------------------------ | --------------------------------------------------------------------------- |
| 21  | **Pre-mortem**            | Before starting implementation | "It's 6 months later and this failed. Why?" → list failure modes            |
| 22  | **Failure Mode Analysis** | System reliability matters     | For each component: what can fail? → how likely? → how severe? → mitigation |
| 23  | **Edge Case Enumeration** | Happy path bias                | List every input boundary, null case, concurrent case, timing case          |
| 24  | **Threat Modeling**       | Security implications          | STRIDE: Spoofing, Tampering, Repudiation, Info disclosure, DoS, Elevation   |
| 25  | **Dependency Mapping**    | Integration complexity         | Map every external dependency → what happens when each fails?               |

### User-Centered — Understanding the Human

| #   | Technique                | When to use                     | Method                                                                      |
| --- | ------------------------ | ------------------------------- | --------------------------------------------------------------------------- |
| 26  | **Persona Creation**     | User needs are abstract         | Create 2-3 fictional users with name, role, goals, frustrations, tech level |
| 27  | **Jobs to Be Done**      | Feature request hides real need | "When <situation>, I want to <motivation>, so I can <outcome>"              |
| 28  | **Customer Journey Map** | UX gaps exist                   | Map: awareness → consideration → adoption → usage → advocacy                |
| 29  | **Day in the Life**      | Context of use is unclear       | Narrate user's typical day, noting when/where/why they'd use the product    |
| 30  | **Empathy Map**          | Disconnected from user          | Map: what user says, thinks, does, feels about the problem                  |

### Technical — Architecture & Design

| #   | Technique              | When to use                | Method                                                                   |
| --- | ---------------------- | -------------------------- | ------------------------------------------------------------------------ |
| 31  | **Event Storming**     | Domain complexity high     | List domain events → group by aggregate → identify commands and policies |
| 32  | **C4 Diagramming**     | Architecture communication | Context → Container → Component → Code (4 zoom levels)                   |
| 33  | **ADR Writing**        | Decision needs recording   | Context → Decision → Alternatives → Consequences                         |
| 34  | **API-First Design**   | Integration-heavy feature  | Define API contract before implementation → validate with consumers      |
| 35  | **Data Flow Analysis** | Data handling complexity   | Trace data: source → transformations → storage → display → deletion      |

### Structured Reasoning — Disciplined Thinking

| #   | Technique                 | When to use                         | Method                                                                                              |
| --- | ------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------- |
| 36  | **Six Thinking Hats**     | Discussion is unfocused             | White (facts), Red (feelings), Black (caution), Yellow (optimism), Green (creative), Blue (process) |
| 37  | **Pros/Cons/Mitigations** | Binary decision                     | List pros, cons, and for each con: a specific mitigation                                            |
| 38  | **Decision Matrix**       | Multiple options, multiple criteria | Score each option against weighted criteria → highest total wins                                    |
| 39  | **Timeboxing**            | Analysis paralysis                  | Set a timer. Decide with available info. Accept imperfection.                                       |
| 40  | **First Principles**      | Conventional wisdom may be wrong    | Strip to fundamental truths → rebuild reasoning from scratch                                        |

### Retrospective — Learning from Experience

| #   | Technique               | When to use            | Method                                                                                |
| --- | ----------------------- | ---------------------- | ------------------------------------------------------------------------------------- |
| 41  | **Start/Stop/Continue** | Simple retrospective   | What should we start doing? Stop doing? Continue doing?                               |
| 42  | **4 Ls**                | Balanced retrospective | Liked, Learned, Lacked, Longed for                                                    |
| 43  | **Timeline**            | Complex project review | Map key events chronologically → mark high/low points → discuss patterns              |
| 44  | **Fishbone Diagram**    | Recurring problem      | Effect at head → categories of causes as bones → specific causes as sub-bones         |
| 45  | **Sailboat**            | Forward-looking retro  | Wind (what propels us), Anchors (what holds back), Rocks (risks ahead), Island (goal) |

### Advanced — Specialized Situations

| #   | Technique                     | When to use               | Method                                                                                                                 |
| --- | ----------------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| 46  | **Wardley Mapping**           | Strategic positioning     | Map value chain → assess evolution stage of each component → identify moves                                            |
| 47  | **Theory of Constraints**     | Bottleneck suspected      | Find the constraint → exploit it → subordinate everything else → elevate it                                            |
| 48  | **Cynefin Framework**         | Complexity level unclear  | Classify: Simple (best practice) → Complicated (expert analysis) → Complex (probe-sense-respond) → Chaotic (act first) |
| 49  | **Opportunity Solution Tree** | Many possible paths       | Map: outcome → opportunities → solutions → experiments per solution                                                    |
| 50  | **Socratic Questioning**      | Deep understanding needed | Ask progressively deeper questions: clarifying → probing assumptions → probing evidence → perspectives → implications  |

---

## Auto-Selection Guide

When the AI needs to pick techniques, use this decision tree:

| Situation                            | Recommended Techniques                                    |
| ------------------------------------ | --------------------------------------------------------- |
| "I have a vague idea"                | 5 Whys, Jobs to Be Done, Future Press Release             |
| "I need to understand the user"      | Persona Creation, Empathy Map, Day in the Life            |
| "I need to prioritize"               | MoSCoW, Impact/Effort Matrix, Dot Voting                  |
| "I need to find risks"               | Pre-mortem, Failure Mode Analysis, Threat Modeling        |
| "I need creative ideas"              | SCAMPER, Reverse Brainstorm, Analogy Thinking             |
| "I need architecture decisions"      | Event Storming, ADR Writing, C4 Diagramming               |
| "I need to decide between options"   | Decision Matrix, Pros/Cons/Mitigations, Six Thinking Hats |
| "I need to learn from what happened" | Start/Stop/Continue, 4 Ls, Timeline                       |

---

## Anti-patterns

- **Technique overload** — 3-5 techniques per session is the sweet spot. More adds fatigue.
- **Technique worship** — The technique is a means, not an end. Skip steps that don't add value.
- **Analysis paralysis** — If elicitation takes longer than implementation would, use Timeboxing.
- **First 20 ideas** — The first 20 ideas in any brainstorm are usually obvious. Push past them.
