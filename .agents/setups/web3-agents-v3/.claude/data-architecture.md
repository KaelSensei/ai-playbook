# Data Architecture

<!-- last-verified: YYYY-MM-DD -->
<!--
  STALENESS RULE: if today - last-verified > 30 days → STALE.
  Verify against actual contract ABIs and subgraph schema before reasoning from this doc.
-->

## On-Chain State Schema

<!--
  Document storage layout for all core contracts.
  Critical for detecting storage collision in upgrades.
  Example:

  Vault.sol storage layout:
  slot 0: uint256 totalAssets
  slot 1: uint256 totalShares
  slot 2: mapping(address => uint256) balances
  slot 3: mapping(address => uint256) lastDeposit
  slot 4-53: uint256[50] __gap  (UUPS gap)
-->

## Events

<!--
  All events emitted by contracts. This is the source of truth
  for what the indexer can consume.
  Example:

  event Deposited(address indexed user, uint256 assets, uint256 shares);
  event Withdrawn(address indexed user, uint256 assets, uint256 shares);
  event Paused(address indexed by);
  event Unpaused(address indexed by);
  event OwnershipTransferred(address indexed from, address indexed to);
-->

## Indexer Schema

<!--
  GraphQL / Ponder entity definitions.
  Example:

  type User @entity {
    id: ID!               # wallet address
    shareBalance: BigInt!
    totalDeposited: BigInt!
    totalWithdrawn: BigInt!
    lastActivityAt: BigInt!
  }

  type Deposit @entity {
    id: ID!               # txHash-logIndex (stable across reorgs)
    user: User!
    assets: BigInt!
    shares: BigInt!
    timestamp: BigInt!
    blockNumber: BigInt!
  }

  type VaultSnapshot @entity {
    id: ID!               # block number
    totalAssets: BigInt!
    totalShares: BigInt!
    pricePerShare: BigDecimal!
    timestamp: BigInt!
  }
-->

## Data Flow

<!--
  How data moves from chain to consumer.
  Example:

  On-chain events
      │
  Event handler (AssemblyScript / TypeScript)
      │  validate → transform → handle reorgs
  Subgraph store / Ponder DB
      │
  GraphQL API
      ├─► Frontend (queries + subscriptions)
      └─► Analytics / dashboards
-->

## Reorg Handling

<!--
  At what depth do we assume finality?
  Example:
  - Mainnet: 12 blocks
  - Base: 10 blocks
  - Entity IDs use txHash-logIndex (stable across reorgs)
  - Ponder: native rollback + replay
  - The Graph: handlers must be idempotent (re-delivery possible)
-->

## Data Freshness Targets

<!--
  Data               | Target lag | Alert threshold
  User balances      | < 30s      | > 5 min
  Vault snapshots    | < 1 block  | > 10 blocks
  Price per share    | < 1 block  | > 5 blocks
-->

## API Catalog

<!--
  Key queries the frontend uses.
  Example:

  # Latest vault state
  query VaultState {
    vaultSnapshot(id: "latest") { totalAssets totalShares pricePerShare }
  }

  # User portfolio
  query UserPortfolio($address: String!) {
    user(id: $address) { shareBalance totalDeposited totalWithdrawn }
  }

  # Recent activity
  query RecentDeposits($limit: Int!) {
    deposits(first: $limit orderBy: timestamp orderDirection: desc) {
      user { id } assets shares timestamp
    }
  }
-->

## Pipeline Configs

<!--
  Document any ETL pipelines, cron jobs, keeper bots, or scheduled tasks.
  Include: trigger, source, destination, failure mode.
-->
