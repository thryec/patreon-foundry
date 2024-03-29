//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {console} from "forge-std/console.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract Profiles {
    using Counters for Counters.Counter;
    Counters.Counter public profileIds; // track number of unique profiles

    mapping(address => string) public profiles; // maps user addresses to IPFS hash containing user data
    mapping(address => uint256) public identities; // maps user addresses to their unique profile Id
    address[] public addressList; // stores address of all profiles

    function addProfile(address user, string calldata ipfsHash) external {
        profiles[user] = ipfsHash;
        if (identities[user] == 0) {
            addressList.push(user);
            profileIds.increment();
            identities[user] = profileIds.current();
        }
    }

    function getProfile(address user)
        external
        view
        returns (string memory ipfsHash)
    {
        return profiles[user];
    }

    function getProfileCount() public view returns (uint256) {
        return profileIds.current();
    }

    function getAllProfiles() external view returns (string[] memory) {
        uint256 totalProfiles = getProfileCount();
        string[] memory allProfiles = new string[](totalProfiles);
        for (uint256 i = 0; i < totalProfiles; i++) {
            string memory currentProfile = profiles[addressList[i]];
            allProfiles[i] = currentProfile;
        }
        return allProfiles;
    }
}
