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

    string testLink1 =
        "https://ipfs.infura.io/ipfs/bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7a";
    string testLink2 =
        "https://ipfs.infura.io/ipfs/bafybohc3gokgtwtxnfwgalh7qftpipwrjlk7lxifwfgrajnvk52q";
    string emptyString = "";

    //------------------- Events ------------------- //

    event CreateETHStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        uint256 startTime,
        uint256 stopTime
    );

    event RecipientWithdrawFromStream(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    event SenderCancelStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    function setUp() public {
        patreon = new Patreon();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    //------------------- Streaming ETH ------------------- //

    function testStreamETH() public {
        vm.startPrank(alice);
        uint256 streamId1 = patreon.createETHStream{value: depositAmount}(
            bob,
            startBlockTime,
            endBlockTime
        );
        uint256 streamId2 = patreon.createETHStream{value: depositAmount}(
            bob,
            startBlockTime,
            endBlockTime
        );
        assertEq(streamId1, 0);
        assertEq(streamId2, 1);
    }

    function testStreamETHEmitsCreateEvent() public {
        vm.expectEmit(true, true, true, true);
        emit CreateETHStream(
            0,
            alice,
            bob,
            depositAmount,
            startBlockTime,
            endBlockTime
        );
        vm.prank(alice);
        patreon.createETHStream{value: depositAmount}(
            bob,
            startBlockTime,
            endBlockTime
        );
    }

    function testStreamETHRequiresNonZeroReceiver() public {
        vm.expectRevert(bytes("stream to the zero address"));
        vm.prank(alice);
        patreon.createETHStream{value: depositAmount}(
            address(0),
            startBlockTime,
            endBlockTime
        );
    }

    function testStreamETHRequiresReceiverNotContract() public {
        address patreonContract = patreon.contractAddress();
        vm.expectRevert(bytes("stream to the contract itself"));
        vm.prank(alice);
        patreon.createETHStream{value: depositAmount}(
            patreonContract,
            startBlockTime,
            endBlockTime
        );
    }

    function testStreamETHRequiresReceiverNotSender() public {
        vm.expectRevert(bytes("stream to the caller"));
        vm.prank(alice);
        patreon.createETHStream{value: depositAmount}(
            alice,
            startBlockTime,
            endBlockTime
        );
    }

    function testStreamETHRequiresDepositNotZero() public {
        vm.expectRevert(bytes("deposit is zero"));
        vm.prank(alice);
        patreon.createETHStream{value: 0 ether}(
            bob,
            startBlockTime,
            endBlockTime
        );
    }

    function testStreamETHRequiresValidStartTime() public {
        uint256 invalidStartTime = 0;
        vm.expectRevert(bytes("start time before block.timestamp"));
        vm.prank(alice);
        patreon.createETHStream{value: depositAmount}(
            bob,
            invalidStartTime,
            endBlockTime
        );
    }

    function testStreamETHRequiresValidEndTime() public {
        vm.expectRevert(bytes("stop time before the start time"));
        vm.prank(alice);
        patreon.createETHStream{value: depositAmount}(
            bob,
            endBlockTime,
            startBlockTime
        );
    }

    function testStreamETHRequiresDepositMoreThanDuration() public {
        uint256 wrongWei = 999 wei;
        vm.expectRevert(bytes("deposit smaller than time delta"));
        vm.prank(alice);
        patreon.createETHStream{value: wrongWei}(
            bob,
            startBlockTime,
            endBlockTime
        );
    }

    function testStreamETHRequiresNoRemainder() public {
        uint256 remainderAmount = 1500 wei;
        vm.expectRevert(bytes("deposit not multiple of time delta"));
        vm.prank(alice);
        patreon.createETHStream{value: remainderAmount}(
            bob,
            startBlockTime,
            endBlockTime
        );
    }

    //------------------- Withdrawing From ETH Stream ------------------- //

    function testWithdrawFromStream() public {
        uint256 streamId = createStreamForTesting();
        vm.warp(501);
        vm.startPrank(bob);

        uint256 firstWithdrawal = patreon.currentETHBalanceOf(streamId, bob);
        patreon.recipientWithdrawFromStream(streamId, firstWithdrawal);
        assertEq(bob.balance, 105 ether);

        vm.warp(601);
        uint256 secondWithdrawal = patreon.currentETHBalanceOf(streamId, bob);
        patreon.recipientWithdrawFromStream(streamId, secondWithdrawal);
        assertEq(bob.balance, 106 ether);
    }

    function testWithdrawFromStreamRequiresNonZeroAmount() public {
        uint256 streamId = createStreamForTesting();
        vm.prank(bob);
        vm.expectRevert(bytes("amount is zero"));
        patreon.recipientWithdrawFromStream(streamId, 0);
    }

    function testWithdrawFromStreamRequiresAmountLessThanBalance() public {
        uint256 streamId = createStreamForTesting();
        vm.prank(bob);
        vm.expectRevert(bytes("amount exceeds the available balance"));
        patreon.recipientWithdrawFromStream(streamId, 11 ether);
    }

    function testWithdrawFromStreamRequiresReceiver() public {
        uint256 streamId = createStreamForTesting();
        vm.prank(alice);
        vm.expectRevert(bytes("caller is not the recipient of the stream"));
        patreon.recipientWithdrawFromStream(streamId, 5 ether);
    }

    function testWithdrawFromStreamRequiresStreamExists() public {
        uint256 fakeStreamId = 0;
        vm.warp(501);
        vm.prank(bob);
        vm.expectRevert(bytes("stream does not exist"));
        patreon.recipientWithdrawFromStream(fakeStreamId, 5 ether);
    }

    function testWithdrawEmitsEvent() public {
        uint256 streamId = createStreamForTesting();
        vm.expectEmit(true, true, true, true);
        vm.warp(501);
        emit RecipientWithdrawFromStream(streamId, bob, 5 ether);
        vm.prank(bob);
        patreon.recipientWithdrawFromStream(streamId, 5 ether);
    }

    //------------------- Cancelling ETH Stream ------------------- //

    function testCancelStream() public {
        uint256 streamId = createStreamForTesting();
        vm.prank(alice);
        patreon.senderCancelStream(streamId);
        vm.expectRevert(bytes("stream does not exist"));
        patreon.getStream(streamId);
    }

    function testCancelStreamWithdrawsBalanceToRecipient() public {
        uint256 streamId = createStreamForTesting();
        vm.warp(501);
        vm.prank(alice);
        patreon.senderCancelStream(streamId);
        assertEq(bob.balance, 105 ether);
    }

    function testCancelStreamRequiresSender() public {
        uint256 streamId = createStreamForTesting();
        vm.expectRevert(bytes("caller is not the sender of the stream"));
        patreon.senderCancelStream(streamId);
    }

    function testCancelStreamRequiresStreamExists() public {
        uint256 fakeStreamId = 0;
        vm.expectRevert(bytes("stream does not exist"));
        vm.prank(alice);
        patreon.senderCancelStream(fakeStreamId);
    }

    function testCancelStreamEmitsEvent() public {
        uint256 streamId = createStreamForTesting();
        uint256 aliceBalance = patreon.currentETHBalanceOf(streamId, alice);
        uint256 bobBalance = patreon.currentETHBalanceOf(streamId, bob);
        vm.expectEmit(true, true, true, true);
        emit SenderCancelStream(streamId, alice, bob, aliceBalance, bobBalance);
        vm.prank(alice);
        patreon.senderCancelStream(streamId);
    }

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

    function testGetStreamRequiresStreamExists() public {
        uint256 fakeStreamId = 0;
        vm.expectRevert(bytes("stream does not exist"));
        patreon.getStream(fakeStreamId);
    }

    function testGetETHBalanceOfRecipient() public {
        uint256 streamId = createStreamForTesting();
        vm.warp(501);
        uint256 currentBalance = patreon.currentETHBalanceOf(streamId, bob);
        assertEq(currentBalance, 5 ether);
    }

    function testGetETHBalanceOfSender() public {
        uint256 streamId = createStreamForTesting();
        vm.warp(501);
        uint256 currentBalance = patreon.currentETHBalanceOf(streamId, alice);
        assertEq(currentBalance, 5 ether);
    }

    function testGetTimePassedInStream() public {
        uint256 streamId = createStreamForTesting();
        vm.warp(501);
        uint256 timePassed = patreon.timeDeltaOf(streamId);
        assertEq(timePassed, 500);
    }

    function testGetETHBAlanceRequiresStreamExists() public {
        uint256 fakeStreamId = 0;
        vm.expectRevert(bytes("stream does not exist"));
        patreon.currentETHBalanceOf(fakeStreamId, bob);
    }

    //------------------- Profile Functions ------------------- //

    function testAddProfile() public {
        patreon.addProfile(alice, testLink1);
        string memory aliceProfile = patreon.getProfile(alice);
        assertEq(aliceProfile, testLink1);
    }

    function testUpdateProfile() public {
        vm.prank(alice);
        patreon.updateProfile(alice, testLink2);
        string memory aliceProfile = patreon.getProfile(alice);
        assertEq(aliceProfile, testLink2);
    }

    function testUpdateProfileRequiresOwner() public {
        vm.expectRevert(bytes("updating requires sender to be owner"));
        patreon.updateProfile(alice, testLink2);
    }

    function testDeleteProfile() public {
        vm.prank(alice);
        patreon.deleteProfile(alice);
        string memory aliceProfile = patreon.getProfile(alice);
        assertEq(aliceProfile, emptyString);
    }

    function testDeleteProfileRequiresOwner() public {
        vm.expectRevert(bytes("deleting requires sender to be owner"));
        patreon.deleteProfile(alice);
    }

    //------------------- Helper Functions ------------------- //

    function createStreamForTesting() public returns (uint256) {
        vm.prank(alice);
        uint256 streamId = patreon.createETHStream{value: depositAmount}(
            bob,
            startBlockTime,
            endBlockTime
        );
        return streamId;
    }
}
