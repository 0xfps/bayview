// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title   IEmitter.
 * @author  fps (@0xfps).
 * @notice  An interface that permits any BayviewContinuousToken contract deployed
 *          by the BayviewContinuousTokenController to callback to the controller and emit
 *          a buy or sell event if the transaction wasn't sent by the controller.
 */

interface IEmitter {
    function emitBuy(uint256 amountMinted, uint256 value) external;
    function emitSell(uint256 amountSold, uint256 valueReceived) external;
}