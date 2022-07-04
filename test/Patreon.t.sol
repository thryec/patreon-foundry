// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Patreon.sol";
import "./utils/Utilities.sol";
import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

contract PatreonTest is DSTest {
    Patreon internal patreon;
    Vm internal vm;
    Utilities internal utils;

    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        patreon = new Patreon();
        utils = new Utilities();
    }

    function testTipETH() public {
        console.log("alice address", alice);

        // vm.prank(alice);
        // patreon.tipETH(address(1));
        // assert(condit);
    }

    // function testStreamETH() public {}
}
