// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "../../contracts/interfaces/IBayviewContinuousToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { BayviewContinuousTokenControllerTest } from "./BayviewContinuousTokenController.t.sol";

contract BayviewContinuousTokenControllerEmitBuyTest is BayviewContinuousTokenControllerTest {

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

        vm.prank(bob);
        _;
    }
    function testEmitBuyWithCallFromController(uint256 amount, uint256 value) public {
        vm.prank(address(token));
        controller.emitBuy(amount, value);
    }

    function testEmitBuyWithCallFromCaller(address caller, uint256 amount, uint256 value) public {
        vm.assume(caller != address(0));
        vm.prank(caller);
        controller.emitBuy(amount, value);
    }
}