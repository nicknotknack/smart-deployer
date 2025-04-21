// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

/// @title IDeployManager - Factory for utility contracts
/// @author Solidity Univesity
/// @notice This interface defines the functions, errors and events for the DeployManager contract.
interface IDeployManager is IERC165 {
    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Reverts if the contract is not active
    error ContractNotActive();

    /// @dev Not enough funds to deploy the contract
    error NotEnoughtFunds();

    /// @dev Reverts if the contract is not registered
    error ContractDoesNotRegistered();

    /// @dev Reverts if the .initialize() function fails
    error InitializationFailed();

    /// @dev Reverts if the contract is not a utility contract
    error ContractIsNotUtilityContract();

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Emitted when a new utility contract template is registered.
    /// @param _contractAddress Address of the registered utility contract template.
    /// @param _fee Fee (in wei) required to deploy a clone of this contract.
    /// @param _isActive Whether the contract is active and deployable.
    /// @param _timestamp Timestamp when the contract was added.
    event NewContractAdded(address indexed _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);
    event ContractFeeUpdated(address indexed _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);
    event ContractStatusUpdated(address indexed _contractAddress, bool _isActive, uint256 _timestamp);
    event NewDeployment(address indexed _deployer, address indexed _contractAddress, uint256 _fee, uint256 _timestamp);

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Deploys a new utility contract
    /// @param _utilityContract The address of the utility contract template
    /// @param _initData The initialization data for the utility contract
    /// @return The address of the deployed utility contract
    /// @dev Emits NewDeployment event
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;
    function updateFee(address _contractAddress, uint256 _newFee) external;
    function deactivateContract(address _contractAddress) external;
    function activateContract(address _contractAddress) external;
}
