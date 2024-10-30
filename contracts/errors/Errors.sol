// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

error Locked();
error BurnExceedsBalance();
error InvalidCaller();
error LiquidityNotAdded();
error LowDeploymentFee();
error PoolNotCreated();
error PoolInitialized();
error PriceBelowZero(int64);
error Uninitialized();
error ValueNotSent(uint256);