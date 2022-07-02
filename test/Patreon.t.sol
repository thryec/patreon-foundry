// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Patreon.sol";
import "ds-test/test.sol";
import "forge-std/Test.sol";

contract PatreonTest is DSTest {
    Patreon patreon;

    function setUp() public {
        patreon = new Patreon();
    }

    function testExample() public {
        assertTrue(true);
    }
}
