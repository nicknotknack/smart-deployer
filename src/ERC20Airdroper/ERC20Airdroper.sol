// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC20Airdroper - Utility contract for batch ERC20 token distribution
/// @author Solidity University
/// @notice Enables owners to airdrop ERC20 tokens to multiple recipients
contract ERC20Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Initializes Ownable with deployer
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of token transfers per airdrop call
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC20 token contract to distribute from
    IERC20 public token;

    /// @notice Fixed amount used for allowance check
    uint256 public amount;

    /// @notice Address holding tokens to be distributed
    address public treasury;

    /// @dev Reverts if contract already initialized
    error AlreadyInitialized();
    /// @dev Reverts if receivers and amounts array lengths mismatch
    error ArraysLengthMismatch();
    /// @dev Reverts if insufficient token allowance from treasury
    error NotEnoughApprovedTokens();
    /// @dev Reverts if ERC20 transfer fails
    error TransferFailed();
    /// @dev Reverts if batch size exceeds limit
    error BatchSizeExceeded();

    /// @dev Restricts `initialize` to one-time execution
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    /// @dev Tracks initialization status
    bool private initialized;

    /// @notice Distributes ERC20 tokens from treasury to recipients
    /// @param receivers Addresses to receive tokens
    /// @param amounts Amount of tokens to send per recipient
    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == amounts.length, ArraysLengthMismatch());
        require(token.allowance(treasury, address(this)) >= amount, NotEnoughApprovedTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < receivers.length;) {
            require(token.transferFrom(treasuryAddress, receivers[i], amounts[i]), TransferFailed());
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUtilityContract
    /// @notice Initializes the airdropper contract with required config
    /// @param _initData Encoded deployManager, token, amount, treasury, and new owner
    /// @return success True if initialized
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, uint256 _amount, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, uint256, address, address));

        setDeployManager(_deployManager);

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Helper to encode constructor-style init data
    /// @param _deployManager Address of the DeployManager
    /// @param _token Address of ERC20 token contract
    /// @param _amount Amount used to validate allowance
    /// @param _treasury Address holding the tokens
    /// @param _owner New owner of the contract
    /// @return Encoded initialization bytes
    function getInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _amount, _treasury, _owner);
    }
}