# PRFAQ Command — Working Backwards Product Validation

When `/prfaq <product or feature idea>` is invoked, guide the user through Amazon's Working
Backwards methodology: write the press release and FAQ **before** building anything.

**Skills used:** `party-mode` (optional, for multi-perspective review).

**Output:** A `PRFAQ.md` document that validates the product idea from the customer's perspective
before any technical work begins.

---

## Why Working Backwards?

Most product development starts with a solution and searches for a problem. Working Backwards
inverts this: start with the customer experience you want to deliver, then work backwards to
determine what to build. If you can't write a compelling press release, the feature probably isn't
worth building.

---

## Step 1: Load Context

1. Read: `README.md`, project docs, existing PRFAQ.md (if resuming)
2. Load rules from `.agents/rules/*.mdc`
3. Parse the product/feature idea from the command argument
4. If no argument: **stop and ask** — "What product or feature idea should we validate?"

---

## Step 2: Identify the Customer

Before writing anything, establish:

1. **Who is the customer?** — Be specific. Not "developers" but "solo developers building SaaS
   products who don't have a dedicated DevOps team."
2. **What is their problem?** — What pain point does this solve? Describe it in their words, not
   yours.
3. **How do they solve it today?** — What's the current alternative (including "do nothing")?
4. **Why is the current solution insufficient?** — What gap exists?

If the user provides a solution-first description ("build an API gateway"), redirect to
customer-first thinking: "Who needs this and why? Let's start there."

---

## Step 3: Write the Press Release

Write a 1-page press release announcing the feature/product as if it's already launched. This is the
core artifact — it must be compelling enough that a customer would care.

### Press Release Structure

```markdown
## PRFAQ: <Feature/Product Name>

### Press Release

**<City>, <Date>** — <Company/Project> today announced <product/feature>, a <one-line description>
designed for <target customer>.

<Problem paragraph — describe the customer pain point in vivid, specific terms. Use the customer's
language, not technical jargon.>

<Solution paragraph — describe what the product/feature does and how it solves the problem. Focus on
the customer experience, not the implementation.>

"<Quote from a fictional customer or team lead describing the impact in their words.>"

<How it works paragraph — high-level description of the experience. What does the customer do? What
happens? Keep it simple.>

<Availability paragraph — how to get started, what's included, any constraints.>
```

### Press Release Rules

- **No technical jargon** — Write for the customer, not engineers.
- **No vague benefits** — "Saves time" is vague. "Reduces deployment from 45 minutes to 3" is
  specific.
- **One page maximum** — If you can't explain it in one page, the idea isn't clear enough.
- **Customer-first** ��� Every sentence should answer "why should the customer care?"

---

## Step 4: Write the FAQ

Two sections: customer-facing FAQ and internal FAQ.

### External FAQ (Customer Questions)

Answer 5-7 questions a customer would ask:

```markdown
### External FAQ

**Q: How is this different from <existing alternative>?** A: <specific differentiation>

**Q: What do I need to get started?** A: <prerequisites and setup>

**Q: What are the limitations?** A: <honest constraints — builds trust>

**Q: How much does it cost / what's the effort?** A: <pricing, time investment, or resource
requirements>

**Q: What happens if <common concern>?** A: <address the objection directly>
```

### Internal FAQ (Team Questions)

Answer 3-5 questions the team would ask:

```markdown
### Internal FAQ

**Q: What's the estimated effort?** A: <scope and complexity assessment>

**Q: What are the biggest risks?** A: <technical, market, or adoption risks>

**Q: What do we need to be true for this to succeed?** A: <key assumptions that must hold>

**Q: How will we measure success?** A: <specific, measurable criteria>

**Q: What's the minimum viable version?** A: <smallest thing we can build to validate the idea>
```

---

## Step 5: Validate the PRFAQ

### Self-Review

Run through this checklist:

- [ ] **Customer clarity** — Is the target customer specific and identifiable?
- [ ] **Problem clarity** — Would the customer recognize the problem as described?
- [ ] **Compelling solution** — Would the customer actually want this?
- [ ] **No jargon** — Can a non-technical person understand the press release?
- [ ] **Specific benefits** — Are benefits measurable, not vague?
- [ ] **Honest limitations** — Are constraints and risks acknowledged?
- [ ] **Minimum viable scope** — Is the smallest useful version identified?

### Optional: Party Mode Review

If `--party` flag is used, spawn a roundtable with:

- **The User Advocate** — Is this actually something customers want?
- **The Skeptic** — What could go wrong? What assumptions are fragile?
- **The Pragmatist** — Can we actually build this with our constraints?

---

## Step 6: Decide and Document

Based on the PRFAQ, recommend one of:

- **GO** — The idea is compelling, the problem is real, the scope is manageable. Suggest next step:
  `/spec` to create a formal specification.
- **REFINE** — The core idea has merit but needs work. Identify what's unclear and iterate.
- **PARK** — The idea isn't compelling enough right now. Document it for future revisiting.
- **DROP** — The problem isn't real, the solution doesn't fit, or the effort isn't justified.

Commit and push the PRFAQ.md:

```bash
git add PRFAQ.md
git commit -m "docs: add PRFAQ for <feature/product name>"
git push origin $(git branch --show-current)
```

---

## Behavior Rules

- Always redirect solution-first thinking to customer-first thinking.
- Never write technical implementation details in the press release.
- Be honest about limitations — a PRFAQ that hides constraints is useless.
- The press release is the hardest part. If it's not compelling, stop and rethink.
- This is a validation tool, not a commitment. "PARK" and "DROP" are valid outcomes.

---

## Usage

- `/prfaq real-time collaboration for the editor` — Validate a feature idea
- `/prfaq AI-powered code review assistant` — Validate a product idea
- `/prfaq --party offline-first mobile app` — Validate with multi-agent roundtable
