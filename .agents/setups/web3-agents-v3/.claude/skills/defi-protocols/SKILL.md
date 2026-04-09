---
name: defi-protocols
description: >
  DeFi protocol patterns, known attack vectors, AMM math, lending mechanics, ERC-4626, staking,
  governance, bridges. Auto-loaded by smart-contract-engineer, backend-engineer, architect when task
  involves DeFi. Also invoke directly for any DeFi design question or known exploit pattern lookup.
---

# DeFi Protocols Reference

## AMM

### Constant Product (x\*y=k)

```solidity
// invariant: reserve0 * reserve1 >= k (after fees)
amountOut = (amountIn * 997 * reserveOut) / (reserveIn * 1000 + amountIn * 997);
```

Attack vectors:

- **Sandwich**: front-run + back-run → enforce slippage + deadline
- **Donation**: direct token transfer inflates reserves → use cached reserve not `balanceOf`
- **Flash loan**: borrow → inflate spot price → exploit → repay → use TWAP

### Concentrated Liquidity (Uniswap V3)

- Price = `sqrtPriceX96²` in Q64.96 fixed point
- Liquidity active only in `[tickLower, tickUpper]`
- `sqrtPriceX96` manipulable via flash swap → always use TWAP for oracle

### Curve StableSwap

- Amplification `A` controls slippage near peg (higher A = less slippage)
- Admin can ramp A → ramp delay must be observed (attack vector if instant)

## Lending

### Health Factor

```
HF = (collateralValue × liquidationThreshold) / borrowedValue
Liquidatable when HF < 1
```

Attack vectors:

- Oracle manipulation: inflate collateral → borrow more → drain
- Flash loan: borrow → manipulate oracle → drain → repay
- Governance: change oracle address to attacker-controlled

### Liquidation

- Liquidation bonus creates MEV — bots race on every unhealthy position
- Max liquidation per tx: typically 50% (Aave pattern) to limit MEV
- Bad debt: if collateral < debt after liquidation → protocol absorbs loss

## ERC-4626 Tokenized Vault

### Share / Asset Math

```solidity
// Deposits: round DOWN shares (user gets less)
shares = assets * totalSupply / totalAssets;
// Withdrawals: round DOWN assets (user gets less)
assets = shares * totalAssets / totalSupply;
// Always round AGAINST the user, IN FAVOR of the vault
```

### Inflation Attack (first deposit)

```solidity
// Attack: deposit 1 wei → donate large amount → 1 share = large value
//         → second depositor rounds to 0 shares → loses everything
// Defense: virtual offset (OpenZeppelin default)
uint256 supply  = _totalSupply + 10 ** decimalsOffset;  // virtual shares
uint256 assets_ = _totalAssets + 1;                     // virtual assets
```

### Donation Attack

```solidity
// ❌ inflatable via direct transfer
uint256 totalAssets = token.balanceOf(address(this));
// ✅ track in storage, update only on deposit/withdraw
uint256 totalAssets = _storedTotalAssets;
```

## Staking / Yield (Synthetix reward pattern)

```solidity
// rewardPerToken: cumulative rewards per staked token
// earned by user: balance × (rewardPerToken - userCheckpoint) + pending

function rewardPerToken() public view returns (uint256) {
    if (totalSupply == 0) return rewardPerTokenStored;
    return rewardPerTokenStored +
        (block.timestamp - lastUpdateTime) * rewardRate * 1e18 / totalSupply;
}
// Gotcha: new reward period must start AFTER old one ends or rate math breaks
// Gotcha: precision loss accumulates with small stakes over long periods
```

## Governance

### Attack Vectors

- **Flash loan vote**: borrow tokens → vote → repay (same tx) → defense: snapshot at proposal block,
  not current block
- **Proposal spam**: enforce minimum tokens to propose
- **Timelock bypass**: check for delegatecall in timelock targets
- **Short lock**: timelock delay must exceed time to coordinate defense

### Safe Timeline

```
Propose (block N) → [Voting Delay] → [Voting Period] → [Timelock] → Execute
Minimum safe:         1 day            3 days            2 days
```

## Cross-Chain / Bridges

### Message Trust Model

| Type                | Mechanism          | Finality | Risk                         |
| ------------------- | ------------------ | -------- | ---------------------------- |
| Optimistic          | Fraud proof        | 7 days   | Challenge window must elapse |
| ZK                  | Validity proof     | Minutes  | Proof system correctness     |
| External validators | Oracle/relayer set | Minutes  | Validator set compromise     |

### Common Bridge Exploits

- **Signature forgery**: insufficient validator count check
- **Replay**: missing nonce + chain ID in message hash
- **Accounting**: minted on dest > locked on source
- **Admin key**: upgrade bridge contract to drain funds

### Bridge Message Hash Pattern

```solidity
bytes32 msgHash = keccak256(abi.encodePacked(
    block.chainid,          // source chain
    dstChainId,             // destination chain
    nonce,                  // prevents replay
    sender,
    recipient,
    amount
));
```

## Historical Exploits (study these patterns)

| Protocol        | Year | Vector                          | Loss  |
| --------------- | ---- | ------------------------------- | ----- |
| The DAO         | 2016 | Reentrancy                      | $60M  |
| bZx             | 2020 | Flash loan + spot oracle        | $1M   |
| Harvest Finance | 2020 | Flash loan price manipulation   | $34M  |
| Compound        | 2021 | DAI oracle manipulation         | $90M  |
| Poly Network    | 2021 | Cross-chain signature bypass    | $611M |
| Ronin           | 2022 | Validator key compromise        | $625M |
| Euler Finance   | 2023 | Donation + bad debt             | $197M |
| Curve           | 2023 | Vyper reentrancy (compiler bug) | $73M  |
| Radiant Capital | 2024 | Flash loan + rounding           | $58M  |
