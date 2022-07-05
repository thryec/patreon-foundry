// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Patreon.sol";
import "./utils/Utilities.sol";
import "forge-std/Test.sol";
import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

contract PatreonTest is DSTest {
    Patreon internal patreon;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    Utilities internal utils;

    address alice = address(0x1);
    address bob = address(0x2);
    uint256 transferValue = 1 ether;

    function setUp() public {
        patreon = new Patreon();
        utils = new Utilities();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    function testTipETH() public {
        uint256 aliceStartBal = alice.balance;
        uint256 bobStartBal = bob.balance;

        vm.startPrank(alice);
        patreon.tipETH{value: transferValue}(bob);
        uint256 aliceNewBal = alice.balance;

        assertEq(aliceStartBal - aliceNewBal, transferValue);
        assertEq(bob.balance, bobStartBal + transferValue);
    }

    // function testStreamETH() public {}
}
