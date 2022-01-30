// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';

interface UniswapV3Factory{
    function createPool(address tokenA,address tokenB,uint24 fee) external returns (address pool);
    function setOwner(address _owner) external;
    function enableFeeAmount(uint24 fee,int24 tickSpacing) external;
    function owner() external view returns(address);
    function getPool(address tokenA,address tokenB,uint24 fee) external view returns (address pool);
}

/**
* @title  BrnMeterverseUniswapV3Integration
* @notice Handles all the Uniswap integration functions for the BRN token  
*/
contract BrnMeterverseUniswapV3Integration is Ownable { 

    address public immutable brnTokenAddress;  //update to BRN address once it is deployed
    address public immutable bnbTokenAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB Wrapped BNB
    address public immutable uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    constructor(address _brnTokenAddress) public {
        brnTokenAddress = _brnTokenAddress;
    }

    /**
    * @notice creates a new BRN/BNB pool
    * @param _fee uint the pool fee
    * @return pool addres of the newly created pool on the Uniswap protocol
    */
    function createPool(uint _fee) public onlyOwner returns(address pool){
        return UniswapV3Factory(uniswapV3Factory).createPool(brnTokenAddress,bnbTokenAddress, uint24(_fee));
    }

    /**
    * @notice sets the new pool owner. Callable only the deployer addresse
    * @param _newOwner address the new owner address 
    */
    function setPoolOwner(address _newOwner) public onlyOwner{
        return UniswapV3Factory(uniswapV3Factory).setOwner(_newOwner);
    }

    /**
    * @notice Enables a fee amount with the given tickSpacing
    * @param _fee uint The fee amount to enable
    * @param _tickSpacing int The spacing between ticks to be enforced for all pools created with the given fee amount
    */
    function enableFeeAmount(uint _fee,int _tickSpacing) public onlyOwner{
        return UniswapV3Factory(uniswapV3Factory).enableFeeAmount(uint24(_fee), int24(_tickSpacing));
    }

    /**
    * @notice Returns the current owner of the factory
    * @dev Can be changed by the current owner via setOwner
    * @return The address of the factory owner
    */
    function getOwner() public view returns(address){
        return UniswapV3Factory(uniswapV3Factory).owner();
    }

    /** 
    * @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    * @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    * @param _fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    * @return pool The pool address
    */

    function getPoolAddress(uint24 _fee) external view returns(address pool){
        return UniswapV3Factory(uniswapV3Factory).getPool(brnTokenAddress,bnbTokenAddress,_fee);
    }
}