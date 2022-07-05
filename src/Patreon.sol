// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./CreatorList.sol";
import {console} from "forge-std/console.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract Patreon is ReentrancyGuard, CreatorList {
    //------------------- Variables ------------------- //
    mapping(uint256 => Stream) public streams; // maps streamIds to stream
    address public contractAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _streamIds; // track unique streamIds

    struct Stream {
        uint256 deposit;
        uint256 ratePerSecond;
        uint256 remainingBalance;
        uint256 startTime;
        uint256 stopTime;
        address recipient;
        address sender;
        bool isEntity;
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

    constructor() {
        contractAddress = address(this);
    }

    //------------------- Mutative Functions ------------------- //

    function createETHStream(
        address _recipient,
        uint256 _startTime,
        uint256 _stopTime
    ) public payable returns (uint256) {
        uint256 _depositAmount = msg.value;
        require(_recipient != address(0x00), "stream to the zero address");
        require(_recipient != address(this), "stream to the contract itself");
        require(_recipient != msg.sender, "stream to the caller");
        require(_depositAmount > 0, "deposit is zero");
        require(
            _startTime >= block.timestamp,
            "start time before block.timestamp"
        );
        require(_stopTime > _startTime, "stop time before the start time");

        uint256 _duration = _stopTime - _startTime;
        uint256 _ratePerSecond = _depositAmount / _duration;

        /* Without this, the rate per second would be zero. */
        require(_depositAmount >= _duration, "deposit smaller than time delta");

        /* This condition avoids dealing with remainders */
        require(
            _depositAmount % _duration == 0,
            "deposit not multiple of time delta"
        );

        uint256 currentStreamId = _streamIds.current();
        streams[currentStreamId] = Stream({
            remainingBalance: _depositAmount,
            deposit: _depositAmount,
            isEntity: true,
            ratePerSecond: _ratePerSecond,
            recipient: _recipient,
            sender: msg.sender,
            startTime: _startTime,
            stopTime: _stopTime
        });

        emit CreateETHStream(
            currentStreamId,
            msg.sender,
            _recipient,
            _depositAmount,
            _startTime,
            _stopTime
        );

        _streamIds.increment();
        return currentStreamId;
    }

    function recipientWithdrawFromStream(uint256 _streamId, uint256 _amount)
        external
        nonReentrant
        streamExists(_streamId)
        onlyRecipient(_streamId)
        returns (bool)
    {
        require(_amount > 0, "amount is zero");
        Stream memory stream = streams[_streamId];

        uint256 balance = currentETHBalanceOf(_streamId, stream.recipient);
        require(balance >= _amount, "amount exceeds the available balance");
        streams[_streamId].remainingBalance = stream.remainingBalance - _amount;

        if (streams[_streamId].remainingBalance == 0) delete streams[_streamId];
        (bool success, ) = payable(stream.recipient).call{value: _amount}("");
        require(success, "Ether not withdrawn to recipient");

        emit RecipientWithdrawFromStream(_streamId, stream.recipient, _amount);
        return true;
    }

    function senderCancelStream(uint256 _streamId)
        external
        nonReentrant
        streamExists(_streamId)
        onlySender(_streamId)
        returns (bool)
    {
        Stream memory stream = streams[_streamId];
        uint256 senderBalance = currentETHBalanceOf(_streamId, stream.sender);
        uint256 recipientBalance = currentETHBalanceOf(
            _streamId,
            stream.recipient
        );

        delete streams[_streamId];

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
            _streamId,
            stream.sender,
            stream.recipient,
            senderBalance,
            recipientBalance
        );
        return true;
    }

    function tipETH(address _recipient) public payable {
        require(msg.value > .0001 ether, "Ether sent is lower than minimum");
        (bool success, ) = payable(_recipient).call{value: msg.value}("");
        require(success, "Ether not sent successfully");
    }

    //------------------- View Functions ------------------- //

    /**
     * @notice Returns the stream with all its properties.
     * @dev Throws if the id does not point to a valid stream.
     * @param _streamId The id of the stream to query.
     * @return The stream object.
     */
    function getStream(uint256 _streamId)
        external
        view
        streamExists(_streamId)
        returns (Stream memory)
    {
        return streams[_streamId];
    }

    /**
     * @notice Returns the available funds for the given stream id and address.
     * @dev Throws if the id does not point to a valid stream.
     * @param _streamId The id of the stream for which to query the balance.
     * @param _who The address for which to query the balance.
     * @return balance The total funds allocated to `who` as uint256.
     */
    function currentETHBalanceOf(uint256 _streamId, address _who)
        public
        view
        streamExists(_streamId)
        returns (uint256 balance)
    {
        uint256 recipientBalance;
        Stream memory stream = streams[_streamId];
        uint256 delta = timeDeltaOf(_streamId);
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

        if (_who == stream.recipient) {
            return totalRecipientBalance;
        }

        if (_who == stream.sender) {
            /* `recipientBalance` cannot and should not be bigger than `remainingBalance`. */
            uint256 senderBalance = stream.remainingBalance - recipientBalance;
            return senderBalance;
        }
        // return 0;
    }

    /**
     * @notice Returns either the delta in seconds between `block.timestamp` and `startTime` or
     *  between `stopTime` and `startTime, whichever is smaller. If `block.timestamp` is before
     *  `startTime`, it returns 0.
     * @dev Throws if the id does not point to a valid stream.
     * @param _streamId The id of the stream for which to query the delta.
     * @return The time delta in seconds.
     */
    function timeDeltaOf(uint256 _streamId)
        public
        view
        streamExists(_streamId)
        returns (uint256)
    {
        Stream memory stream = streams[_streamId];
        if (block.timestamp <= stream.startTime) {
            return 0;
        }
        if (block.timestamp < stream.stopTime) {
            return block.timestamp - stream.startTime;
        }

        return stream.stopTime - stream.startTime;
    }

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
            "caller is not the sender of the stream"
        );
        _;
    }

    /**
     * @dev Throws if the provided id does not point to a valid stream.
     */
    modifier streamExists(uint256 streamId) {
        require(streams[streamId].isEntity, "stream does not exist");
        _;
    }
}
