// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "../../contracts/interfaces/IBayviewContinuousToken.sol";

import { console } from "forge-std/console.sol";

import { BayviewContinuousTokenTest } from "./BayviewContinuousToken.t.sol";

contract BayviewContinuousTokenRetireTest is BayviewContinuousTokenTest {
    function testRetireAfterPoolInitialized() public {
        vm.deal(alice, 505 ether);
        vm.prank(alice);
        bayview.mint{ value: 500 ether }(alice);

        vm.expectRevert();
        vm.prank(alice);
        bayview.retire(alice, 24504781340937707);
    }

    function testNonReentrant() public {
        _mint();
        vm.expectRevert();
        vm.prank(address(this));
        bayview.retire(address(this), 100000000000000);
    }

    function testRetireWithCallFromNonRetireeOrController() public {
        vm.expectRevert();
        vm.prank(chris);
        bayview.retire(alice, 10000000000);
    }

    function testRetireWithAmountGreaterThanBalance() public {
        _mint();
        vm.expectRevert();
        vm.prank(bob);
        bayview.retire(bob, 1);
    }

    function testEmit() public {
        _mint();
        vm.prank(address(controller));
        bayview.retire(alice, 1000000000);
    }

    function _mint() internal {
        vm.deal(alice, 505 ether);
        vm.prank(alice);
        bayview.mint{ value: 12 ether }(alice);

    }

    receive() external payable {
        vm.prank(address(this));
        bayview.retire(address(this), 100000000000000);
    }
}