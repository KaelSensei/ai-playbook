---
name: solidity-patterns
description: >
  Solidity security patterns, anti-patterns, proxy patterns, access control, and EIP reference.
  Auto-loaded by smart-contract-engineer, architect, spec-writer. Also invoke directly for any
  Solidity security question, proxy pattern selection, or EIP lookup.
---

# Solidity Patterns Reference

## Security Patterns

### Checks-Effects-Interactions (CEI)

Always in this order. State changes before any external call.

```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);    // CHECK
    balances[msg.sender] -= amount;             // EFFECT
    (bool ok,) = msg.sender.call{value: amount}("");  // INTERACT
    require(ok, "transfer failed");
}
// ❌ vulnerable: external call before state update → reentrancy
```

### Reentrancy Guard

```solidity
// Solidity 0.8.24+ (Cancun) — transient storage version (cheaper)
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
// Pre-Cancun fallback
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
```

### Pull Over Push

```solidity
// ❌ push — one failing recipient blocks everyone
function distribute(address[] calldata recipients, uint256[] calldata amounts) external {
    for (uint i; i < recipients.length; i++) {
        recipients[i].transfer(amounts[i]); // revert on one → all fail
    }
}
// ✅ pull — each user claims independently
mapping(address => uint256) public pending;
function claim() external {
    uint256 amount = pending[msg.sender];
    pending[msg.sender] = 0;                        // effect first
    (bool ok,) = msg.sender.call{value: amount}(""); // then interact
    require(ok);
}
```

### Integer Math

```solidity
// Solidity 0.8+ overflows revert by default ✅
// unchecked: only when overflow is logically impossible AND proven
// Rounding: always against the user, in favor of the protocol
uint256 fee = (amount * feeBps + 9999) / 10000;       // round up (protocol gets more)
uint256 userShare = (amount * userBps) / 10000;        // round down (user gets less)
// ❌ never divide before multiply
uint256 wrong = (amount / PRECISION) * rate;           // precision loss
uint256 correct = (amount * rate) / PRECISION;
```

## Access Control

### Roles (prefer over single Ownable for protocols)

```solidity
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
bytes32 public constant GUARDIAN_ROLE  = keccak256("GUARDIAN_ROLE");

// constructor:
_grantRole(DEFAULT_ADMIN_ROLE, multisig);
_grantRole(OPERATOR_ROLE, operatorAddress);
```

### Two-Step Ownership (never single-step for protocol ownership)

```solidity
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
```

## Proxy Patterns

### UUPS (preferred for new protocols)

- Upgrade logic lives in implementation (cheaper proxy calls)
- MUST override `_authorizeUpgrade` with access control
- Risk: forgetting `_authorizeUpgrade` → permanently locked

```solidity
function _authorizeUpgrade(address) internal override onlyOwner {}
```

### Transparent Proxy

- Admin cannot call implementation functions (prevents selector clash)
- Use when migrating from existing Transparent setup
- ProxyAdmin contract owns upgrade rights

### Storage Layout Rules (both patterns)

```solidity
// ❌ NEVER reorder or remove storage variables in upgrades
// ✅ ALWAYS append at end
// ✅ Use storage gaps: uint256[50] private __gap;
// ✅ Verify before deploy: forge inspect ContractV2 storage-layout
```

## Oracle Safety

### TWAP (use this, not spot price)

```solidity
// Uniswap V3 TWAP — manipulation-resistant
(int56[] memory tickCumulatives,) = pool.observe([secondsAgo, 0]);
int24 tick = int24((tickCumulatives[1] - tickCumulatives[0]) / int56(int32(secondsAgo)));
```

### Chainlink Freshness Check

```solidity
(, int256 price,, uint256 updatedAt,) = priceFeed.latestRoundData();
require(price > 0, "invalid price");
require(block.timestamp - updatedAt <= STALENESS_THRESHOLD, "stale oracle");
```

### Deviation Guard

```solidity
uint256 deviation = price > ref
    ? (price - ref) * 1e18 / ref
    : (ref - price) * 1e18 / ref;
require(deviation <= MAX_DEVIATION, "oracle deviation");
```

## Flash Loan Defense

```solidity
// ❌ spot price — manipulable in one tx via flash loan
uint256 price = token.balanceOf(pool) * 1e18 / pool.totalSupply();
// ✅ TWAP or price cached externally and updated with delay
uint256 price = _getTWAP(secondsAgo);
```

## EIP Quick Reference

| EIP      | What             | Watch out for                               |
| -------- | ---------------- | ------------------------------------------- |
| ERC-20   | Fungible token   | Check return value; fee-on-transfer tokens  |
| ERC-721  | NFT              | `safeTransferFrom` calls `onERC721Received` |
| ERC-1155 | Multi-token      | Batch ops; id collision attacks             |
| ERC-4626 | Tokenized vault  | Share/asset rounding critical               |
| EIP-712  | Typed signatures | Domain separator; cross-chain replay        |
| EIP-2612 | Permit           | Front-runnable; use carefully               |
| EIP-1967 | Proxy storage    | Standard slots for implementation/admin     |
| EIP-3156 | Flash loans      | Callback caller must be verified            |

## Vulnerability Quick Reference

| Class                     | Check                                |
| ------------------------- | ------------------------------------ |
| Reentrancy                | CEI + guard on all value functions   |
| Flash loan                | No spot price reads                  |
| Signature replay          | Nonce + domain separator in EIP-712  |
| Front-running             | Commit-reveal or slippage + deadline |
| ERC-4626 inflation        | Virtual shares offset (OZ default)   |
| Donation attack           | Never use `balanceOf` as totalAssets |
| Sandwich                  | Slippage tolerance + deadline        |
| Precision loss            | No div before mul                    |
| `tx.origin` auth          | Never — phishing vector              |
| Delegatecall to untrusted | Never — full storage access          |
