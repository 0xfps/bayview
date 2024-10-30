// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { INonFungiblePositionManager } from "./interfaces/INonFungiblePositionManager.sol";

import { PoolCreator } from "./PoolCreator.sol";

abstract contract PoolLiquidityProvider is PoolCreator {
    uint16 internal constant THIRTY_MINUTES = 60 * 30;
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;
    address internal constant RECIPIENT = address(1);

    constructor (address _nonFungiblePositionManager, address _weth)
        PoolCreator(_nonFungiblePositionManager, _weth) {}

    function _addLiquidity(uint256 bayviewTokenAmount, uint256 wethAmount) internal returns (uint128) {
        INonFungiblePositionManager.MintParams memory mintParams = 
        INonFungiblePositionManager.MintParams({
            token0: address(this),
            token1: WETH,
            fee: FEE,
            tickLower: MIN_TICK,
            tickUpper: MAX_TICK,
            amount0Desired: bayviewTokenAmount,
            amount1Desired: wethAmount,
            amount0Min: 0,
            amount1Min: 0,
            recipient: RECIPIENT,
            deadline: block.timestamp + THIRTY_MINUTES
        });

        (, uint128 liquidity, , ) = nonFungiblePositionManager.mint(mintParams);
        return liquidity;
    }
}