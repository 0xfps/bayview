// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "./interfaces/IBayviewContinuousToken.sol";
import { IBayviewContinuousTokenFactory } from "./interfaces/IBayviewContinuousTokenFactory.sol";

import "./errors/Errors.sol";
import { BayviewContinuousToken } from "./BayviewContinuousToken.sol";

contract BayviewContinuousTokenFactory is IBayviewContinuousTokenFactory {
    uint256 public constant MIN_DEPLOYMENT_FEE = 1e13;
    
    address public immutable pythOracleAddress;
    address public immutable WETH;
    address public immutable nonFungiblePositionManager;

    uint256 public bayviewTokenDeploymentCount;
    bool public initialized;
    mapping(address bayviewToken => bool isBayViewToken) public bayviewTokenMap;

    modifier factoryInitialized {
        if (!initialized) revert Uninitialized();
        _;
    }

    fallback () external payable {}
    receive () external payable {}

    constructor (
        address _nonFungiblePositionManager,
        address _pythOracleAddress,
        address _weth
    ) {
        pythOracleAddress = _pythOracleAddress;
        WETH = _weth;
        nonFungiblePositionManager = _nonFungiblePositionManager;
    }

    function deployBayviewContinuousToken(string memory name, string memory symbol) 
        public
        payable
        factoryInitialized
        returns (address token)
    {
        if (msg.value < MIN_DEPLOYMENT_FEE) revert LowDeploymentFee();

        token = address(new BayviewContinuousToken(
            name,
            symbol,
            nonFungiblePositionManager,
            pythOracleAddress,
            WETH
        ));

        uint256 initialReserve = msg.value / 2;
        (bool sent, ) = token.call{ value: initialReserve }("");
        if (!sent) revert ValueNotSent(initialReserve);

        bayviewTokenMap[token] = true;
        ++bayviewTokenDeploymentCount;
    }

    function buy(IBayviewContinuousToken token) public payable returns (uint256 amountMinted) {
        amountMinted = token.mint{ value: msg.value }(msg.sender);
        emit Buy(address(token), amountMinted, msg.value);
    }
    function sell(IBayviewContinuousToken token, uint256 amount) public returns (uint256 valueReceived) {
        valueReceived = token.retire(msg.sender, amount);
        emit Sell(address(token), amount, valueReceived);
    }

    function emitBuy(uint256 amountMinted, uint256 value) external {
        if (bayviewTokenMap[msg.sender])
            emit Buy(msg.sender, amountMinted, value);
    }

    function emitSell(uint256 amountSold, uint256 valueReceived) external {
        if (bayviewTokenMap[msg.sender])
            emit Sell(msg.sender, amountSold, valueReceived);
    }
}