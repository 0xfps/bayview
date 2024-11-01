// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IPyth } from "@pyth/IPyth.sol";

import { console } from "forge-std/console.sol";

import { Addresses } from "../__utils__/Addresses.sol";
import { BayviewContinuousToken } from "../../contracts/BayviewContinuousToken.sol";
import { BayviewContinuousTokenController } from "../../contracts/BayviewContinuousTokenController.sol";
import { PythOracle } from "../../contracts/oracles/PythOracle.sol";

contract BayviewContinuousTokenTest is Addresses {
    BayviewContinuousToken public bayview;
    BayviewContinuousTokenController public controller;
    PythOracle public pyth;
    uint256 public forkId;

    function setUp() public {
        forkId = vm.createSelectFork(arbitrumSepoliaRPC);

        pyth = new PythOracle(IPyth(pythOracleArbitrumSepoliaAddress));

        controller = new BayviewContinuousTokenController(
            nonFungiblePositionManager,
            address(pyth),
            WETH
        );

        vm.prank(address(controller));
        bayview = new BayviewContinuousToken(
            "Big Latina Booty",
            "$BLB",
            nonFungiblePositionManager,
            address(pyth),
            WETH,
            owner
        );

        vm.deal(address(bayview), 1e13);
    }

    function testSetUp() public view {
        bool iss = address(bayview) < address(WETH);
        console.log(iss); 
        assertTrue(address(bayview) != address(0));
        assertTrue(bayview.pool() == address(0));
        assertTrue(bayview.owner() == owner);
        assertTrue(address(bayview.pythOracle()) == address(pyth));
        assertTrue(bayview.controller() == address(controller));
        assertTrue(bayview.balanceOf(address(controller)) == 1e18);
    }
}