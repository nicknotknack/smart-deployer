// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../UtilityContract/IUtilityContract.sol";
import "./IDeployManager.sol";

//Deploy Manager
contract DeployManager is IDeployManager, Ownable {
    constructor() Ownable(msg.sender) payable {}

    struct ContractInfo {
        uint256 fee;
        bool isActive;
        uint256 registredAt;
    }

    mapping(address => address[]) public deployedContracts;
    mapping(address => ContractInfo) public contractsData;

    error ContractNotActive();
    error NotEnoughtFunds();
    error ContractDoesNotRegistered();
    error InitializationFailed();

    function deploy(address _utilityContract, bytes calldata _initData) external override payable returns (address) {
        ContractInfo memory info = contractsData[_utilityContract];

        require(info.isActive, ContractNotActive());
        require(msg.value >= info.fee, NotEnoughtFunds());
        require(info.registredAt > 0, ContractDoesNotRegistered());

        address clone = Clones.clone(_utilityContract);

        require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

        payable(owner()).transfer(msg.value);

        deployedContracts[msg.sender].push(clone);

        emit NewDeployment(msg.sender, clone, msg.value, block.timestamp);

        return clone;
    }

    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner {
        contractsData[_contractAddress] = ContractInfo({fee: _fee, isActive: _isActive, registredAt: block.timestamp});

        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner {
        require(contractsData[_contractAddress].registredAt > 0, ContractDoesNotRegistered());

        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, _oldFee, _newFee, block.timestamp);
    }

    function deactivateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registredAt > 0, ContractDoesNotRegistered());

        contractsData[_address].isActive = false;

        emit ContractStatusUpdated(_address, false, block.timestamp);
    }

    function activateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registredAt > 0, ContractDoesNotRegistered());

        contractsData[_address].isActive = true;

        emit ContractStatusUpdated(_address, true, block.timestamp);
    }
}
