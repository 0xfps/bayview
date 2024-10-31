// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title   IBayviewContinuousToken.
 * @author  fps (@0xfps).
 * @notice  An interface for the BayviewContinuousToken contract.
 */

interface IBayviewContinuousToken {
    event Mint(
        address indexed mintedBy,
        uint256 indexed amount,
        uint256 indexed value
    );

    event Retire(
        address indexed retiredBy,
        uint256 indexed amount,
        uint256 indexed value
    );
  
    function price() external view returns (uint256);
    function reserveWeight() external view returns (uint32);
    function getReserveBalance() external view returns (uint256);

    function mint(address recipient) external payable returns (uint256 amountMinted);
    function retire(address retiree, uint256 amount) external returns (uint256 salePrice);

    function reserveTokenPriceForAmount(uint256 amount) external view returns (uint256);
    function quantityToBuyWithDepositAmount(uint256 amount) external view returns (uint256);
    function valueToReceiveAfterTokenAmountSale(uint256 amount) external view returns (uint256);
}