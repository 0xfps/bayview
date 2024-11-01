// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { INonFungiblePositionManager } from "./interfaces/INonFungiblePositionManager.sol";

/**
 * @title   PoolCreator.
 * @author  fps <@0xfps>.
 * @notice  This contract handles the creation of a UniswapV3 pool.
 */

abstract contract PoolCreator {
    address internal immutable WETH;
    uint24 internal constant FEE = 3000;

    INonFungiblePositionManager internal immutable nonFungiblePositionManager;

    constructor(address _nonFungiblePositionManager, address _weth) {
        nonFungiblePositionManager = INonFungiblePositionManager(_nonFungiblePositionManager);
        WETH = _weth;
    }

    function _createNewPoolIfNecessary(uint160 sqrtPriceX96) internal returns (address pool) {
        (address token0, address token1) = _getToken0Token1(); 
        pool = nonFungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            FEE,
            sqrtPriceX96
        );
    }

    function _getToken0Token1() internal view returns (address, address) {
        return address(this) < WETH ? (address(this), WETH) : (WETH, address(this));
    }
}