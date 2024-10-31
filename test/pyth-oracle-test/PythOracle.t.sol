// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IPyth } from "@pyth/IPyth.sol";

import { Addresses } from "../__utils__/Addresses.sol";
import { PythOracle } from "../../contracts/oracles/PythOracle.sol";

contract PythOracleTest is Addresses {
    PythOracle public pyth;
    uint256 public forkId;

    function setUp() public {
        forkId = vm.createSelectFork(arbitrumSepoliaRPC);
        pyth = new PythOracle(IPyth(pythOracleArbitrumSepoliaAddress));
    }

    function testSetUp() public view {
        assertTrue(pyth != PythOracle(address(0)));
        assertTrue(pyth.oracleAddress() != address(pyth));
    }
}