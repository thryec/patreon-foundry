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

    // function testStreamETHRequiresDepositNotZero() public {
    //     vm.expectRevert(bytes("deposit is zero"));
    //     vm.prank(alice);
    //     patreon.createETHStream{value: 0 ether}(
    //         bob,
    //         startBlockTime,
    //         endBlockTime
    //     );
    // }

    // function testStreamETHRequiresValidStartTime() public {
    //     uint256 invalidStartTime = 0;
    //     vm.expectRevert(bytes("start time before block.timestamp"));
    //     vm.prank(alice);
    //     patreon.createETHStream{value: depositAmount}(
    //         bob,
    //         invalidStartTime,
    //         endBlockTime
    //     );
    // }

    // function testStreamETHRequiresValidEndTime() public {
    //     vm.expectRevert(bytes("stop time before the start time"));
    //     vm.prank(alice);
    //     patreon.createETHStream{value: depositAmount}(
    //         bob,
    //         endBlockTime,
    //         startBlockTime
    //     );
    // }

    // function testStreamETHRequiresDepositMoreThanDuration() public {
    //     uint256 wrongWei = 999 wei;
    //     vm.expectRevert(bytes("deposit smaller than time delta"));
    //     vm.prank(alice);
    //     patreon.createETHStream{value: wrongWei}(
    //         bob,
    //         startBlockTime,
    //         endBlockTime
    //     );
    // }

    // function testStreamETHRequiresNoRemainder() public {
    //     uint256 remainderAmount = 1500 wei;
    //     vm.expectRevert(bytes("deposit not multiple of time delta"));
    //     vm.prank(alice);
    //     patreon.createETHStream{value: remainderAmount}(
    //         bob,
    //         startBlockTime,
    //         endBlockTime
    //     );
    // }

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

    function testGetStreamInfoById() public {
        uint256 streamId = createStreamForTesting();
        Patreon.Stream memory createdStream = patreon.getStream(streamId);
        uint256 rate = depositAmount / (endBlockTime - startBlockTime);
        assertEq(createdStream.sender, alice);
        assertEq(createdStream.recipient, bob);
        assertEq(createdStream.deposit, depositAmount);
        assertEq(createdStream.startTime, startBlockTime);
        assertEq(createdStream.stopTime, endBlockTime);
        assertEq(createdStream.ratePerSecond, rate);
    }

    // function testGetCurrentETHBalance() public {}

    // function testGetTimePassedInStream() public {}

    //------------------- Helper Functions ------------------- //

    function createStreamForTesting() public returns (uint256) {
        vm.startPrank(alice);
        uint256 streamId = patreon.createETHStream{value: depositAmount}(
            bob,
            startBlockTime,
            endBlockTime
        );
        return streamId;
    }
}
