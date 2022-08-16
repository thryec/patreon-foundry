// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./Profiles.sol";
import {console} from "forge-std/console.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract Patreon is ReentrancyGuard, Profiles {
    //------------------- Variables ------------------- //
    address public contractAddress;
    mapping(uint256 => Stream) public streams; // maps streamIds to stream

    using Counters for Counters.Counter;
    Counters.Counter public streamIds; // track unique streamIds

    struct Stream {
        uint256 streamId;
        uint256 deposit;
        uint256 ratePerSecond;
        uint256 remainingBalance;
        uint256 startTime;
        uint256 stopTime;
        address recipient;
        address sender;
        bool exists;
        bool isActive;
    }

    //------------------- Events ------------------- //

    /**
     * @notice Emits when a stream is successfully created.
     */
    event CreateETHStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        uint256 startTime,
        uint256 stopTime
    );

    /**
     * @notice Emits when the recipient of a stream withdraws a portion or all their pro rata share of the stream.
     */
    event RecipientWithdrawFromStream(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    /**
     * @notice Emits when a stream is successfully cancelled and tokens are transferred back on a pro rata basis.
     */
    event SenderCancelStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    //------------------- Modifiers ------------------- //

    /**
     * @dev Throws if the caller is not the sender of the stream.
     */
    modifier onlySender(uint256 streamId) {
        require(
            msg.sender == streams[streamId].sender,
            "caller is not the sender of the stream"
        );
        _;
    }

    /**
     * @dev Throws if the caller is not the recipient of the stream.
     */
    modifier onlyRecipient(uint256 streamId) {
        require(
            msg.sender == streams[streamId].recipient,
            "caller is not the recipient of the stream"
        );
        _;
    }

    /**
     * @dev Throws if the provided id does not point to a valid stream.
     */
    modifier streamExists(uint256 streamId) {
        require(streams[streamId].exists, "stream does not exist");
        _;
    }

    /**
     * @dev Throws if the provided id does not point to an active
     */
    modifier streamIsActive(uint256 streamId) {
        require(streams[streamId].isActive, "stream is not active");
        _;
    }

    constructor() {
        contractAddress = address(this);
    }

    //------------------- Mutative Functions ------------------- //

    function createETHStream(
        address recipient,
        uint256 startTime,
        uint256 stopTime
    ) external payable returns (uint256) {
        uint256 _depositAmount = msg.value;
        require(recipient != address(0x00), "stream to the zero address");
        require(recipient != address(this), "stream to the contract itself");
        require(recipient != msg.sender, "stream to the caller");
        require(_depositAmount > 0, "deposit is zero");
        require(
            startTime >= block.timestamp,
            "start time before block.timestamp"
        );
        require(stopTime > startTime, "stop time before the start time");

        uint256 _duration = stopTime - startTime;
        uint256 _ratePerSecond = _depositAmount / _duration;

        // /* Without this, the rate per second would be zero. */
        require(_depositAmount >= _duration, "deposit smaller than time delta");

        /* This condition avoids dealing with remainders */
        require(
            _depositAmount % _duration == 0,
            "deposit not multiple of time delta"
        );

        uint256 currentStreamId = streamIds.current();
        streams[currentStreamId] = Stream({
            streamId: currentStreamId,
            remainingBalance: _depositAmount,
            deposit: _depositAmount,
            ratePerSecond: _ratePerSecond,
            recipient: recipient,
            sender: msg.sender,
            startTime: startTime,
            stopTime: stopTime,
            exists: true,
            isActive: true
        });
        streamIds.increment();

        emit CreateETHStream(
            currentStreamId,
            msg.sender,
            recipient,
            _depositAmount,
            startTime,
            stopTime
        );

        return currentStreamId;
    }

    function senderCancelStream(uint256 streamId)
        external
        nonReentrant
        streamExists(streamId)
        streamIsActive(streamId)
        onlySender(streamId)
        returns (bool)
    {
        Stream memory stream = streams[streamId];
        uint256 senderBalance = currentETHBalanceOf(streamId, stream.sender);
        uint256 recipientBalance = currentETHBalanceOf(
            streamId,
            stream.recipient
        );

        streams[streamId].isActive = false;

        if (recipientBalance > 0) {
            (bool success, ) = payable(stream.recipient).call{
                value: recipientBalance
            }("");
            require(success, "Ether not withdrawn to recipient");
        }

        if (senderBalance > 0) {
            (bool success, ) = payable(stream.sender).call{
                value: senderBalance
            }("");
            require(success, "Ether not withdrawn to recipient");
        }

        emit SenderCancelStream(
            streamId,
            stream.sender,
            stream.recipient,
            senderBalance,
            recipientBalance
        );
        return true;
    }

    function recipientWithdrawFromStream(uint256 streamId, uint256 amount)
        external
        nonReentrant
        streamExists(streamId)
        onlyRecipient(streamId)
        returns (bool)
    {
        require(amount > 0, "amount is zero");
        Stream memory stream = streams[streamId];

        uint256 balance = currentETHBalanceOf(streamId, stream.recipient);
        require(balance >= amount, "amount exceeds the available balance");
        streams[streamId].remainingBalance = stream.remainingBalance - amount;

        if (streams[streamId].remainingBalance == 0) delete streams[streamId];

        (bool success, ) = payable(stream.recipient).call{value: amount}("");
        require(success, "Ether not withdrawn to recipient");

        emit RecipientWithdrawFromStream(streamId, stream.recipient, amount);
        return true;
    }

    function tipETH(address recipient) external payable {
        require(recipient != address(0x00), "Stream to the zero address");
        require(msg.value > .0001 ether, "Ether sent is lower than minimum");
        (bool success, ) = payable(recipient).call{value: msg.value}("");
        require(success, "Ether not sent successfully");
    }

    //------------------- View Functions ------------------- //

    /**
     * @notice Returns the stream with all its properties.
     * @dev Throws if the id does not point to a valid stream.
     * @param streamId The id of the stream to query.
     * @return The stream object.
     */
    function getStream(uint256 streamId)
        external
        view
        streamExists(streamId)
        returns (Stream memory)
    {
        return streams[streamId];
    }

    /**
     * @notice Returns an array of streams associated with sender.
     * @param sender The address of the sender to query.
     * @return Array of streams associated with the sender.
     */
    function getAllStreamsBySender(address sender)
        external
        view
        returns (Stream[] memory)
    {
        uint256 totalStreams = streamIds.current();
        uint256 totalSenderStreams = 0;
        uint256 resultStreamId = 0;

        for (uint256 i = 0; i <= totalStreams; i++) {
            if (streams[i].sender == sender) {
                totalSenderStreams++;
            }
        }

        Stream[] memory senderStreams = new Stream[](totalSenderStreams);

        for (uint256 i = 0; i < totalStreams; i++) {
            if (streams[i].sender == sender) {
                senderStreams[resultStreamId] = streams[i];
                resultStreamId++;
            }
        }
        return senderStreams;
    }

    /**
     * @notice Returns an array of streams associated with recipient.
     * @param recipient The address of the recipient to query.
     * @return Array of streams associated with the recipient.
     */
    function getAllStreamsByRecipient(address recipient)
        external
        view
        returns (Stream[] memory)
    {
        uint256 totalStreams = streamIds.current();
        uint256 totalRecipientStreams = 0;
        uint256 resultStreamId = 0;

        for (uint256 i = 0; i <= totalStreams; i++) {
            if (streams[i].recipient == recipient) {
                totalRecipientStreams++;
            }
        }

        Stream[] memory recipientStreams = new Stream[](totalRecipientStreams);

        for (uint256 i = 0; i < totalStreams; i++) {
            if (streams[i].recipient == recipient) {
                recipientStreams[resultStreamId] = streams[i];
                resultStreamId++;
            }
        }
        return recipientStreams;
    }

    /**
     * @notice Returns the available funds for the given stream id and address.
     * @dev Throws if the id does not point to a valid stream.
     * @param streamId The id of the stream for which to query the balance.
     * @param who The address for which to query the balance.
     * @return balance The total funds allocated to `who` as uint256.
     */
    function currentETHBalanceOf(uint256 streamId, address who)
        public
        view
        streamExists(streamId)
        returns (uint256 balance)
    {
        uint256 recipientBalance;
        Stream memory stream = streams[streamId];
        uint256 delta = timeDeltaOf(streamId);
        uint256 totalRecipientBalance = delta * stream.ratePerSecond;

        /*
         * If the stream `balance` does not equal `deposit`, it means there have been withdrawals.
         * We have to subtract the total amount withdrawn from the amount of money that has been
         * streamed until now.
         */

        if (stream.deposit > stream.remainingBalance) {
            uint256 withdrawalAmount = stream.deposit - stream.remainingBalance;
            recipientBalance = totalRecipientBalance - withdrawalAmount;
            return recipientBalance;
        }

        if (who == stream.recipient) {
            return totalRecipientBalance;
        }

        if (who == stream.sender) {
            /* `recipientBalance` cannot and should not be bigger than `remainingBalance`. */
            uint256 senderBalance = stream.remainingBalance -
                totalRecipientBalance;
            return senderBalance;
        }
        // return 0;
    }

    /**
     * @notice Returns either the delta in seconds between `block.timestamp` and `startTime` or
     *  between `stopTime` and `startTime, whichever is smaller. If `block.timestamp` is before
     *  `startTime`, it returns 0.
     * @dev Throws if the id does not point to a valid stream.
     * @param streamId The id of the stream for which to query the delta.
     * @return The time delta in seconds.
     */
    function timeDeltaOf(uint256 streamId)
        public
        view
        streamExists(streamId)
        returns (uint256)
    {
        Stream memory stream = streams[streamId];
        if (block.timestamp <= stream.startTime) {
            return 0;
        }
        if (block.timestamp < stream.stopTime) {
            return block.timestamp - stream.startTime;
        }

        return stream.stopTime - stream.startTime;
    }
}
