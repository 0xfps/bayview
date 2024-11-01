// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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

    function testMintAndTryCreatePool() public {
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
        // console.log("ETH Market Cap:", bayview._calculateMarketCapInETH());
        // console.log("USD Market Cap:", bayview._calculateMarketCapInUSD());
    }
}
