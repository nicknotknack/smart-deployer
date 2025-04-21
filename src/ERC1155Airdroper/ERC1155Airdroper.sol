// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Airdroper is AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 10;

    IERC1155 public token;
    address public treasury;

    error AlreadyInitialized();
    error ReceiversLengthMismatch();
    error AmountsLengthMismatch();
    error BatchSizeExceeded();
    error NeedToApproveTokens();

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds)
        external
        onlyOwner
    {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ReceiversLengthMismatch());
        require(amounts.length == tokenIds.length, AmountsLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < amounts.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i], amounts[i], "");
            unchecked {
                ++i;
            }
        }
    }

    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, address _treasury, address _owner) = abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC1155(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    function getInitData(address _deployManager, address _token, address _treasury, address _owner) external pure returns (bytes memory) {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}
