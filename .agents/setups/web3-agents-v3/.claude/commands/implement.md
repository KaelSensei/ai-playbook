---
name: implement
description: >
  Implements a Web3 spec in strict TDD adapted for smart contracts. RED-GREEN-BLUE cycle on each
  item in the test list. Mandatory order: unit → integration → fork → invariant. Requires an
  approved spec from /spec.
argument-hint: '[spec slug]'
---

# /implement (Web3 — Strict TDD)

Update tasks/current_task.md: status=IMPLEMENT

---

## Phase 1 — Load the spec and the test list

```
Load .claude/specs/$ARGUMENTS.md
Extract the ordered test list (4 mandatory levels if on-chain value is involved):
  1. Unit tests (pure domain, no fork)
  2. Integration tests (interactions between contracts)
  3. Fork tests (behavior on real mainnet)
  4. Invariant tests (properties that must always hold)
```

Display the test list. User gate before starting.

---

## Phase 2 — TDD loop (one item at a time)

### 🔴 RED — smart-contract-engineer writes ONE test

```
You are smart-contract-engineer.
Load project-architecture.md SUMMARY.
Load solidity-patterns → the relevant section only.
Load the foundry-testing skill.

Spec: [contents of .claude/specs/$ARGUMENTS.md]
Next item: [item from the test list]

RED PHASE:
Write ONE Foundry test that fails.
The test expresses the expected BEHAVIOR — not the implementation.
Naming: test_[behavior]_[condition]()
Run: forge test --match-test [name] — it must be RED.
Verify the failure is an assertion failure, not a compilation error.

Output:
- Test code
- forge test output (must show FAIL)
- Reason for the failure (assertion, not import error)
```

**RED gate**: if the test passes → it's bad → start over.

---

### 🔵 TEST review — dev-senior-b before any production code

```
You are dev-senior-b (Web3 mode).
Load testing-patterns, solidity-patterns skills.
Load team--skill-review.

Review the TEST only — no production code yet.

Check:
- Does the test express behavior (not implementation)?
- Is the assertion precise (not just assertTrue)?
- Is the test independent (clean setUp)?
- Are the cheatcodes appropriate (vm.prank, deal, etc.)?
- For value functions: is ReentrancyGuard tested?
- For oracles: are freshness and deviation tested?

Verdict: APPROVE / APPROVE_WITH_CHANGES / REQUEST_REDESIGN
```

If REQUEST_REDESIGN → rewrite the test. If APPROVE → move to GREEN.

---

### 🟢 GREEN — smart-contract-engineer implements the minimum

```
You are smart-contract-engineer.
GREEN PHASE:

Write the MINIMUM Solidity code that makes the test pass.
SUPER GREEN rules (Web3-adapted):
  ✅ Test passes
  ✅ Expressive naming (no a, b, x as variable names)
  ✅ CEI enforced if value is transferred
  ✅ No magic numbers — use named constants
  ✅ Events emitted correctly

Run: forge test --match-test [name]
ALL previous tests must still pass.

Output:
- Solidity code added
- forge test output (ALL PASS)
- Gas: forge test --gas-report for this function
```

---

### 🔵 MAYBE REFACTOR — evaluate, do not refactor on principle

```
You are smart-contract-engineer.
MAYBE REFACTOR PHASE:

Evaluate:
1. Duplication detected? → extract an internal function
2. Magic number? → pull it out into a constant
3. Wrong layer? (logic in the test instead of the contract) → move it
4. Gas optimizable without changing behavior? → optimize

If everything is fine → SKIP. Justify the skip.
Never refactor if it changes observable behavior.
Run forge test after every refactoring change.
```

---

### ✅ Commit and move to next item

```bash
git add .
git commit -m "test([contract]): [behavior under test]"
```

Check the item off in tasks/current_task.md. Next item → back to RED.

---

## Phase 3 — Verify (test list exhausted)

```bash
# All levels
forge test                          # unit + integration
forge test --fork-url $MAINNET_RPC  # fork tests
forge test --match-contract Invariant # invariant tests

# Gas snapshot
forge snapshot

# Slither if installed
slither . --config-file slither.config.json
```

---

## Phase 4 — Final review (all agents)

Spawn ALL agents in parallel on the full diff. Apply team--skill-refine until unanimous APPROVE.

Update tasks/current_task.md: status=IDLE

```
✅ Implementation complete: $ARGUMENTS
Tests: unit [N] + integration [N] + fork [N] + invariant [N]
Gas snapshot: saved
Final review: unanimous APPROVE
Ready for: /pr $ARGUMENTS
```
