// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

abstract contract Addresses is Test {
    address public owner = vm.addr(1);
    address public hacker = vm.addr(666);

    address public alice = vm.addr(0xa);
    address public bob = vm.addr(0xb);
    address public chris = vm.addr(0xc);
    address public dick = vm.addr(0xc);
    address public finn = vm.addr(0xf);

    address public randomAddress = vm.addr(uint256(block.timestamp));
    address public zero = address(0);

    string public arbitrumSepoliaRPC = "https://arbitrum-sepolia.blockpi.network/v1/rpc/public";
    address public pythOracleArbitrumSepoliaAddress = 0x4374e5a8b9C22271E9EB878A2AA31DE97DF15DAF;
    
    bytes32 internal constant ETH_USD_ID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;
    uint16 internal THREE_HOURS = 60 * 60 * 3; 
}