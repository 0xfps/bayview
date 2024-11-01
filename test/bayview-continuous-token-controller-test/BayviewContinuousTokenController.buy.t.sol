// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "../../contracts/interfaces/IBayviewContinuousToken.sol";

import { BayviewContinuousTokenControllerTest } from "./BayviewContinuousTokenController.t.sol";

contract BayviewContinuousTokenControllerBuyTest is BayviewContinuousTokenControllerTest {
    modifier setup() {
        vm.deal(owner, 5 ether);
        vm.deal(bob, 5 ether);

        vm.prank(owner);
        token = IBayviewContinuousToken(
            controller.deployBayviewContinuousToken{ value: 2 ether } (
                "Big Booty Latina",
                "$BLB"
            )
        );

        _;
    }

    function testBuy() public setup {
        vm.prank(bob);
        controller.buy{ value: 2 ether }(token);
    }
}