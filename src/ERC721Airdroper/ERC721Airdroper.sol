// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC721Airdroper - Utility contract for batch ERC721 token distribution
/// @author Solidity University
/// @notice Enables owners to airdrop ERC721 tokens to multiple recipients
contract ERC721Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Initializes Ownable with deployer
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of token transfers per airdrop call
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC721 token contract to distribute from
    IERC721 public token;

    /// @notice Address holding tokens to be distributed
    address public treasury;

    /// @dev Reverts if contract already initialized
    error AlreadyInitialized();
    /// @dev Reverts if receivers and tokenIds array lengths mismatch
    error ArraysLengthMismatch();
    /// @dev Reverts if this contract is not approved to transfer tokens from treasury
    error NeedToApproveTokens();
    /// @dev Reverts if tokenIds length exceeds batch limit
    error BatchSizeExceeded();

    /// @dev Restricts `initialize` to one-time execution
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    /// @dev Tracks initialization status
    bool private initialized;

    /// @notice Distributes ERC721 tokens from treasury to recipients
    /// @param receivers Addresses to receive tokens
    /// @param tokenIds IDs of tokens to transfer
    function airdrop(address[] calldata receivers, uint256[] calldata tokenIds) external onlyOwner {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ArraysLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < tokenIds.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUtilityContract
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC721(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Helper to encode constructor-style init data
    /// @param _deployManager Address of the DeployManager
    /// @param _token Address of ERC721 token contract
    /// @param _treasury Address holding the tokens
    /// @param _owner New owner of the contract
    /// @return Encoded initialization bytes
    function getInitData(address _deployManager, address _token, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}