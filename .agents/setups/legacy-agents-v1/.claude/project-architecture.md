# Project Architecture

<!-- last-verified: YYYY-MM-DD -->
<!-- STALENESS RULE: if today - last-verified > 30 days → STALE.
     Explore the codebase directly. Do not trust the doc. -->

## Overview

<!-- What the application does, who uses it, what value it delivers.
     Include: estimated age, team history if known. -->

## Codebase Status

<!-- Honest assessment of the current codebase.
     Example:
     - Coverage: ~12%
     - Last major rewrite: 2019
     - Stable zones: [list]
     - Zones to avoid: [list]
     - Dead dependencies: [list]
     - Dominant patterns: [e.g. God Classes, Spaghetti, Copy-paste] -->

## Module Map

<!-- Main modules, their supposed responsibility, their state.
     Example:
     src/
     ├── UserManager.php     — auth + profile + billing + emails (GOD CLASS)
     ├── OrderProcessor.php  — orders + stock + PDF + email sending
     ├── utils/              — 847 unsorted utility functions
     └── legacy/             — do not touch, especially not this -->

## Known Entry Points

<!-- How requests enter the system.
     Example:
     - HTTP: index.php → router.php → controllers/
     - Cron: cron/ → jobs/
     - CLI: bin/ → commands/ -->

## Risk Zones

<!-- Code that must not be touched without a full safety net.
     Example:
     - billing/: billing logic, no tests, 4000 lines
     - auth/: custom sessions, fragile
     - imports/: ETL that runs in production at night -->

## External Dependencies

<!-- Critical services, APIs, libraries.
     Include versions and maintenance status. -->

## What Works

<!-- What is stable and must not be touched without reason. -->

## What Is Broken / Worked Around

<!-- Known workarounds, known uncorrected bugs, "normal but wrong" behaviors. -->
