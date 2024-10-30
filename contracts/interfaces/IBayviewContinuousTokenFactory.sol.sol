// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "./IBayviewContinuousToken.sol";

interface IBayviewContinuousTokenFactory {
    event Buy (
        address indexed bayviewToken,
        uint256 indexed amountPurchased,
        uint256 indexed value
    );
    
    event Sell (
        address indexed bayviewToken,
        uint256 indexed amountSold,
        uint256 indexed value
    );

    function deployBayviewContinuousToken() external payable returns (address token);
    function mint(IBayviewContinuousToken token) external payable returns (uint256 amountMinted);
    function retire(IBayviewContinuousToken token, uint256 amount) external returns (uint256 valueReceived);
}