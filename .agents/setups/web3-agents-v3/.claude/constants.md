# Constants

<!-- last-verified: YYYY-MM-DD -->
<!--
  Update this file whenever:
  - A contract is deployed or upgraded
  - A new chain is added
  - ABI changes are shipped
  - Environment variables change
-->

## Chain IDs

| Network           | Chain ID | RPC env var             |
| ----------------- | -------- | ----------------------- |
| Ethereum mainnet  | 1        | `MAINNET_RPC_URL`       |
| Base              | 8453     | `BASE_RPC_URL`          |
| Sepolia (testnet) | 11155111 | `SEPOLIA_RPC_URL`       |
| Anvil (local)     | 31337    | `http://127.0.0.1:8545` |

---

## Contract Addresses

### Mainnet (Chain ID: 1)

```
VAULT_ADDRESS=0x
ROUTER_ADDRESS=0x
REGISTRY_ADDRESS=0x
PROXY_ADMIN=0x
TIMELOCK=0x
MULTISIG=0x
```

### Base (Chain ID: 8453)

```
VAULT_ADDRESS=0x
ROUTER_ADDRESS=0x
```

### Sepolia (Chain ID: 11155111)

```
VAULT_ADDRESS=0x
ROUTER_ADDRESS=0x
```

---

## External Protocol Addresses (Mainnet)

```
USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
UNISWAP_V3_FACTORY=0x1F98431c8aD98523631AE4a59f267346ea31F984
CHAINLINK_ETH_USD=0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
```

---

## Environment Variables

```bash
# Node providers
MAINNET_RPC_URL=
BASE_RPC_URL=
SEPOLIA_RPC_URL=

# Deployment (NEVER commit these values)
DEPLOYER_PRIVATE_KEY=
ETHERSCAN_API_KEY=
BASESCAN_API_KEY=

# Indexer
GRAPH_NODE_URL=
SUBGRAPH_NAME=

# Frontend (public — safe to expose)
NEXT_PUBLIC_VAULT_ADDRESS=
NEXT_PUBLIC_CHAIN_ID=
NEXT_PUBLIC_ALCHEMY_ID=
```

---

## Toolchain Versions

```
solc:    0.8.24
foundry: (pin with: foundryup --version x.x.x)
node:    20.x LTS
wagmi:   2.x
viem:    2.x
```

---

## Timelock Delays

| Operation         | Delay | Who can execute         |
| ----------------- | ----- | ----------------------- |
| Contract upgrade  | 48h   | Multisig after timelock |
| Parameter change  | 24h   | Multisig after timelock |
| Emergency pause   | 0     | Guardian only           |
| Emergency unpause | 24h   | Multisig after timelock |

---

## Block Explorers

| Network | URL                            |
| ------- | ------------------------------ |
| Mainnet | `https://etherscan.io`         |
| Base    | `https://basescan.org`         |
| Sepolia | `https://sepolia.etherscan.io` |
