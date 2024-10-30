// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "./interfaces/IBayviewContinuousToken.sol";
import { IPythOracle } from "./oracles/interfaces/IPythOracle.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { BancorBondingCurveMath } from "./bancor/BancorBondingCurveMath.sol";