//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract Profiles {
    using Counters for Counters.Counter;
    Counters.Counter private profileId; // track number of unique profiles

    mapping(address => string) public profiles; // maps user addresses to IPFS hash containing user data
    address[] public addressList; // stores address of all profiles

    function addProfile(address user, string calldata ipfsHash) public {
        profiles[user] = ipfsHash;
        if (addressList.length == 0) {
            addressList.push(user);
        } else {
            for (uint256 i = 0; i < addressList.length; i++) {
                if (addressList[i] != user) {
                    addressList.push(user);
                }
            }
        }
    }

    function deleteProfile(address user) public {
        require(msg.sender == user, "deleting requires sender to be owner");
        delete profiles[user];

        uint256 addressNum = addressList.length;
        console.log("start address length", addressList.length);
        for (uint256 i = 0; i < addressNum; i++) {
            if (addressList[i] == user) {
                // console.log("current address", addressList[i]); // alice
                // console.log("last index", addressList.length - 1); // length of array = 2
                // addressList[i] = addressList[addressList.length - 1];
                console.log("current address", addressList[0]);
                addressList.pop();
            }
        }
        console.log("end address length", addressList.length);
    }

    function getProfile(address user)
        public
        view
        returns (string memory ipfsHash)
    {
        return profiles[user];
    }

    function getAllProfiles() public view returns (string[] memory) {
        uint256 totalProfiles = addressList.length;
        string[] memory allProfiles = new string[](totalProfiles);
        for (uint256 i = 0; i < totalProfiles; i++) {
            string memory currentProfile = profiles[addressList[i]];
            allProfiles[i] = currentProfile;
        }
        return allProfiles;
    }
}
