// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "./interfaces/IBayviewContinuousToken.sol";
import { IEmitter } from "./interfaces/IEmitter.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPythOracle } from "./oracles/interfaces/IPythOracle.sol";

import { Math } from "./libraries/Math.sol";

import "./errors/Errors.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { BancorBondingCurveMath } from "./bancor/BancorBondingCurveMath.sol";
import { PoolLiquidityProvider } from "./liquidity-pool/PoolLiquidityProvider.sol";

contract BayviewContinuousToken is 
    IBayviewContinuousToken, 
    BancorBondingCurveMath,
    PoolLiquidityProvider,
    ERC20
{
    IPythOracle public pythOracle;

    address public immutable factory;
    IEmitter internal immutable emitter;

    uint64 internal constant INITIAL_MINT = 1e18;
    uint32 public constant reserveWeight = 200_000;
    uint32 public constant BONDING_CURVE_LIMIT = 69_000; 
    uint32 public constant LP_HALF = 15_000;
    
    address public owner;
    address public pool;
    bool internal locked;

    modifier lock {
        if (locked) revert Locked();
        locked = true;
        _;
        locked = false;
    }

    modifier poolNotInitialized() {
        if (pool != address(0)) revert PoolInitialized();
        _;
    }

    constructor (
        string memory name,
        string memory symbol,
        address _nonFungiblePositionManager,
        address _pythOracle,
        address _weth,
        address _owner
    ) ERC20(name, symbol) PoolLiquidityProvider (_nonFungiblePositionManager, _weth) {
        pythOracle = IPythOracle(_pythOracle);
        factory = msg.sender;
        emitter = IEmitter(msg.sender);
        owner = _owner;

        _mint(factory, INITIAL_MINT);
    }

    fallback () external payable {}
    receive () external payable {}

    function price() public view override returns (uint256) {
        return super.price(
            address(this).balance,
            totalSupply(),
            reserveWeight
        );
    }

    function getReserveBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function reserveTokenPriceForAmount(uint256 amount) public view override returns (uint256) {
        return super.reserveTokenPriceForAmount(
            totalSupply(),
            getReserveBalance(),
            reserveWeight,
            amount
        );
    }

    function quantityToBuyWithDepositAmount(uint256 amount) public view override returns (uint256) {
        return super.quantityToBuyWithDepositAmount(
            totalSupply(),
            getReserveBalance(),
            reserveWeight,
            amount
        );
    }

    function valueToReceiveAfterTokenAmountSale(uint256 amount) public view override returns (uint256) {
        return super.valueToReceiveAfterTokenAmountSale(
            totalSupply(),
            getReserveBalance(),
            reserveWeight,
            amount
        );
    }

    function mint(address recipient) public payable poolNotInitialized returns (uint256 amountMinted) {
        uint256 deposit = msg.value;
        amountMinted = quantityToBuyWithDepositAmount(deposit);
        
        _mint(recipient, amountMinted);
        
        _attemptPoolSetup();

        emitter.emitBuy(amountMinted, deposit);
        emit Mint(recipient, amountMinted, deposit);
    }

    function retire(address retiree, uint256 amount) public poolNotInitialized lock returns (uint256 valueReceived) {
        if ((msg.sender != factory) && (msg.sender != retiree)) revert InvalidCaller();
        if (amount > balanceOf(retiree)) revert BurnExceedsBalance();
        
        _burn(retiree, amount);

        valueReceived = valueToReceiveAfterTokenAmountSale(amount);
        (bool sent, ) = retiree.call{ value: valueReceived }("");
        
        _validateSending(sent, valueReceived);
        
        emitter.emitSell(amount, valueReceived);
        emit Retire(retiree, amount, valueReceived);
    }

    function _validateSending(bool sent, uint256 value) internal pure {
        if (!sent) revert ValueNotSent(value);
    }

    function _convertWeightTo18Decimals() internal pure returns (uint256) {
        return (uint256(reserveWeight) * 1e18) / 1e6;
    }

    // Market cap PS = R / F, remember.
    function _calculateMarketCapInETH() internal view returns (uint256 marketCapInETH) {
        uint256 weightIn18Decimals = _convertWeightTo18Decimals();
        return (getReserveBalance() / weightIn18Decimals);
    }

    function _calculateMarketCapInUSD() internal view returns (uint256 marketCapInUSD) {
        (uint256 ethUsdPrice, uint256 precision) = pythOracle.getETHPriceInUSD();
        uint256 numerator = _calculateMarketCapInETH() * ethUsdPrice;
        uint256 denominator = 1e18 * (10 ** precision);
        return numerator / denominator;
    }

    function _calculateETHEquivalentForLPHalfUSDValue() internal view returns (uint256 value) {
        (uint256 ethUsdPrice, uint256 precision) = pythOracle.getETHPriceInUSD();
        uint256 usdLpHalfToPrecision = LP_HALF * (10 ** precision);
        uint256 oneETH = 1e18;
        uint256 numerator = oneETH * usdLpHalfToPrecision;
        uint256 denominator = ethUsdPrice * (10 ** precision);
        value = numerator / denominator;
    }

    function _attemptPoolSetup() internal {
        if (_calculateMarketCapInUSD() < BONDING_CURVE_LIMIT) return;

        if (pool == address(0)) {
            _rewardOwnerWith1PercentOfReserve();
            _setupNewPoolWithLiquidity();
        }
    }

    function _setupNewPoolWithLiquidity() internal {
        (uint256 tokenAmountToSend, uint256 ethValueToSend) = _approveBothAssetsAndReturnAmounts();

        uint160 sqrtPriceX96 = _getSqrtPriceX96(tokenAmountToSend, ethValueToSend);

        pool = _createNewPoolIfNecessary(sqrtPriceX96);
        uint128 liquidity = _addLiquidity(tokenAmountToSend, ethValueToSend);
        if (liquidity == 0) revert LiquidityNotAdded();
    }

    function _approveBothAssetsAndReturnAmounts() internal returns (uint256 tokenAmountToSend, uint256 ethValueToSend) {
        ethValueToSend = _calculateETHEquivalentForLPHalfUSDValue();
        tokenAmountToSend = quantityToBuyWithDepositAmount(ethValueToSend);
        
        _mint(address(this), tokenAmountToSend);
        _approve(address(this), pool, tokenAmountToSend);

        _getWETHForETH(ethValueToSend);
        IERC20(WETH).approve(pool, ethValueToSend);
    }

    // https://stackoverflow.com/questions/78182497/how-to-calculate-sqrtpricex96-for-uniswap-pool-creation
    function _getSqrtPriceX96(uint256 bayviewTokenAmount, uint256 wethAmount) internal pure returns (uint160 sqrtPriceX96) {
        uint256 priceSqrd = wethAmount / bayviewTokenAmount;
        uint256 sqrtPrice = Math.sqrt(priceSqrd);
        sqrtPriceX96 = uint160(sqrtPrice * (2 ** 96));
    }

    function _getWETHForETH(uint256 ethValueToSend) internal {
        (bool sent, ) = WETH.call{ value: ethValueToSend }("");
        _validateSending(sent, ethValueToSend);
    }

    function _rewardOwnerWith1PercentOfReserve() internal {
        uint256 onePercentOfReserve = getReserveBalance() / 100;
        (bool sent, ) = owner.call{ value: onePercentOfReserve }("");
        _validateSending(sent, onePercentOfReserve);
    }
}