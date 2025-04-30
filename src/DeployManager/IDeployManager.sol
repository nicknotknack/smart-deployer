// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

/// @title IDeployManager - Factory for utility contracts
/// @author Solidity Univesity
/// @notice This interface defines the functions, errors and events for the DeployManager contract
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

    /// @dev Reverts if the contracts already registered
    error AlreadyRegistered();

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Emitted when a new utility contract template is registered
    /// @param _contractAddress Address of the registered utility contract template
    /// @param _fee Fee (in wei) required to deploy a clone of this contract
    /// @param _isActive Whether the contract is active and deployable
    /// @param _timestamp Timestamp when the contract was added
    event NewContractAdded(address indexed _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);

    /// @notice Emitted when a contract deployment fee is updated
    /// @param _contractAddress Address of the registered utility contract
    /// @param _oldFee Fee (in wei) required to deploy contract before update
    /// @param _newFee Fee (in wei) required to deploy contract after update
    /// @param _timestamp Timestamp of fee update
    event ContractFeeUpdated(address indexed _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);

    /// @notice Emitted when a contract active status is updated
    /// @param _contractAddress Address of the registered utility contract
    /// @param _isActive Ture if the contract can be deployed
    /// @param _timestamp Timestamp of status update
    event ContractStatusUpdated(address indexed _contractAddress, bool _isActive, uint256 _timestamp);

    /// @notice Emitted when new utility contract is deployed
    /// @param _deployer Address that initiated deployment
    /// @param _contractAddress Address of the utility contract
    /// @param _fee Fee (in wei) paid for deployment
    /// @param _timestamp Timestamp of deployment
    event NewDeployment(address indexed _deployer, address indexed _contractAddress, uint256 _fee, uint256 _timestamp);

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Deploys a new utility contract
    /// @param _utilityContract The address of the registered utility contract
    /// @param _initData The initialization data for the utility contract
    /// @return The address of the deployed utility contract
    /// @dev Emits NewDeployment event
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    /// @notice Registers a new utility contract
    /// @param _contractAddress The address of the utility contract template
    /// @param _fee Fee (in wei) required for the deployment
    /// @param _isActive Ture if the contract can be deployed immediately
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    /// @notice Updates fee for registered contract
    /// @param _contractAddress The address of the registered utility contract
    /// @param _newFee New fee (in wei) required for the deployment
    function updateFee(address _contractAddress, uint256 _newFee) external;

    /// @notice Disables ability to deploy of a registered contract
    /// @param _contractAddress The address of the registered utility contract
    /// @dev Sets _isActive to false
    function deactivateContract(address _contractAddress) external;

    /// @notice Activates ability to deploy of a registered contract
    /// @param _contractAddress The address of the registered utility contract
    /// @dev Sets _isActive to true
    function activateContract(address _contractAddress) external;
}