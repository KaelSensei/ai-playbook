---
name: debugging-methodology
description:
  Systematic root-cause analysis methodology for persistent bugs. Use when standard fixes fail and
  deep investigation is needed.
---

# Debugging Methodology

A structured approach to finding and fixing root causes when simple debugging has not worked.

## When to use this skill

- When running `/magic-wand`.
- When a bug persists after multiple fix attempts.
- When the user says "I've tried everything" or "this keeps coming back."

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`debugging-methodology` skill."

- **Automatic:** The AI loads this skill when a bug persists after standard fix attempts.
- **Referenced by:** `/magic-wand` -- the command delegates the investigation methodology to this
  skill. `/fix` may also reference it for complex issues.

## Mindset

- Fix the **root cause**, not the symptom.
- The bug is probably **not** in the file you think it is.
- Recent changes are the most likely culprit.
- Configuration changes cause more subtle bugs than code changes.

## Step 1: Gather evidence

1. **Exact symptom**: What happens vs. what should happen?
2. **Reproduction**: When does it happen? Always, or only sometimes?
3. **Timeline**: When did it start? What changed around that time?
4. **Prior attempts**: What has been tried? Why didn't it work?

## Step 2: Review recent history

```bash
git log --oneline -30
```

Look for:

- Changes in **configuration files** (build config, network config, env).
- Dependency updates (`package.json`, lock files).
- Refactors that changed assumptions.
- Changes in files **related to** (not just in) the affected area.

## Step 3: Widen the search

Don't just look at the file where the bug manifests. Check:

- **Configuration files** -- build settings, security config, environment.
- **State management** -- providers, context, global state.
- **Navigation/routing** -- screen mounting, params, lifecycle.
- **Database layer** -- transactions, migrations, schema.
- **Middleware/utilities** -- shared helpers, interceptors, wrappers.

## Step 4: Trace execution end-to-end

Read ALL related files completely (not just snippets):

1. Follow data from source to destination.
2. Check every state update and side effect.
3. Verify async operations complete and are awaited.
4. Look for race conditions and timing issues.

## Step 5: Common root causes

### Configuration

- Security config blocking connections (e.g. network security, CORS).
- Build config changing behavior between dev/release.
- Environment variables missing or wrong.

### State management

- Missing dependencies in hooks (stale closures).
- State not updating because of reference equality.
- Context provider not wrapping the right subtree.

### Async and timing

- Promise not awaited.
- Race condition between two async operations.
- Event listener firing before data is ready.
- Cleanup function missing (memory leak, stale subscription).

### Navigation

- Screen not remounting when expected.
- Params not updating on re-navigation.
- Focus/blur events not firing.

### Database

- Transaction not committed.
- Query returning stale data (caching).
- Schema mismatch after migration.

## Step 6: Document reasoning

Before implementing a fix, write down:

1. **Root cause**: What is actually wrong and why.
2. **Why previous fixes failed**: What they missed.
3. **Proposed fix**: What to change and in which files.
4. **Verification**: How to confirm the fix works.

## Anti-patterns

- Fixing the symptom without understanding the cause.
- Only looking at the reported file.
- Guessing instead of tracing execution.
- Adding workarounds instead of fixing the real problem.
- Not checking configuration and environment.
