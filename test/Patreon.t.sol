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

    uint256 startBlockTime = 1;
    uint256 endBlockTime = 1001;

    function setUp() public {
        patreon = new Patreon();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    //------------------- Streaming ETH ------------------- //

    // function testStreamETH() public {
    //     vm.startPrank(alice);
    //     uint256 streamId1 = patreon.createETHStream{value: depositAmount}(
    //         bob,
    //         startBlockTime,
    //         endBlockTime
    //     );
    //     uint256 streamId2 = patreon.createETHStream{value: depositAmount}(
    //         bob,
    //         startBlockTime,
    //         endBlockTime
    //     );
    //     assertEq(streamId1, 0);
    //     assertEq(streamId2, 1);
    // }

    // function testStreamETHRequiresNonZeroReceiver() public {
    //     vm.expectRevert(bytes("stream to the zero address"));
    //     vm.startPrank(alice);
    //     patreon.createETHStream{value: depositAmount}(
    //         address(0),
    //         startBlockTime,
    //         endBlockTime
    //     );
    // }

    // function testStreamETHRequiresReceiverNotContract() public {
    //     address patreonContract = patreon.contractAddress();
    //     vm.expectRevert(bytes("stream to the contract itself"));
    //     vm.prank(alice);
    //     patreon.createETHStream{value: depositAmount}(
    //         patreonContract,
    //         startBlockTime,
    //         endBlockTime
    //     );
    // }

    // function testStreamETHRequiresReceiverNotSender() public {
    //     vm.expectRevert(bytes("stream to the caller"));
    //     vm.prank(alice);
    //     patreon.createETHStream{value: depositAmount}(
    //         alice,
    //         startBlockTime,
    //         endBlockTime
    //     );
    // }

    function testStreamETHRequiresDepositNotZero() public {
        vm.expectRevert(bytes("deposit is zero"));
        vm.prank(alice);
        patreon.createETHStream{value: 0 ether}(
            bob,
            startBlockTime,
            endBlockTime
        );
    }

    //------------------- Withdrawing From ETH Stream ------------------- //

    // function testWithdrawFromStream() public {}

    // function testWithdrawFromStreamRequiresReceiver() public {}

    // function testWithdrawFromStreamRequiresStreamExists() public {}

    //------------------- Cancelling ETH Stream ------------------- //

    // function testCancelStream() public {}

    // function testCancelStreamRequiresSender() public {}

    // function testCancelStreamRequiresStreamExists() public {}

    //------------------- Tipping ETH ------------------- //

    // function testTipETH() public {
    //     uint256 aliceStartBal = alice.balance;
    //     uint256 bobStartBal = bob.balance;

    //     vm.prank(alice);
    //     patreon.tipETH{value: transferAmount}(bob);
    //     uint256 aliceNewBal = alice.balance;

    //     assertEq(aliceStartBal - aliceNewBal, transferAmount);
    //     assertEq(bob.balance, bobStartBal + transferAmount);
    // }

    //------------------- Reading Contract Values ------------------- //

    // function testGetStreamInfoById() public {}

    // function testGetCurrentETHBalance() public {}

    // function testGetTimePassedInStream() public {}
}
