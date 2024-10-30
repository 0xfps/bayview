// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IBayviewContinuousToken {
    event Mint(
        address indexed mintedBy,
        uint256 indexed amount
    );

    event Retire(
        address indexed retiredBy,
        uint256 indexed amount,
        uint256 value
    );
  
    function price() external view returns (uint256 price);
    function getReserve() external view returns (uint256 reserve);
    function reserveWeight() external view returns (uint32 weight);

    function mint() external payable returns (uint256 amountMinted);
    function retire() external payable returns (uint256 valueReceived);

    function reserveTokenPriceForAmount(uint256 amount) external view returns (uint256);
    function quantityToBuyWithDepositAmount(uint256 amount) external view returns (uint256);
    function valueToReceiveAfterTokenAmountSale(uint256 amount) external view returns (uint256);
}