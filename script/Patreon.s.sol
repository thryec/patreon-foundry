// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "forge-std/Script.sol";
import "../src/Patreon.sol";

contract PatreonScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new Patreon();
        vm.stopBroadcast();
    }
}
