// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { IPyth } from "@pyth/IPyth.sol";

import { PriceBelowZero } from "../errors/Errors.sol";
import { PythStructs } from "@pyth/PythStructs.sol";

/**
 * @title   PythOracle.
 * @author  fps <@0xfps>.
 * @notice  This contract handles the retrieval of ETH/USD prices from Pyth oracles.
 */

abstract contract PythOracle {
    IPyth internal immutable pyth;
    bytes32 internal constant ETH_USD_ID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;
    uint16 internal THREE_HOURS = 60 * 60 * 3; 

    constructor(IPyth _pyth) {
        pyth = _pyth;
    }

    function oracleAddress() public view returns (address) {
        return address(pyth);
    }

    function getETHPriceInUSD() internal view returns (uint256 price, uint256 exponent) {
        PythStructs.Price memory priceStruct = pyth.getPriceNoOlderThan(ETH_USD_ID, THREE_HOURS);
        
        _checkPriceBelowZero(priceStruct);

        price = uint256(int256(priceStruct.price));
        exponent = uint256(int256(-1 * priceStruct.expo));
    }

    function _checkPriceBelowZero(PythStructs.Price memory priceStruct) internal pure {
        if (priceStruct.price < 0) revert PriceBelowZero(priceStruct.price);
    }
}