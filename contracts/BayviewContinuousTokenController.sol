// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "./interfaces/IBayviewContinuousToken.sol";
import { IBayviewContinuousTokenController } from "./interfaces/IBayviewContinuousTokenController.sol";

import "./errors/Errors.sol";
import { BayviewContinuousToken } from "./BayviewContinuousToken.sol";

/**
 * @title   BayviewContinuousTokenController.
 * @author  fps <@0xfps>.
 * @notice  This contract deploys new BayviewContinuousToken contracts and acts as a source for
 *          interactions with them.
 *
 * @dev     The controller receives the initial supply of every token it deploys (INITIAL_MINT).
 *          This supply is intentionally held by the controller, which has no function to
 *          transfer or sell it, so it stays locked for the lifetime of the token.
 */

contract BayviewContinuousTokenController is IBayviewContinuousTokenController {
    /**
     * @dev Minimum ETH a deployer must send. This is a seed deposit, not a kept fee:
     *      half seeds the new token's reserve and the other half is returned to the deployer.
     */
    uint256 public constant MIN_DEPLOYMENT_FEE = 1e13;
    
    address public immutable pythOracleAddress;
    address public immutable WETH;
    address public immutable nonFungiblePositionManager;

    uint256 public bayviewTokenDeploymentCount;
    mapping(address bayviewToken => bool isBayViewToken) public bayviewTokenMap;

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
        returns (address token)
    {
        if (msg.value < MIN_DEPLOYMENT_FEE) revert LowDeploymentFee();

        token = address(new BayviewContinuousToken(
            name,
            symbol,
            nonFungiblePositionManager,
            pythOracleAddress,
            WETH,
            msg.sender
        ));

        // Effects before interactions.
        bayviewTokenMap[token] = true;
        ++bayviewTokenDeploymentCount;

        // Split msg.value exactly, so an odd amount never strands 1 wei in the controller.
        uint256 initialReserve = msg.value / 2;
        uint256 refundAmount = msg.value - initialReserve;

        (bool sent, ) = token.call{ value: initialReserve }("");
        if (!sent) revert ValueNotSent(initialReserve);

        (bool refunded, ) = msg.sender.call{ value: refundAmount }("");
        if (!refunded) revert ValueNotSent(refundAmount);
        
        emit Deploy(msg.sender, token);
    }

    function buy(IBayviewContinuousToken token) public payable returns (uint256 amountMinted) {
        amountMinted = token.mint{ value: msg.value }(msg.sender);
        emit Buy(address(token), amountMinted, msg.value);
    }

    function sell(IBayviewContinuousToken token, uint256 amount) public returns (uint256 salePrice) {
        salePrice = token.retire(msg.sender, amount);
        emit Sell(address(token), amount, salePrice);
    }

    function emitBuy(uint256 amountMinted, uint256 value) external {
        if (bayviewTokenMap[msg.sender])
            emit Buy(msg.sender, amountMinted, value);
    }

    function emitSell(uint256 amountSold, uint256 salePrice) external {
        if (bayviewTokenMap[msg.sender])
            emit Sell(msg.sender, amountSold, salePrice);
    }
}
