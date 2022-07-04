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

    address internal ada = payable(address(0xada));
    address internal bob = address(0xb0b);

    function setUp() public {
        patreon = new Patreon();
        utils = new Utilities();
    }

    function testTipETH() public {
        utils.createUsers(2);
        console.log("ada balance", address(ada).balance);
        // vm.prank(ada);
        // patreon.tipETH(address(1));
        // assert(condit);
    }

    // function testStreamETH() public {}
}
