// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IPyth } from "@pyth/IPyth.sol";
import { IBayviewContinuousToken } from "../../contracts/interfaces/IBayviewContinuousToken.sol";

import { Addresses } from "../__utils__/Addresses.sol";
import { BayviewContinuousTokenController } from "../../contracts/BayviewContinuousTokenController.sol";
import { PythOracle } from "../../contracts/oracles/PythOracle.sol";

contract BayviewContinuousTokenControllerTest is Addresses {
    BayviewContinuousTokenController internal controller;
    IBayviewContinuousToken internal token;
    address pyth;
    uint256 public forkId;

    function setUp() public {
        forkId = vm.createSelectFork(arbitrumSepoliaRPC);

        pyth = address(new PythOracle(IPyth(pythOracleArbitrumSepoliaAddress)));

        controller = new BayviewContinuousTokenController(
            nonFungiblePositionManager,
            pyth,
            WETH
        );
    }

    function testSetUp() public view {
        assertTrue(address(controller) != address(0));
    }
}