// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/src/Script.sol";
import "../src/Patreon.sol";

contract ContractScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new Patreon();
        vm.stopBroadcast();
    }
}
