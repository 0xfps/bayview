// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { INonFungiblePositionManager } from "./interfaces/INonFungiblePositionManager.sol";

import { PoolCreator } from "./PoolCreator.sol";

contract PoolLiquidityProvider is PoolCreator {
    constructor (address _nonFungiblePositionManager)
        PoolCreator(_nonFungiblePositionManager) {}

    function _addLiquidity(INonFungiblePositionManager.MintParams memory mintParams) internal {
        nonFungiblePositionManager.mint(mintParams);
    }
}