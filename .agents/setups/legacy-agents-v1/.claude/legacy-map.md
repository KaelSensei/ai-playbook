# Legacy Map

<!-- last-verified: YYYY-MM-DD -->
<!--
  Living document. Updated by /understand and /characterize.
  It is the map of the territory — it is always incomplete,
  but it grows with each exploration.

  RULE: never delete an entry. Annotate if obsolete.
-->

## Mapped Modules

<!--
  Format per module:

  ### [module / file name]
  - **Location**: path/to/file
  - **Size**: ~N lines
  - **Actual role**: what it really does (based on the code, not the comments)
  - **Multiple responsibilities**: list if god class / god function
  - **Incoming dependencies**: who calls it
  - **Outgoing dependencies**: what it calls
  - **Existing tests**: yes / no / partial (file)
  - **Last modification**: date (git blame)
  - **Risk level**: green low / yellow medium / red high
  - **Notes**: important observations, identified traps
-->

## Identified Seams

<!--
  A "seam" (Michael Feathers) = a place where you can insert
  a control point without modifying the code around it.

  Format:
  - **[name]**: [description] — [how to exploit it]

  Example:
  - **Payment interface**: PaymentGateway.php — can be mocked via config
  - **Email sending**: global mailer — can be replaced with a fake in tests
-->

## Pinned Behaviors (Characterization Tests)

<!--
  List of behaviors documented by characterization tests.
  Updated by /characterize.

  Format:
  - [ ] [behavior] — [test file] — [date]

  Example:
  - [x] billing calculates 20% VAT on non-exempt products — test_billing_char.php — 2024-03-15
  - [ ] behavior when user has no email — not documented
-->

## Unexplored Zones

<!--
  What we know we don't know.
  Updated over the course of /understand runs.

  Example:
  - cron_sync.php — unknown purpose, runs in prod every hour
  - legacy_import/ — folder of 40 files, no reference found since 2021
-->

## Dangerous Couplings

<!--
  Circular dependencies, global state, magic session variables,
  anything that makes changes unpredictable.

  Format:
  - [coupling description] — [impact] — [files involved]
-->

## Inherited Decisions

<!--
  Past technical choices that we have understood (even if we would not agree today).
  Document the "why" when you find it.

  Example:
  - Prices are stored as integer cents — 2012 decision to avoid floats
  - The PHP session is used as a temporary database — workaround for slow MySQL
-->
