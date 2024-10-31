// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title   IPythOracle.
 * @author  fps <@0xfps>.
 * @notice  An interface for the PythOracle contract.
 */

interface IPythOracle {
    function oracleAddress() external view returns (address);
    function getETHPriceInUSD() external view returns (uint256 price, uint256 exponent);
}