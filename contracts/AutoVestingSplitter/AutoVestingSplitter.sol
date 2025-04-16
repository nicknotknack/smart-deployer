// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";
import "../IUtilityContract.sol";

contract AutoVestingSplitter is Ownable, IUtilityContract {

    constructor() Ownable(msg.sender) {}

    struct PayeeInfo {
        address account;
        uint256 share;
        address vestingWallet;
    }

    uint256 public totalShares;
    uint256 public start;
    uint256 public duration;

    PayeeInfo[] public payees;
    mapping(address => address) public vestingWalletOf;

    bool private initialized;

    event PaymentReceived(address from, uint256 amount);
    event VestedETHForwarded(address indexed payee, address vestingWallet, uint256 amount);

    error AlreadyInitialized();
    error InvalidInput();
    error ZeroAddress();
    error ZeroShare();

    modifier notInitialized() {
        if (initialized) revert AlreadyInitialized();
        _;
    }

    function initialize(bytes memory _initData) external notInitialized override returns (bool) {
        (address[] memory _accounts, uint256[] memory _shares, uint64 _duration, address _owner) =
            abi.decode(_initData, (address[], uint256[], uint64, address));

        if (_accounts.length != _shares.length || _accounts.length == 0) revert InvalidInput();

        start = block.timestamp;
        duration = _duration;

        for (uint256 i = 0; i < _accounts.length; i++) {
            if (_accounts[i] == address(0)) revert ZeroAddress();
            if (_shares[i] == 0) revert ZeroShare();

            VestingWallet vesting = new VestingWallet(_accounts[i], uint64(start), _duration);
            vestingWalletOf[_accounts[i]] = address(vesting);

            payees.push(PayeeInfo({
                account: _accounts[i],
                share: _shares[i],
                vestingWallet: address(vesting)
            }));

            totalShares += _shares[i];
        }

        _transferOwnership(_owner);
        initialized = true;
        return true;
    }

    function getInitData(
        address[] memory _accounts,
        uint256[] memory _shares,
        uint64 _duration,
        address _owner
    ) external pure returns (bytes memory) {
        return abi.encode(_accounts, _shares, _duration, _owner);
    }

    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
        _splitETH(msg.value);
    }

    fallback() external {
        revert("ERC20 transfers not supported");
    }

    function _splitETH(uint256 amount) internal {
        for (uint256 i = 0; i < payees.length; i++) {
            PayeeInfo memory p = payees[i];
            uint256 payment = (amount * p.share) / totalShares;
            if (payment > 0) {
                payable(p.vestingWallet).transfer(payment);
                emit VestedETHForwarded(p.account, p.vestingWallet, payment);
            }
        }
    }

    function getAllPayees() external view returns (PayeeInfo[] memory) {
        return payees;
    }

    function getVestingWallet(address user) external view returns (address) {
        return vestingWalletOf[user];
    }

    function vestingWalletCount() external view returns (uint256) {
        return payees.length;
    }
}
