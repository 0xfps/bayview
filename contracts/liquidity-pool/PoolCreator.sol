// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { INonFungiblePositionManager } from "./interfaces/INonFungiblePositionManager.sol";

abstract contract PoolCreator {
    INonFungiblePositionManager internal immutable nonFungiblePositionManager;
    constructor(address _nonFungiblePositionManager) {
        nonFungiblePositionManager = INonFungiblePositionManager(_nonFungiblePositionManager);
    }

    function _createNewPoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) internal returns (address pool) {
        pool = nonFungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            fee,
            sqrtPriceX96
        );
    }
}