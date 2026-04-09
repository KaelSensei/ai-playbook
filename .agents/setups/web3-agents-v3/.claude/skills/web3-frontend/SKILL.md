---
name: web3-frontend
description: >
  wagmi v2, viem, wallet integration, tx UX state machine, EIP-712 signing, WebSocket cleanup,
  Multicall3. Auto-loaded by frontend-engineer. Also invoke directly for any wagmi/viem hook
  question, wallet connect setup, contract read/write pattern, or tx pending state handling.
---

# Web3 Frontend Reference (wagmi v2 + viem)

## Stack

- wagmi v2 + viem (native bigint, no ethers.js)
- TanStack Query v5 (built into wagmi v2)
- RainbowKit or ConnectKit for wallet UI
- TypeScript strict mode + wagmi codegen for ABI types

## Contract Reads

```typescript
import { useReadContract } from 'wagmi'
import { vaultAbi } from '@/generated'  // wagmi codegen

function UserBalance({ address }: { address: `0x${string}` }) {
  const { data, isLoading, error } = useReadContract({
    address: VAULT_ADDRESS,
    abi: vaultAbi,
    functionName: 'balanceOf',
    args: [address],
  })
  if (isLoading) return <Skeleton />
  if (error) return <Error message={decodeError(error)} />
  return <span>{formatUnits(data ?? 0n, 18)}</span>
}
```

## Batch Reads (Multicall3 — one RPC call)

```typescript
import { useReadContracts } from 'wagmi';

const { data } = useReadContracts({
  contracts: [
    { address: VAULT, abi: vaultAbi, functionName: 'totalAssets' },
    { address: VAULT, abi: vaultAbi, functionName: 'totalShares' },
    { address: TOKEN, abi: erc20Abi, functionName: 'balanceOf', args: [user] },
  ],
});
// data[0].result, data[1].result, data[2].result
```

## Transaction — Full 4-State Machine

```typescript
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'

function DepositButton({ amount }: { amount: bigint }) {
  const { writeContract, data: hash, isPending, error: writeError } = useWriteContract()
  const { isLoading: isConfirming, isSuccess, error: receiptError } =
    useWaitForTransactionReceipt({ hash })

  // States: idle | pending (wallet) | confirming (mempool) | success | error
  const label =
    isPending    ? 'Awaiting wallet signature…' :
    isConfirming ? 'Confirming on-chain…' :
    isSuccess    ? 'Deposited!' :
    'Deposit'

  return (
    <button
      disabled={isPending || isConfirming}
      onClick={() => writeContract({
        address: VAULT_ADDRESS,
        abi: vaultAbi,
        functionName: 'deposit',
        args: [amount],
      })}
    >
      {label}
    </button>
  )
}
```

## Error Decoding (never show raw hex to users)

```typescript
import { ContractFunctionRevertedError } from 'viem';

function decodeError(error: unknown): string {
  if (error instanceof ContractFunctionRevertedError) {
    return error.shortMessage; // viem auto-decodes ABI errors
  }
  if (error instanceof Error) return error.message;
  return 'Transaction failed';
}
```

## EIP-712 Structured Signing

```typescript
import { useSignTypedData } from 'wagmi';

const { signTypedData } = useSignTypedData();

signTypedData({
  domain: {
    name: 'MyProtocol',
    version: '1',
    chainId,
    verifyingContract: CONTRACT_ADDRESS,
  },
  types: {
    Permit: [
      { name: 'owner', type: 'address' },
      { name: 'spender', type: 'address' },
      { name: 'value', type: 'uint256' },
      { name: 'nonce', type: 'uint256' },
      { name: 'deadline', type: 'uint256' },
    ],
  },
  primaryType: 'Permit',
  message: { owner, spender, value, nonce, deadline },
});
// Always display domain + message human-readably before user signs
```

## WebSocket / Event Subscriptions — cleanup is mandatory

```typescript
// ✅ correct — always return cleanup
useEffect(() => {
  const unwatch = watchContractEvent(config, {
    address: VAULT_ADDRESS,
    abi: vaultAbi,
    eventName: 'Deposited',
    onLogs: (logs) => setEvents(prev => [...prev, ...logs]),
  })
  return () => unwatch()  // ← REQUIRED — prevents connection leak on unmount
}, [])

// ❌ missing return → leaks WebSocket connection every mount/unmount
useEffect(() => {
  watchContractEvent(config, { ... })  // no cleanup
}, [])
```

## Chain Guard Pattern

```typescript
import { useChainId, useSwitchChain } from 'wagmi'

function ChainGuard({ required, children }: { required: number; children: ReactNode }) {
  const chainId = useChainId()
  const { switchChain, isPending } = useSwitchChain()

  if (chainId !== required) {
    return (
      <button
        onClick={() => switchChain({ chainId: required })}
        disabled={isPending}
      >
        {isPending ? 'Switching…' : `Switch to ${getChainName(required)}`}
      </button>
    )
  }
  return <>{children}</>
}
```

## ABI Codegen Setup

```bash
# wagmi CLI generates typed hooks from ABIs
npx wagmi generate
```

```typescript
// wagmi.config.ts
export default defineConfig({
  out: 'src/generated.ts',
  contracts: [
    {
      name: 'Vault',
      address: { 1: '0x...mainnet', 8453: '0x...base' },
      abi: parseAbi([...]),
    },
  ],
})
```

## Anti-Patterns Reference

| Anti-pattern                             | Fix                                                       |
| ---------------------------------------- | --------------------------------------------------------- |
| `useEffect` subscription without cleanup | Always return `unwatch()`                                 |
| Raw hex revert shown to user             | Use viem error decoding                                   |
| `window.ethereum` direct access          | Use wagmi/viem abstractions                               |
| Hardcoded chain ID                       | Use `useChainId()`                                        |
| No tx deadline                           | `deadline = BigInt(Math.floor(Date.now() / 1000) + 1200)` |
| Polling every block                      | Event subscription or longer interval                     |
| `ethers.BigNumber`                       | Native `bigint` (viem/wagmi v2)                           |
| Only 2 tx states (loading/done)          | All 4: idle / wallet / confirming / success-or-error      |
| SSR wallet access                        | Guard with `typeof window !== 'undefined'`                |
