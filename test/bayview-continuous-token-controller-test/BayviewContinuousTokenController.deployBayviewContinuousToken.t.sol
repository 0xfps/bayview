// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { BayviewContinuousTokenControllerTest } from "./BayviewContinuousTokenController.t.sol";

contract BayviewContinuousTokenControllerDeployTest is BayviewContinuousTokenControllerTest {
    function testDeployWithLowDeploymentFee() public {
        vm.prank(owner);
        vm.expectRevert();
        controller.deployBayviewContinuousToken{ value: 0 } (
            "Big Booty Latina",
            "$BLB"
        );
    }

    function testDeployWithDeploymentFee() public {
        vm.deal(owner, 5 ether);
        vm.prank(owner);
        address token = controller.deployBayviewContinuousToken{ value: 2 ether } (
            "Big Booty Latina",
            "$BLB"
        );
        assert(token.balance == 1 ether);
    }
}