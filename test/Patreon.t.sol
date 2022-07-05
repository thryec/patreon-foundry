// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Patreon.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

contract PatreonTest is Test {
    Patreon internal patreon;

    address alice = address(0x1);
    address bob = address(0x2);
    uint256 transferAmount = 1 ether;
    uint256 depositAmount = 10 ether;

    function setUp() public {
        patreon = new Patreon();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    //------------------- Streaming ETH ------------------- //

    function testStreamETH() public {
        vm.startPrank(alice);
        patreon.createETHStream{value: depositAmount}(bob, 1, 100);
    }

    // function testStreamETHRequiresNonZeroReceiver() public {}

    // function testStreamETHRequiresReceiverNotContract() public {}

    // function testStreamETHRequiresReceiverNotSender() public {}

    // function testStreamETHRequiresDepositNotZero() public {}

    //------------------- Withdrawing From ETH Stream ------------------- //

    // function testWithdrawFromStream() public {}

    // function testWithdrawFromStreamRequiresReceiver() public {}

    // function testWithdrawFromStreamRequiresStreamExists() public {}

    //------------------- Cancelling ETH Stream ------------------- //

    // function testCancelStream() public {}

    // function testCancelStreamRequiresSender() public {}

    // function testCancelStreamRequiresStreamExists() public {}

    //------------------- Tipping ETH ------------------- //

    function testTipETH() public {
        uint256 aliceStartBal = alice.balance;
        uint256 bobStartBal = bob.balance;

        vm.prank(alice);
        patreon.tipETH{value: transferAmount}(bob);
        uint256 aliceNewBal = alice.balance;

        assertEq(aliceStartBal - aliceNewBal, transferAmount);
        assertEq(bob.balance, bobStartBal + transferAmount);
    }

    //------------------- Reading Contract Values ------------------- //

    // function testGetStreamInfoById() public {}

    // function testGetCurrentETHBalance() public {}

    // function testGetTimePassedInStream() public {}
}
