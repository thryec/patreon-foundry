//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Profiles {
    mapping(address => bytes32) public profiles; // maps user addresses to IPFS hash containing user data

    function addProfile(address user, bytes32 ipfsHash) public {
        profiles[user] = ipfsHash;
    }

    function getProfile(address user) public view returns (bytes32 ipfsHash) {
        return profiles[user];
    }
}
