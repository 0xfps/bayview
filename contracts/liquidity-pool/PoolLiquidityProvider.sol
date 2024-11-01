// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { INonFungiblePositionManager } from "./interfaces/INonFungiblePositionManager.sol";

import { PoolCreator } from "./PoolCreator.sol";

/**
 * @title   PoolLiquidityProvider.
 * @author  fps <@0xfps>.
 * @notice  This contract handles the addition of liquidity to the created UniswapV3 pool.
 */

abstract contract PoolLiquidityProvider is PoolCreator {
    uint16 internal constant THIRTY_MINUTES = 60 * 30;

    // Uniswap @ https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/TickMath.sol#L9-L11
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;
    
    address internal constant RECIPIENT = address(1);

    constructor (address _nonFungiblePositionManager, address _weth)
        PoolCreator(_nonFungiblePositionManager, _weth) {}

    function _addLiquidity(uint256 bayviewTokenAmount, uint256 wethAmount) internal returns (uint128) {
        (address token0, address token1) = _getToken0Token1(); 
        (uint256 amount0, uint256 amount1) = _getAmount0Amount1(bayviewTokenAmount, wethAmount);

        INonFungiblePositionManager.MintParams memory mintParams = 
        INonFungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: FEE,
            tickLower: MIN_TICK,
            tickUpper: MAX_TICK,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: 0,
            amount1Min: 0,
            recipient: RECIPIENT,
            deadline: block.timestamp + THIRTY_MINUTES
        });

        (, uint128 liquidity, , ) = nonFungiblePositionManager.mint(mintParams);
        return liquidity;
    }

    function _getAmount0Amount1(uint256 bayviewTokenAmount, uint256 wethAmount) internal view returns (uint256, uint256) {
        (address token0,) = _getToken0Token1();
        return token0 == address(this) ? (bayviewTokenAmount, wethAmount) : (wethAmount, bayviewTokenAmount);
    }
}