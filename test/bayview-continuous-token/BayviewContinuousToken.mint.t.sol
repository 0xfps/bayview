// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "../../contracts/interfaces/IBayviewContinuousToken.sol";

import { console } from "forge-std/console.sol";

import { BayviewContinuousTokenTest } from "./BayviewContinuousToken.t.sol";

contract BayviewContinuousTokenMintTest is BayviewContinuousTokenTest {
    function testMintWhenPoolIsUninitialized() public {
        vm.deal(alice, 40 ether);
        console.log("Old Pool ReserveBalance", bayview.getReserveBalance());
        console.log("Old Total Supply", bayview.totalSupply());
        console.log("Alice's address:", alice);
        console.log("Old Pool Price per token:", bayview.price());

        vm.prank(alice);
        bayview.mint{ value: 3 ether }(alice);

        console.log("New Pool ReserveBalance", bayview.getReserveBalance());
        console.log("New Total Supply", bayview.totalSupply());
        console.log("New Pool Price per token:", bayview.price());
    }

    function testMintAndCreatePool() public {
        vm.deal(alice, 505 ether);
        
        console.log("Old Pool ReserveBalance", bayview.getReserveBalance());
        console.log("Old Total Supply", bayview.totalSupply());
        console.log("Alice's address:", alice);
        console.log("Old Pool Price per token:", bayview.price());
        console.log("Old Pool Address:", bayview.pool());

        vm.prank(alice);
        uint256 valueMinted = bayview.mint{ value: 500 ether }(alice);

        console.log("Minted:", valueMinted);
        console.log("New Pool ReserveBalance", bayview.getReserveBalance());
        console.log("New Total Supply", bayview.totalSupply());
        console.log("New Pool Price per token:", bayview.price());
        console.log("Price of sale:", bayview.valueToReceiveAfterTokenAmountSale(bayview.balanceOf(alice)));
        console.log("New Pool Address:", bayview.pool());
    }

    function testMintAndTryCreatePoolCallFromController() public {
        vm.deal(alice, 40 ether);
        vm.startPrank(alice);
        address newToken = controller.deployBayviewContinuousToken{ value: 1 ether }("Big Booty Latina", "$BLB");
        controller.buy{ value: 10 ether }(IBayviewContinuousToken(newToken));
        vm.stopPrank();
    }

    function testMintAfterPoolCreated() public {
        testMintAndCreatePool();

        vm.expectRevert();
        vm.deal(alice, 505 ether);
        vm.prank(alice);
        bayview.mint{ value: 2 ether }(alice);
    }
}
