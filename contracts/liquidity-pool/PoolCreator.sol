// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { INonFungiblePositionManager } from "./interfaces/INonFungiblePositionManager.sol";

abstract contract PoolCreator {
    address internal immutable WETH;
    uint24 internal constant FEE = 3000;
    uint160 internal constant SQRT_PRICE_X96 = 5000; // @note Study this and know what it is more.

    INonFungiblePositionManager internal immutable nonFungiblePositionManager;

    constructor(address _nonFungiblePositionManager, address _weth) {
        nonFungiblePositionManager = INonFungiblePositionManager(_nonFungiblePositionManager);
        WETH = _weth;
    }

    function _createNewPoolIfNecessary(address token0) internal returns (address pool) {
        pool = nonFungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            WETH,
            FEE,
            SQRT_PRICE_X96
        );
    }
}