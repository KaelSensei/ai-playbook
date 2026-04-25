---
name: security-web3
description: >
  Smart contract security for EVM and Solidity ^0.8 — reentrancy, signature replay, access control,
  oracle manipulation, MEV/sandwich, integer/precision issues, upgradeability hazards,
  ERC-20/721/4626 pitfalls, bridge & cross-chain risks. Auto-loaded by
  smart-contract-security-reviewer. Invoke for any on-chain security question, exploit pattern
  lookup, or pre-deployment review.
---

# Security Web3 Reference

> Smart contracts are adversarial by default. Once deployed, code is public, immutable (or
> upgradeable with its own risks), and every external call is a hostile actor. Assume every input is
> attacker-controlled, every external contract is malicious, and every oracle can be manipulated.

## Threat Model

| Surface                     | Attacker capabilities                                                  |
| --------------------------- | ---------------------------------------------------------------------- |
| `external` / `public` calls | Arbitrary calldata, MEV ordering, sandwich, frontrun                   |
| External contract calls     | Reentrancy, malicious tokens (fee-on-transfer, rebasing), revert bombs |
| Oracles                     | Spot-price manipulation via flashloan-funded swaps                     |
| Signatures                  | Replay across chains/contracts, malleability, signer collisions        |
| Admin keys                  | Compromise → full drain; multisig and timelock are mitigations         |
| Upgradeability              | Storage collision, uninitialized implementation, selector clash        |
| Cross-chain / bridges       | Replay, double-spend, finality assumptions, relayer trust              |

## Top Vulnerability Classes

### 1. Reentrancy

```solidity
// ❌ State updated AFTER external call — classic reentrancy
function withdraw(uint amount) external {
    require(balances[msg.sender] >= amount);
    (bool ok,) = msg.sender.call{value: amount}("");      // <-- attacker re-enters
    require(ok);
    balances[msg.sender] -= amount;                       // too late
}

// ✅ Checks-Effects-Interactions
function withdraw(uint amount) external {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount;                       // effect first
    (bool ok,) = msg.sender.call{value: amount}("");      // interaction last
    require(ok);
}

// ✅ Reentrancy guard (use OZ ReentrancyGuard, not a hand-rolled one)
function withdraw(uint amount) external nonReentrant { ... }
```

Watch for **read-only reentrancy** too: a view function returning stale state mid-call can mislead
integrators (Curve LP price, Balancer pools, etc.).

### 2. Access Control

```solidity
// ❌ Missing modifier
function setOwner(address newOwner) external { owner = newOwner; }

// ❌ tx.origin (phishing-prone)
require(tx.origin == owner);

// ✅ msg.sender + explicit modifier, OZ AccessControl or Ownable
modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }
function setOwner(address newOwner) external onlyOwner { ... }

// ✅ Two-step ownership transfer (OZ Ownable2Step) — prevents typo'd transfer to dead address
```

Audit every `external`/`public` function for the right modifier. `initialize()` on upgradeable
contracts MUST be guarded by `initializer` and the implementation MUST be initialized at deploy time
(or `_disableInitializers()` in constructor).

### 3. Oracle Manipulation

```solidity
// ❌ Spot price from a single AMM pair — flashloanable
uint price = pair.getReserves(); // attacker swaps, calls you, swaps back

// ✅ Use a TWAP (Uniswap V3 oracle) or Chainlink with staleness check
(, int answer,, uint updatedAt,) = chainlinkFeed.latestRoundData();
require(answer > 0, "bad price");
require(block.timestamp - updatedAt < MAX_STALENESS, "stale price");
require(answerInRound >= roundId, "stale round");
```

Never price an asset off the same pool you're transacting against. Validate decimals, heartbeat, and
the round.

### 4. Signature Replay & EIP-712

```solidity
// ❌ Reusable across chains and across contracts
bytes32 hash = keccak256(abi.encode(user, amount, nonce));

// ✅ EIP-712 domain separator binds to chain + contract
bytes32 DOMAIN = keccak256(abi.encode(
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
    keccak256(bytes(NAME)), keccak256(bytes(VERSION)),
    block.chainid, address(this)
));

// ✅ Track and increment per-user nonce; reject reused nonces
mapping(address => uint) public nonces;
require(nonce == nonces[user]++, "bad nonce");

// ✅ Use OZ ECDSA.recover (rejects malleable s) — never raw ecrecover with unchecked s
address signer = ECDSA.recover(digest, signature);
```

Watch chain forks: a sig valid pre-fork remains valid post-fork unless `chainid` is in the domain.

### 5. Integer & Precision

```solidity
// 0.8+ has built-in overflow checks — but division, ordering, and downcasts still bite

// ❌ Division before multiplication loses precision
uint share = (amount / total) * pool;

// ✅ Multiply first, then divide
uint share = (amount * pool) / total;

// ❌ Silent downcast
uint128 small = uint128(largeUint256); // truncates

// ✅ SafeCast
using SafeCast for uint256;
uint128 small = largeUint256.toUint128();

// ❌ unchecked block hides legitimate overflow
unchecked { total += untrustedAmount; }
```

Round in your favor on protocol-side math (favor the protocol vault, not the user). Document the
rounding direction at every division.

### 6. ERC-20 Pitfalls

- **Fee-on-transfer**: balance after `transferFrom` ≠ amount sent. Compute
  `balanceAfter - balanceBefore`.
