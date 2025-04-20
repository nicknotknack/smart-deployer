// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IDeployManager} from "../DeployManager/IDeployManager.sol";
import {IUtilityContract} from "./IUtilityContract.sol";

abstract contract AbstractUtilityContract is IUtilityContract {
    address public deployManager;

    function initialize(bytes memory _initData) external virtual override returns (bool) {
        deployManager = abi.decode(_initData, (address));
        return true;
    }
}
