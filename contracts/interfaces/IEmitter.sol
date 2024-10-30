// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IEmitter {
    function emitBuy(uint256 amountMinted, uint256 value) external;

    function emitSell(uint256 amountSold, uint256 valueReceived) external;
}