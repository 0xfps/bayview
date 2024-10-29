// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IPythOracle {
    function oracleAddress() external view returns (address);
    function getETHPriceInUSD() external view returns (uint256 price, uint256 exponent);
}