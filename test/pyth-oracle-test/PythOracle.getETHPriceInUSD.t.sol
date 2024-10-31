// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IPyth } from "@pyth/IPyth.sol";

import { console } from "forge-std/console.sol";

import { PythOracleTest } from "./PythOracle.t.sol";
import { PythStructs } from "@pyth/PythStructs.sol";

contract PythOracleGetETHPriceInUSDTest is PythOracleTest {
    PythStructs.Price internal mockPrice = PythStructs.Price({
        price: -2,
        conf: 3,
        expo: 1,
        publishTime: 4
    });

    function testGetETHPriceInUSDTestAndReturnProperPrice() public view {
        (uint256 price, uint256 precision) = pyth.getETHPriceInUSD();

        console.log("Price:", price);
        console.log("Precision:", precision);
    }

    function testGetETHPriceInUSDTestAndReturnZeroPrice() public {
        vm.mockCall(
            pythOracleArbitrumSepoliaAddress, 
            abi.encodeWithSelector(IPyth(pythOracleArbitrumSepoliaAddress).getPriceNoOlderThan.selector), 
            abi.encode(mockPrice)
        );

        PythStructs.Price memory p = IPyth(pythOracleArbitrumSepoliaAddress).getPriceNoOlderThan(
            ETH_USD_ID, 
            THREE_HOURS
        );

        console.log("Mocked Price is:", p.price);

        vm.expectRevert();
        pyth.getETHPriceInUSD();
        vm.clearMockedCalls();
    }
}