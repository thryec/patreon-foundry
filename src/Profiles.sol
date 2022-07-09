//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";

contract Profiles {
    mapping(address => string) public profiles; // maps user addresses to IPFS hash containing user data
    address[] public addressList; // stores address of all profiles

    function addProfile(address user, string calldata ipfsHash) public {
        profiles[user] = ipfsHash;
        addressList.push(user);
    }

    function deleteProfile(address user) public {
        require(msg.sender == user, "deleting requires sender to be owner");
        delete profiles[user];
        uint256 addressNum = addressList.length;

        for (uint256 i = 0; i < addressNum; i++) {
            if (addressList[i] == user) {
                delete addressList[i];
            }
        }
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