- **Rebasing tokens**: balances change without transfers. Don't assume invariants.
- **USDT**: missing return value. Use `SafeERC20.safeTransfer`/`safeApprove`.
- **Approval race**: ERC-20 `approve(x→y)` is racy. Use `forceApprove` or `0 → y`.
- **Blacklist tokens** (USDC/USDT): a recipient may revert. Don't gate withdrawals on a single
  recipient.
- **Self-transfer**: `transferFrom(A, A, n)` valid but counter-intuitive. Don't assume sender ≠
  recipient.
- **Decimals**: don't assume 18.

### 7. ERC-4626 / Vaults

- Inflation/donation attack on first depositor — mitigate with virtual shares (OZ default) or a
  protocol-seeded initial deposit.
- `previewDeposit` vs actual `deposit` mismatch under fee-on-transfer assets.
- Round shares **down** on deposit, **up** on withdraw (favor the vault).

### 8. Upgradeability

```solidity
// ✅ UUPS or Transparent proxy (OZ). Always:
//    - constructor() { _disableInitializers(); }
//    - storage gap: uint256[50] private __gap; on each upgradeable parent
//    - new variables APPENDED only — never reorder or remove
//    - run `forge inspect ContractV2 storageLayout` and diff against V1
//    - timelock + multisig on upgrade authority
```

Selector collision in Transparent proxies: any function selector matching `upgradeTo` etc. on the
proxy admin is unreachable on the implementation. Diamonds (EIP-2535) have their own selector clash
risk.

### 9. MEV / Frontrunning

- Public mempool = adversarial. Slippage params are mandatory for swaps (`amountOutMin`,
  `deadline`).
- Commit-reveal for sensitive actions (auctions, liquidations).
- Avoid putting profitable pure on-chain logic in plain `external` calls — use Flashbots, sealed
  bids, or off-chain proofs where appropriate.
- `block.timestamp` and `blockhash` are weak randomness — use Chainlink VRF or commit-reveal.

### 10. External Calls

```solidity
// ❌ Trusting external return is gas-bombable and reentrancy-prone
target.call(data);

// ✅ Bound gas, check return, isolate state
(bool ok, bytes memory ret) = target.call{gas: 100_000}(data);
if (!ok) revert ExternalCallFailed(ret);
```

A `call` to a contract that uses all gas (`assert(false)`) bricks your tx. Cap gas on untrusted
calls. Beware revert-bombs returning megabytes of revert data.

## Pre-Deployment Checklist

```
[ ] All external/public functions reviewed for access control modifier
[ ] Checks-Effects-Interactions on every state-changing function
[ ] OZ ReentrancyGuard on functions that make external calls before state finalization
[ ] No tx.origin checks
[ ] EIP-712 domain with chainid + contract address; per-user nonces tracked
[ ] ECDSA.recover (not raw ecrecover); s-malleability rejected
[ ] Oracle staleness + round + decimals validated; TWAP for AMM-derived prices
[ ] SafeERC20 for all token transfers; balanceBefore/After for fee-on-transfer support
[ ] All math: multiply-before-divide; SafeCast on downcast; rounding documented
[ ] Upgradeable: _disableInitializers, storage gaps, append-only layout, timelocked admin
[ ] Slippage + deadline on swaps; no spot-price-only oracles
[ ] No block.timestamp/blockhash for randomness
[ ] External call gas bounded; revert-bomb resistant
[ ] Invariant tests (Foundry) pass under fuzz at >= 100k runs
[ ] Slither, Mythril (or echidna/medusa fuzzing) clean or triaged
[ ] Forked-mainnet integration test against real upstream protocols
[ ] Admin keys: multisig + timelock; emergency pause documented
[ ] Verified source on block explorer at deploy
```

## Known Exploit Pattern Index

| Pattern                        | Where to look                                 | Quick test                                             |
| ------------------------------ | --------------------------------------------- | ------------------------------------------------------ |
| Reentrancy                     | External calls before state writes            | Foundry: malicious receiver re-enters                  |
| Read-only reentrancy           | Views called by integrators mid-tx            | Reorder in test: read during external hook             |
| Price oracle (flashloan)       | `getReserves()`, single-pool spot             | Fork test with flashloan + swap + your fn              |
| Signature replay               | Missing chainid / nonce in digest             | Replay same sig on a forked chain                      |
| First-depositor inflation      | ERC-4626 without virtual shares               | Deposit 1 wei → donate → next depositor → 0            |
| Approval race                  | `approve(spender, x)` then `(spender, y)`     | Sandwich the approval                                  |
| Storage collision (proxy)      | New parent inserted in inheritance            | `forge inspect` diff between versions                  |
| Uninitialized implementation   | Logic contract without `_disableInitializers` | Anyone calls `initialize()` directly                   |
| Missing slippage               | `swapExactTokensForTokens` with `0`           | Sandwich in fork test                                  |
| `tx.origin` auth               | `require(tx.origin == ...)`                   | Phishing contract that proxies the call                |
| Unchecked external call return | `target.call(data);` no `ok` check            | Make target revert and observe state                   |
| Self-destruct receipt          | Force-send via `selfdestruct`                 | Don't depend on `address(this).balance` for accounting |

## Operational Hygiene

- Verify and publish source immediately after deploy.
- Pin compiler version exactly (`pragma solidity 0.8.24;`, not `^`).
- No `console.log` or `Hardhat`-only imports in production code.
- No hardcoded chain IDs or addresses across networks — use a config struct keyed by chainid.
- Emit events on every state change that integrators may need to index.
- Document invariants in NatSpec; encode them as Foundry invariant tests.
