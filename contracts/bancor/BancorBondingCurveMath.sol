//SPDX-License-Identifier: Bancor LICENSE
pragma solidity ^0.8.0;

import { SafeMath } from "./libraries/SafeMath.sol";

import { Power } from "./Power.sol";

/**
 * @title   BancorBondingCurveMath.
 * @author  Bancor <https://github.com/bancorprotocol>.
 * @notice  Bancor bonding curve math, originally named `BancorFormula`, is a source code owned by Bancor Protocol, lifted from
 *          https://github.com/bancorprotocol/contracts-solidity/blob/master/solidity/contracts/converter/BancorFormula.sol
 *          with some minor alterations. The code used in this smart contract was copied from Slothman <https://github.com/slothman3878>,
 *          at https://github.com/slothman3878/bondingcurve/blob/main/contracts/BancorFormula/BancorFormula.sol.
 */

abstract contract BancorBondingCurveMath is Power {
  using SafeMath for uint256;

  uint32 private constant MAX_WEIGHT = 1_000_000;

  /**
   * @dev Returns the price of the token at any given time.
   * 
   * @param reserveBalance  Reserve balance in ETH. 
   * @param totalSupply     Total supply.
   * @param reserveWeight   Reserve weight in 6 decimals.
   * 
   * @return uint256 Price.
   */
  function price(
    uint256 reserveBalance,
    uint256 totalSupply,
    uint32 reserveWeight
    ) internal view virtual returns (uint256) {
      return (reserveBalance.div(totalSupply)).mul(MAX_WEIGHT / reserveWeight);
  }

  /**
    * @dev  Given a token supply, reserve balance, weight and an amount (in the main token),
    *       calculates the amount of reserve tokens required for purchasing the given amount
    *       of pool tokens.
    *
    *       Formula:
    *       return = _reserveBalance * ((_amount / _supply + 1) ^ (1000000 / _reserveWeight) - 1)
    *
    * @param _supply          Liquid token supply.
    * @param _reserveBalance  Reserve balance.
    * @param _reserveWeight   Reserve weight, represented in ppm (1-1000000).
    * @param _amount          Requested amount of pool tokens.
    *
    * @return Reserve token amount.
    */
  function reserveTokenPriceForAmount(
    uint256 _supply,
    uint256 _reserveBalance,
    uint32 _reserveWeight,
    uint256 _amount
  ) internal view virtual returns (uint256) {
    require(_supply > 0, "ERR_INVALID_SUPPLY");
    require(_reserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");
    require(_reserveWeight > 0 && _reserveWeight <= MAX_WEIGHT, "ERR_INVALID_RESERVE_RATIO");

    if (_amount == 0) return 0;
    if (_reserveWeight == MAX_WEIGHT) return (_amount.mul(_reserveBalance) - 1) / _supply + 1;

    uint256 baseN = _supply.add(_amount);
    (uint256 result, uint8 precision) = power(baseN, _supply, MAX_WEIGHT, _reserveWeight);
    uint256 temp = (_reserveBalance.mul(result) - 1) >> precision;
    return temp - _reserveBalance;
  }

  /**
    * @dev  Given a token supply, reserve balance, weight and a deposit amount (in the reserve token),
    *       calculates the target amount for a given conversion (in the main token).
    *
    *       Formula:
    *       return = _supply * ((1 + _amount / _reserveBalance) ^ (_reserveWeight / 1000000) - 1)
    *
    * @param _supply          Liquid token supply.
    * @param _reserveBalance  Reserve balance.
    * @param _reserveWeight   Reserve weight, represented in ppm (1-1000000).
    * @param _amount          Amount of reserve tokens to get the target amount for.
    *
    * @return Quantity of tokens that can be purchased.
    */
  function quantityToBuyWithDepositAmount(
    uint256 _supply,
    uint256 _reserveBalance,
    uint32 _reserveWeight,
    uint256 _amount
  ) internal view virtual returns (uint256) {
    require(_supply > 0, "ERR_INVALID_SUPPLY");
    require(_reserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");
    require(_reserveWeight > 0 && _reserveWeight <= MAX_WEIGHT, "ERR_INVALID_RESERVE_WEIGHT");

    if (_amount == 0) return 0;
    if (_reserveWeight == MAX_WEIGHT) return _supply.mul(_amount) / _reserveBalance;

    uint256 baseN = _amount.add(_reserveBalance);
    (uint256 result, uint8 precision) = power(baseN, _reserveBalance, _reserveWeight, MAX_WEIGHT);
    uint256 temp = (_supply.mul(result) >> precision) + 1;
    return temp - _supply;
  }

  /**
    * @dev  Given a token supply, reserve balance, weight and a sell amount (in the main token),
    *       calculates the target amount for a given conversion (in the reserve token).
    *
    *       Formula:
    *       return = _reserveBalance * (1 - (1 - _amount / _supply) ^ (1000000 / _reserveWeight))
    *
    * @param _supply          Liquid token supply.
    * @param _reserveBalance  Reserve balance.
    * @param _reserveWeight   Reserve weight, represented in ppm (1-1000000).
    * @param _amount          Amount of liquid tokens to get the target amount for.
    *
    * @return Reserve token amount.
    */
  function valueToReceiveAfterTokenAmountSale(
    uint256 _supply,
    uint256 _reserveBalance,
    uint32 _reserveWeight,
    uint256 _amount
  ) internal view virtual returns (uint256) {
    require(_supply > 0, "ERR_INVALID_SUPPLY");
    require(_reserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");
    require(_reserveWeight > 0 && _reserveWeight <= MAX_WEIGHT, "ERR_INVALID_RESERVE_WEIGHT");
    require(_amount <= _supply, "ERR_INVALID_AMOUNT");

    if (_amount == 0) return 0;
    if (_amount == _supply) return _reserveBalance;
    if (_reserveWeight == MAX_WEIGHT) return _reserveBalance.mul(_amount) / _supply;

    uint256 baseD = _supply - _amount;
    (uint256 result, uint8 precision) = power(_supply, baseD, MAX_WEIGHT, _reserveWeight);
    uint256 temp1 = _reserveBalance.mul(result);
    uint256 temp2 = _reserveBalance << precision;
    return (temp1 - temp2) / result;
  }
}