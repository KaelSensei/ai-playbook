# Data Architecture

<!-- last-verified: YYYY-MM-DD -->

## Database Status

<!-- Honest assessment.
     Example:
     - 287 tables, of which ~40 actively used
     - No FKs in production (disabled for "performance")
     - TEXT columns for everything (int, date, json stored as TEXT)
     - No formal migrations: direct ALTER TABLE in prod -->

## Main Tables

<!-- Critical tables, their actual role, their state.
     Example:
     users        — accounts, but also config, preferences, various flags
     orders       — orders + history + logs + temp data
     settings     — key/value table that replaces config (156 entries)
     temp_*       — temporary tables that were never deleted -->

## Existing Conventions (or absence of conventions)

<!-- What has been done, even if it's bad.
     Knowing existing conventions avoids breaking them accidentally.
     Example:
     - No soft delete: direct DELETE everywhere
     - IDs: AUTO_INCREMENT int (not UUID)
     - Dates: DATETIME without timezone (everything assumed UTC)
     - Passwords: MD5 (yes, really) -->

## Migrations

<!-- How DB changes have been made so far.
     Example:
     - No migration system
     - SQL scripts in /scripts/db/ (not all documented)
     - Some changes made directly in prod and never documented -->

## Sensitive Data

<!-- Where the sensitive data lives, how it is (poorly) protected. -->

## Critical / Known Queries

<!-- Important or dangerous queries to be aware of.
     Example:
     - The dashboard query loads 50k rows without pagination
     - The monthly report runs 45 min and locks tables -->
