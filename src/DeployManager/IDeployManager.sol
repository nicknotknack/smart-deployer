// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IDeployManager {
    event NewContractAdded(address indexed _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);
    event ContractFeeUpdated(address indexed _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);
    event ContractStatusUpdated(address indexed _contractAddress, bool _isActive, uint256 _timestamp);
    event NewDeployment(address indexed _deployer, address indexed _contractAddress, uint256 _fee, uint256 _timestamp);

    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;
    function updateFee(address _contractAddress, uint256 _newFee) external;
    function deactivateContract(address _contractAddress) external;
    function activateContract(address _contractAddress) external;
}