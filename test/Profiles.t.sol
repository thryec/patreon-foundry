// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Profiles.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

contract ProfileTest is Test {
    Profiles internal profile;

    function setUp() {
        profile = new Profiles();
    }

    function testAddingProfile() {}

    function testGettingProfile() {}
}
