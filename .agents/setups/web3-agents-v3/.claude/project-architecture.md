# Project Architecture

<!-- last-verified: YYYY-MM-DD -->
<!--
  STALENESS RULE (agents must enforce):
  If today - last-verified > 30 days → this doc is STALE.
  Do NOT reason from stale docs. Instead:
    1. Note the staleness explicitly in your output
    2. Explore the codebase directly to verify
    3. Flag discrepancies — do not silently update
-->

## System Overview

<!--
  Fill in: what does this protocol do, who uses it,
  what value does it hold, which chains does it run on.
  1-2 paragraphs max.
-->

## Component Map

<!--
  Describe the components and how they connect.
  Keep it as a simple diagram or bullet list.
  Example:

  Frontend (Next.js + wagmi)
      │ signs tx / reads state
  Contracts (Foundry / Solidity)
      │ emits events
  Indexer (The Graph / Ponder)
      │ serves GraphQL
  Frontend / API consumers
-->

## Contract Directory

<!--
  List the main contracts, their role, and their risk level.
  Example:
  contracts/
  ├── core/
  │   ├── Vault.sol        — holds user funds (HIGH RISK)
  │   ├── Router.sol       — entry point for all user actions
  │   └── Registry.sol     — tracks deployed instances
  ├── interfaces/
  └── libraries/
-->

## Trust Model

<!--
  Who can do what. Be explicit. Example:
  - Owner (multisig 0x...): upgrade, pause, set params
  - Operators (list): execute batches
  - Users: untrusted — all inputs validated on-chain
  - External contracts: any address can call public functions → treat as adversarial
-->

## Key Invariants

<!--
  What MUST always be true regardless of any action.
  Agents check these on every change.
  Example:
  - Sum of user balances == totalAssets at all times
  - No reentrancy across vault state changes
  - Paused state: only withdrawals permitted
  - Share price never decreases
-->

## External Dependencies

<!--
  Protocol / library | Version | Risk | Failure mode
  Example:
  Chainlink oracle   | —       | Price manipulation | TWAP fallback if deviation > 1%
  USDC (ERC-20)      | —       | Blacklist          | Handle failed transfer
  Uniswap V3         | —       | Flash loans        | Treat as untrusted caller
  OpenZeppelin       | ^5.x    | —                  | Pin version, monitor advisories
-->

## Deployment Addresses

<!--
  Network    | Contract | Address
  Mainnet    | Vault    | 0x...
  Base       | Vault    | 0x...
  Sepolia    | Vault    | 0x...
-->

## Upgrade Strategy

<!--
  Example:
  Pattern: UUPS proxy
  Admin: 3/5 multisig
  Timelock: 48h for upgrades, 24h for param changes
-->

## Known Limitations / Out of Scope

<!--
  What this system intentionally does NOT handle.
  Explicit scope boundary prevents scope creep during implementation.
-->
