// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "./IBayviewContinuousToken.sol";
import { IEmitter } from "./IEmitter.sol";

/**
 * @title   IBayviewContinuousTokenController.
 * @author  fps (@0xfps).
 * @notice  An interface for the BayviewContinuousTokenController contract.
 */

interface IBayviewContinuousTokenController is IEmitter {
    event Deploy (address indexed deployer, address indexed bayviewToken);

    event Buy (
        address indexed bayviewToken,
        uint256 indexed amountPurchased,
        uint256 indexed price
    );
    
    event Sell (
        address indexed bayviewToken,
        uint256 indexed amountSold,
        uint256 indexed price
    );

    function deployBayviewContinuousToken(string memory name, string memory symbol) external payable returns (address token);
    function buy(IBayviewContinuousToken token) external payable returns (uint256 amountMinted);
    function sell(IBayviewContinuousToken token, uint256 amount) external returns (uint256 salePrice);
}