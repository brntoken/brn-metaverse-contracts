// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';

/**
* @notice Interacts with pancakeswap to create a new liquidity pool pair for BRN/WBNB
*/
interface PancakeSwapV2Factory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

/**
* @notice Interacts with pancakeswap to create a new liquidity pool for the BRN/WBNB pair created
*/
interface PancakeSwapV2Router{
    function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}
/**
* @title  BrnMeterverseUniswapV3Integration
* @notice Handles all the PancakeSwap integration functions for the BRN token on PancakeSwap DEX
*/
contract BrnPancakeSwapV2Integration is Ownable { 

    address public immutable brnTokenAddress;  //update to BRN address once it is deployed
    address public immutable bnbTokenAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB (Wrapped BNB)
    address public immutable pancakeSwapV2Factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public immutable pancakeSwapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    mapping(address => bool) public brnBnbPairExists;

    constructor(address _brnTokenAddress) public {
        brnTokenAddress = _brnTokenAddress;
    }

    /**
    * @notice creates a new liquidoty pair for WBNB and BRN
    * @dev only callable by the contract owner
    * @dev if the pair exists already, reverts with error message
    * @return success if pair was created 
    */
    function addBrnBnbPoolPair() public onlyOwner returns(bool success){
        address existingPair = PancakeSwapV2Factory(pancakeSwapV2Factory).getPair(brnTokenAddress, bnbTokenAddress);
        require(brnBnbPairExists[existingPair] == false,"BRN Meterverse PancakeSwap: Pool Pair Already Exists");
        address newPair = PancakeSwapV2Factory(pancakeSwapV2Factory).createPair(brnTokenAddress,bnbTokenAddress);
        brnBnbPairExists[newPair] = true;
        return true;
    }

    /**
    * @notice Adds liquidity to a BRN⇄WBNB pool.
    * @param _amountTokenDesired uint The amount of the BRN tokens you'd to provide as liquidity
    * @param _amountTokenMin uint The minimum amount of the BRN to provide (slippage impact).
    * @param _amountETHMin uint The minimum amount of BNB to provide (slippage impact).
    * @param _deadline uint Unix timestamp deadline by which the transaction must confirm.
    **/
    function addBrnBnbLiquidity(
        uint _amountTokenDesired, 
        uint _amountTokenMin, 
        uint _amountETHMin,
        uint _deadline) 
        public payable onlyOwner returns (uint amountToken, uint amountETH, uint liquidity){
            return PancakeSwapV2Router(pancakeSwapV2Router).addLiquidityETH(
                brnTokenAddress, 
                _amountTokenDesired, 
                _amountTokenMin, 
                _amountETHMin,
                payable(msg.sender), //Address of Liquidity Pool Token recipient
                _deadline);
    }
}