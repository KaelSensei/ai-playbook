---
name: story
description: >
  Transforms a raw business need into user stories with BDD acceptance criteria. PO analyses and
  clarifies. BA enriches the Gherkin ACs.
argument-hint: '[raw need in natural language]'
---

# /story

## Step 1 — PO analyses the need

You are product-owner. Load bdd-gherkin, spec-writing, acceptance-criteria skills. Need: $ARGUMENTS

1. Identify the personas concerned
2. Ask the necessary clarifying questions
3. Produce user stories if enough context is available

Gate: if open questions → wait for answers before continuing.

## Step 2 — BA enriches the ACs

You are business-analyst. Load bdd-gherkin, spec-writing, acceptance-criteria skills. Stories from
PO: [stories]

For each story:

1. Write complete Gherkin ACs (happy path + errors + edge cases)
2. Document identified business rules (numbered BR-XX)
3. List edge cases with boundary specifications

## Step 3 — PO gate

Present to PO for validation: "Do these stories and ACs match the intended need?"

## Output

Save to: docs/specs/[slug]-stories.md
