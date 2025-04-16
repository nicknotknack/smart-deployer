# AutoVestingSplitter

## 📄 Description

`AutoVestingSplitter` is a utility contract that automatically splits received **Ether (ETH)** among a group of predefined recipients and forwards their respective shares to personal `VestingWallet` contracts. Each participant's ETH is unlocked gradually over a fixed duration using OpenZeppelin's `VestingWallet`.

The contract is designed to be used in a smart deployer infrastructure via `initialize(...)` and `getInitData(...)`.

---

## 🔧 Features

- Automatically creates a `VestingWallet` per recipient.
- Splits ETH by predefined shares.
- Instantly forwards ETH to vesting wallets.
- Fully Ownable.
- Rejects all ERC20 token transfers.
- Uses external `initialize(...)` instead of a constructor.

---

## 🏗 Initialization

```solidity
initialize(bytes _initData)
```

- `_initData` must be encoded using `abi.encode(...)` with the following parameters:
  - `address[] accounts` — recipient addresses
  - `uint256[] shares` — corresponding shares
  - `uint64 duration` — vesting duration (in seconds)
  - `address owner` — contract owner

You can generate `_initData` using the `getInitData(...)` helper function.

---

## 💸 How ETH is Distributed

- When ETH is sent to the contract, it triggers `receive()`.
- ETH is split proportionally according to each recipient’s share.
- Each share is immediately forwarded to the corresponding `VestingWallet`.

---

## 🚫 Restrictions

- ERC20 tokens are not supported.
- ETH is instantly forwarded — no internal balance is kept.
- Cannot re-initialize more than once.

---

## 📚 Key Functions

### initialize(bytes _initData)
Initializes the contract. Can only be called once.

### getInitData(address[] accounts, uint256[] shares, uint64 duration, address owner)
Returns the encoded data used for initialization.

### getAllPayees()
Returns full list of payees and their vesting wallets.

### getVestingWallet(address user)
Returns the vesting wallet associated with a given address.

### vestingWalletCount()
Returns the number of registered payees.

---

## 🔔 Events

- `PaymentReceived(address from, uint256 amount)`
- `VestedETHForwarded(address indexed payee, address vestingWallet, uint256 amount)`
