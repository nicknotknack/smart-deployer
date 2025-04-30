// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import {IDeployManager} from "../DeployManager/IDeployManager.sol";
import {IUtilityContract} from "./IUtilityContract.sol";

/// @title AbstractUtilityContract - Abstract contract for utility contracts
/// @author Solidity University
/// @notice This abstract contract provides a base implementation for utility contracts.
/// @dev Utility contracts should inherit from this contract and implement the initialize function.
abstract contract AbstractUtilityContract is IUtilityContract, ERC165 {
    /// @notice Address of the DeployManager that deployed this contract
    address public deployManager;

    /// @inheritdoc IUtilityContract
    function initialize(bytes memory _initData) external virtual override returns (bool) {
        deployManager = abi.decode(_initData, (address));
        setDeployManager(deployManager);
        return true;
    }

    /// @notice Internal funciton for setting DeployManager
    /// @param _deployManager DeployManager address
    function setDeployManager(address _deployManager) internal virtual {
        if (!validateDeployManager(_deployManager)) {
            revert FailedToValidateDeployManager();
        }
        deployManager = _deployManager;
    }

    /// @notice Checks if the _deployManager address is valid DeployManager
    /// @param _deployManager DeployManager address
    /// @return True if valid
    /// @dev Validates _deployManager is not zero address and supports IDeployManager interface
    function validateDeployManager(address _deployManager) internal view returns (bool) {
        if (_deployManager == address(0)) {
            revert DeployManagerCannotBeZero();
        }

        bytes4 interfaceId = type(IDeployManager).interfaceId;

        if (!IDeployManager(_deployManager).supportsInterface(interfaceId)) {
            revert NotDeployManager();
        }

        return true;
    }

    /// @inheritdoc IUtilityContract
    function getDeployManager() external view virtual override returns (address) {
        return deployManager;
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }
}