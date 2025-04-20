// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../IUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is IUtilityContract, Ownable {
    constructor() Ownable(msg.sender) {}

    IERC20 public token;
    bool private initialized;
    uint256 public allocatedTokens;

    struct VestingInfo {
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
        uint256 claimed;
        uint256 lastClaimTime;
        uint256 claimCooldown;
        uint256 minClaimAmount;
    }

    mapping(address => VestingInfo) public vestings;

    event VestingCreated(address beneficiary, uint256 amount, uint256 creationTime);
    event TokensWithdrawn(address to, uint256 amount);

    error AlreadyInitialized();
    error VestingNotFound();
    error CliffNotReached();
    error TransferFailed();
    error NothingToClaim();
    error InfsufficientBalance();
    error VestingAlreadyExist();
    error AmountCantBeZero();
    error StartTimeShouldBeFuture();
    error DurationCantBeZero();
    error CliffCantBeLongerThanDuration();
    error CooldownCantBeLongerThanDuration();
    error InvalidBeneficiary();
    error BelowMinimalClaimAmount();
    error CooldownNotPassed();
    error CantClaimMoreThanTotalAmount();
    error WithdrawTransferFailed();
    error NothingToWithdraw();

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function claim() public {
        VestingInfo storage vesting = vestings[msg.sender];

        require(vesting.totalAmount > 0, VestingNotFound());
        require(block.timestamp > vesting.startTime + vesting.cliff, CliffNotReached());
        require(block.timestamp >= vesting.lastClaimTime + vesting.claimCooldown, CooldownNotPassed());

        uint256 claimable = claimableAmount(msg.sender);
        require(claimable > 0, NothingToClaim());
        require(claimable >= vesting.minClaimAmount, BelowMinimalClaimAmount());
        require(claimable + vesting.claimed <= vesting.totalAmount, CantClaimMoreThanTotalAmount());

        vesting.claimed += claimable;
        vesting.lastClaimTime = block.timestamp;
        allocatedTokens -= claimable;

        require(token.transfer(msg.sender, claimable), TransferFailed());

        emit Claim(msg.sender, claimable, block.timestamp);
    }

    function vestedAmount(address _claimer) internal view returns (uint256) {
        VestingInfo storage vesting = vestings[_claimer];
        if (block.timestamp < vesting.startTime + vesting.cliff) return 0;

        uint256 passedTime = block.timestamp - (vesting.startTime + vesting.cliff);
        if (passedTime > vesting.duration) {
            passedTime = vesting.duration;
        }
        return (vesting.totalAmount * passedTime) / vesting.duration;
    }

    function claimableAmount(address _claimer) public view returns (uint256) {
        VestingInfo storage vesting = vestings[_claimer];
        if (block.timestamp < vesting.startTime + vesting.cliff) return 0;

        return vestedAmount(_claimer) - vesting.claimed;
    }

    function startVesting(
        address _beneficiary,
        uint256 _totalAmount,
        uint256 _startTime,
        uint256 _cliff,
        uint256 _duration,
        uint256 _claimCooldown,
        uint256 _minClaimAmount
    ) external onlyOwner {
        require(token.balanceOf(address(this)) - allocatedTokens >= _totalAmount, InfsufficientBalance());
        require(_totalAmount > 0, AmountCantBeZero());
        require(
            vestings[_beneficiary].totalAmount == 0
                || vestings[_beneficiary].totalAmount == vestings[_beneficiary].claimed,
            VestingAlreadyExist()
        );
        require(_startTime > block.timestamp, StartTimeShouldBeFuture());
        require(_duration > 0, DurationCantBeZero());
        require(_cliff < _duration, CliffCantBeLongerThanDuration());
        require(_claimCooldown < _duration, CooldownCantBeLongerThanDuration());
        require(_beneficiary != address(0), InvalidBeneficiary());

        vestings[_beneficiary] = VestingInfo({
            totalAmount: _totalAmount,
            startTime: _startTime,
            cliff: _cliff,
            duration: _duration,
            claimed: 0,
            lastClaimTime: 0,
            claimCooldown: _claimCooldown,
            minClaimAmount: _minClaimAmount
        });

        allocatedTokens += _totalAmount;

        emit VestingCreated(_beneficiary, _totalAmount, block.timestamp);
    }

    function withdrawUnallocated(address _to) external onlyOwner {
        uint256 available = token.balanceOf(address(this)) - allocatedTokens;
        require(available > 0, NothingToWithdraw());

        require(token.transfer(_to, available), WithdrawTransferFailed());

        emit TokensWithdrawn(_to, available);
    }

    function initialize(bytes memory _initData) external notInitialized returns (bool) {
        (address _token, address _owner) = abi.decode(_initData, (address, address));

        token = IERC20(_token);
        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    function getInitData(address _token, address _owner) external pure returns (bytes memory) {
        return abi.encode(_token, _owner);
    }
}
