// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Addresses } from "../__utils__/Addresses.sol";
import { BayviewContinuousToken } from "../../contracts/BayviewContinuousToken.sol";

contract BayviewContinuousTokenTest is Addresses {
    BayviewContinuousToken public bayview;
    uint256 public forkId;

    function setUp() public {
        forkId = vm.createSelectFork(arbitrumSepoliaRPC);

        vm.prank(owner); // Assume Controller is also owner.

        bayview = new BayviewContinuousToken(
            "Big Latina Booty",
            "$BLB",
            nonFungiblePositionManager,
            pythOracleArbitrumSepoliaAddress,
            WETH,
            owner
        );
    }
}