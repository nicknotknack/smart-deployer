// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../IUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is IUtilityContract, Ownable {

    constructor() Ownable(msg.sender) {}
    
    IERC20 public token;
    bool private initialized;
    address public beneficiary; //3. Vesting smart contract can be used by multiple ppl
                                // u can use mapping here
    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public cliff;
    uint256 public duration;
    uint256 public claimed;

    error AlreadyInitialized();
    error ClaimerIsNotBeneficiary();
    error CliffNotReached();
    error TransferFailed();
    error NothingToClaim();

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    //4. split initialization logic and start vesting logic
    //initialization = tokenAddress, totalAmount, owner
    //startVesting (arg1, arg2, arg...) require tokens on contract

    //5. initialize, getInitdata should work

    function claim() public {
        //1. add claim cooldown
        //2. add min. claim amaunt
        require(msg.sender == beneficiary, ClaimerIsNotBeneficiary());
        require(block.timestamp > startTime + cliff, CliffNotReached());

        uint256 claimable = claimableAmount();
        require(claimable > 0, NothingToClaim());

        claimed += claimable;
        require(token.transfer(beneficiary, claimable), TransferFailed());

        emit Claim(msg.sender, claimable, block.timestamp);
    }

    function vestedAmount() internal view returns(uint256) {
        if (block.timestamp < startTime + cliff) return 0;

        uint256 passedTime = block.timestamp - (startTime + cliff);
        return (totalAmount * passedTime) / duration;
    }

    function claimableAmount() public view returns(uint256) {
        if (block.timestamp < startTime + cliff) return 0;

        return vestedAmount() - claimed;
    }














    function initialize(bytes memory _initData) external notInitialized returns(bool) {

        (address _token, address _treasury, address _owner) = abi.decode(_initData, (address, address, address));


        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    function getInitData(address _token, address _treasury, address _owner) external pure returns(bytes memory) {
        return abi.encode(_token, _treasury, _owner);
    }

    

}