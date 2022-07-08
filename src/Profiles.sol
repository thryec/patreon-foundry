//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";

contract Profiles {
    mapping(address => bytes32) public profiles; // maps user addresses to IPFS hash containing user data
    address[] public addressList; // stores address of all profiles

    function addProfile(address user, bytes32 ipfsHash) public {
        profiles[user] = ipfsHash;
        addressList.push(user);
    }

    function updateProfile(address user, bytes32 updatedHash) public {
        require(msg.sender == user);
        profiles[user] = updatedHash;
    }

    function deleteProfile(address user) public {
        require(msg.sender == user);
        delete profiles[user];
    }

    function getProfile(address user) public view returns (bytes32 ipfsHash) {
        return profiles[user];
    }

    function getAllProfiles() public view {
        uint256 totalProfiles = addressList.length;
        console.log("total profiles", totalProfiles);
    }
}
