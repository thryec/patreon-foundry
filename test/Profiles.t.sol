// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Profiles.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

contract ProfileTest is Test {
    Profiles internal profile;

    address alice = address(0x1);
    address bob = address(0x2);

    string testLink1 =
        "https://ipfs.infura.io/ipfs/bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7a";
    string testLink2 =
        "https://ipfs.infura.io/ipfs/bafybohc3gokgtwtxnfwgalh7qftpipwrjlk7lxifwfgrajnvk52q";
    string emptyString = "";

    function setUp() public {
        profile = new Profiles();
    }

    function testAddProfile() public {
        profile.addProfile(alice, testLink1);
        string memory aliceProfile = profile.getProfile(alice);
        assertEq(aliceProfile, testLink1);
    }

    function testUpdateProfile() public {
        vm.prank(alice);
        profile.updateProfile(alice, testLink2);
        string memory aliceProfile = profile.getProfile(alice);
        assertEq(aliceProfile, testLink2);
    }

    function testUpdateProfileRequiresOwner() public {
        vm.expectRevert(bytes("updating requires sender to be owner"));
        profile.updateProfile(alice, testLink2);
    }

    function testDeleteProfile() public {
        vm.prank(alice);
        profile.deleteProfile(alice);
        string memory aliceProfile = profile.getProfile(alice);
        assertEq(aliceProfile, emptyString);
    }

    function testDeleteProfileRequiresOwner() public {
        vm.expectRevert(bytes("deleting requires sender to be owner"));
        profile.deleteProfile(alice);
    }
}
