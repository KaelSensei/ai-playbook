---
name: technical-debt
description: >
  Technical debt taxonomy, metrics, prioritization, business communication. Auto-loaded by
  debt-tracker, tech-lead, legacy-analyst. Invoke to audit, quantify, or prioritize debt.
---

# Technical Debt Reference

## Taxonomy (Ward Cunningham + Martin Fowler)

```
                    DELIBERATE         ACCIDENTAL
PRUDENT    │ "We know we are    │ "We now understand │
           │  making a trade-   │  we should have    │
           │  off to ship       │  done it better"   │
           │  fast"             │                    │
───────────┼─────────────────────┼─────────────────────┤
RECKLESS   │ "We don't have     │ "We didn't even    │
           │  time to do it     │  know we were      │
           │  properly"         │  doing it wrong"   │
```

**Deliberate + Prudent**: acceptable if documented and planned for repayment. **Deliberate +
Reckless**: dangerous, accumulates without a plan. **Accidental + Prudent**: normal, team learning.
**Accidental + Reckless**: the most dangerous, invisible.

## Concrete Metrics

### Hotspot Analysis (Adam Tornhill)

```bash
# Most-modified files = likely debt
git log --name-only --format="" | grep -v "^$" | sort | uniq -c | sort -rn | head -20

# Combined with complexity = refactoring priority
# Frequently modified AND complex file = pay back first
```

### Cyclomatic Complexity

```bash
# PHP
phploc src/ --log-csv metrics.csv

# Python
radon cc src/ -a

# JavaScript
npx complexity-report src/

# Thresholds:
# 1-10   : simple
# 11-20  : moderate (watch)
# 21-50  : complex (test rigorously)
# > 50   : danger (pay back in priority)
```

### Duplication

```bash
# PHP
phpcpd src/ --min-lines 5

# Python
pylint --disable=all --enable=duplicate-code src/

# JavaScript
jscpd src/

# > 20% duplication = significant debt
```

## Cost of Debt

```
Main cost = Interest
Debt does not cost at time T.
It costs every time you touch that code afterwards.

Principal = effort to repay
Interest = extra effort per feature because of the debt

If interest > 0 for each feature → pay back now
If interest ≈ 0 (code rarely touched) → accept
```

## Prioritization

```
Score = Impact / Effort

Impact (1-5):
  5 = blocks deployments or causes prod bugs
  4 = significantly slows each feature
  3 = frequent source of confusion and errors
  2 = annoying but manageable
  1 = cosmetic

Effort (1-5):
  1 = < 1h (rename, simple extraction)
  2 = 1 day (module refactoring)
  3 = 1 week (component refactoring)
  4 = 1 month (module split)
  5 = > 1 month (partial rewrite)

Matrix:
Impact high / Effort low  = pay back now
Impact high / Effort high = plan (Strangler Fig)
Impact low  / Effort low  = Boy Scout Rule (in passing)
Impact low  / Effort high = accept and document
```

## Business Communication

```
Don't say: "We have technical debt to pay back"
Do say: "Each new feature in this module takes 3x longer than
        elsewhere. If we invest 2 weeks now, the next 12 features
        will go 3x faster."

Don't say: "The code is dirty"
Do say: "3 prod bugs this month came from the same module.
        Paying back this debt would reduce incidents by ~50%."

Always translate into: time saved, bugs avoided, features unblocked.
```

## Boy Scout Rule

```
Leave the code a little better than you found it.
No unsolicited grand refactoring.
Just: rename an obscure variable, extract a 5-line function,
remove an obsolete comment.
Accumulated over months, it changes everything.
```
