//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {console} from "forge-std/console.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract Profiles {
    using Counters for Counters.Counter;
    Counters.Counter private profileId; // track number of unique profiles

    mapping(address => string) public profiles; // maps user addresses to IPFS hash containing user data
    address[] public addressList; // stores address of all profiles

    function addProfile(address user, string calldata ipfsHash) external {
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

    function deleteProfile(address user) external {
        require(msg.sender == user, "deleting requires sender to be owner");
        delete profiles[user];

        for (uint256 i = 0; i < addressList.length; i++) {
            if (addressList[i] == user) {
                addressList[i] = addressList[addressList.length - 1];
                addressList.pop();
            }
        }
    }

    function getProfile(address user)
        external
        view
        returns (string memory ipfsHash)
    {
        return profiles[user];
    }

    function getAllProfiles() external view returns (string[] memory) {
        uint256 totalProfiles = addressList.length;
        string[] memory allProfiles = new string[](totalProfiles);
        for (uint256 i = 0; i < totalProfiles; i++) {
            string memory currentProfile = profiles[addressList[i]];
            allProfiles[i] = currentProfile;
        }
        return allProfiles;
    }
}
