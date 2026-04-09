---
name: foundry-testing
description: >
  Foundry test patterns: unit, integration, fork, invariant, fuzzing, cheatcodes, gas snapshots.
  Auto-loaded by smart-contract-engineer, devops-engineer. Also invoke directly for any Foundry
  question, test structure, invariant setup, or CI configuration.
---

# Foundry Testing Reference

## Test Hierarchy (write all four for anything touching value)

```
Unit          → isolated function, mock external deps
Integration   → multi-contract flows, realistic state
Fork          → forked mainnet, real protocol state
Invariant     → stateful fuzzing across all action sequences
```

## Unit Test Pattern

```solidity
contract VaultTest is Test {
    Vault vault;
    ERC20Mock token;
    address user = makeAddr("user");

    function setUp() public {
        token = new ERC20Mock();
        vault = new Vault(address(token));
        token.mint(user, 1000e18);
        vm.prank(user);
        token.approve(address(vault), type(uint256).max);
    }

    function test_deposit_updatesBalance() public {
        vm.prank(user);
        vault.deposit(100e18);
        assertEq(vault.balanceOf(user), 100e18);
    }

    function test_deposit_emitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Deposited(user, 100e18);
        vm.prank(user);
        vault.deposit(100e18);
    }

    function test_deposit_revertsIfZero() public {
        vm.expectRevert(Vault.ZeroAmount.selector);
        vm.prank(user);
        vault.deposit(0);
    }

    function testFuzz_deposit(uint256 amount) public {
        amount = bound(amount, 1, 1000e18);
        vm.prank(user);
        vault.deposit(amount);
        assertEq(vault.balanceOf(user), amount);
    }
}
```

## Fork Test Pattern

```solidity
contract VaultForkTest is Test {
    uint256 mainnetFork;
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address whale = 0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341;

    function setUp() public {
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(mainnetFork);
        vm.rollFork(19_000_000);  // pin block for reproducibility
    }

    function test_deposit_withRealUSDC() public {
        vm.prank(whale);
        usdc.approve(address(vault), 1_000_000e6);
        vm.prank(whale);
        vault.deposit(1_000_000e6);
        assertGt(vault.balanceOf(whale), 0);
    }
}
```

## Invariant Test Pattern

```solidity
contract VaultInvariantTest is Test {
    Vault vault;
    Handler handler;

    function setUp() public {
        vault = new Vault();
        handler = new Handler(vault);
        targetContract(address(handler));  // fuzzer only calls handler
    }

    // Key invariant: totalAssets == sum of user balances
    function invariant_solvency() public view {
        assertEq(vault.totalAssets(), handler.ghost_totalDeposited() - handler.ghost_totalWithdrawn());
    }

    // Key invariant: share price monotonically non-decreasing
    function invariant_sharePriceMonotonic() public view {
        assertGe(vault.pricePerShare(), handler.initialPricePerShare());
    }
}

contract Handler is CommonBase, StdCheats, StdUtils {
    Vault vault;
    uint256 public initialPricePerShare;
    uint256 public ghost_totalDeposited;
    uint256 public ghost_totalWithdrawn;

    constructor(Vault _vault) {
        vault = _vault;
        initialPricePerShare = vault.pricePerShare();
    }

    function deposit(uint256 amount, address actor) public {
        amount = bound(amount, 1, 100_000e18);
        deal(address(vault.asset()), actor, amount);
        vm.startPrank(actor);
        vault.asset().approve(address(vault), amount);
        vault.deposit(amount);
        vm.stopPrank();
        ghost_totalDeposited += amount;
    }

    function withdraw(uint256 shares, address actor) public {
        shares = bound(shares, 0, vault.balanceOf(actor));
        if (shares == 0) return;
        vm.prank(actor);
        uint256 assets = vault.withdraw(shares);
        ghost_totalWithdrawn += assets;
    }
}
```

## Reentrancy Attack Test

```solidity
contract ReentrantAttacker {
    Vault vault;
    bool reentered;

    receive() external payable {
        if (!reentered) {
            reentered = true;
            try vault.withdraw(1 ether) {} catch {}
        }
    }
}

function test_withdraw_blocksReentrancy() public {
    ReentrantAttacker attacker = new ReentrantAttacker();
    deal(address(attacker), 2 ether);
    vm.prank(address(attacker));
    vault.deposit{value: 2 ether}();

    vm.expectRevert();  // ReentrancyGuardReentrantCall
    vm.prank(address(attacker));
    vault.withdraw(1 ether);
}
```

## Flash Loan Oracle Attack Test

```solidity
function test_oracle_resistsFlashLoanManipulation() public {
    // Simulate flash loan: inflate pool balance in same tx
    deal(address(token), address(pool), 100_000_000e18);

    uint256 price = oracle.getPrice();

    // TWAP should be within 1% of expected price (manipulation didn't work)
    assertApproxEqRel(price, EXPECTED_PRICE, 0.01e18);
}
```

## Essential Cheatcodes

```solidity
vm.prank(address)                  // next call from address
vm.startPrank(address)             // all calls from address until stopPrank
vm.deal(address, amount)           // set ETH balance
deal(token, address, amount)       // set ERC20 balance (StdCheats)
vm.warp(timestamp)                 // set block.timestamp
vm.roll(blockNumber)               // set block.number
vm.expectRevert(selector)          // expect specific custom error
vm.expectEmit(true, true, false, true)  // expect event with indexed args
vm.mockCall(target, data, return) // mock specific external call
vm.label(address, "Name")          // name for stack traces
makeAddr("name")                   // deterministic test address
bound(x, min, max)                 // clamp fuzz input to range
```

## foundry.toml

```toml
[profile.default]
src = "src"
test = "test"
out = "out"
libs = ["lib"]
solc = "0.8.24"
optimizer = true
optimizer_runs = 200

[profile.default.fuzz]
runs = 1000
max_test_rejects = 65536

[profile.default.invariant]
runs = 500
depth = 100           # actions per run
fail_on_revert = false

[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
base    = "${BASE_RPC_URL}"
```

## CI (GitHub Actions)

```yaml
- name: Foundry tests
  run: |
    forge build --sizes
    forge test -vvv
    forge snapshot --check      # fail if gas increases
    slither . --config-file slither.config.json
env:
  MAINNET_RPC_URL: ${{ secrets.MAINNET_RPC_URL }}
```
