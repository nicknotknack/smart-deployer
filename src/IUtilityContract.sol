// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IUtilityContract {
    function initialize(bytes memory _initData) external returns (bool);
}
