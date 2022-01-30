// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';

interface UniswapV3Factory{
    function createPool(address tokenA,address tokenB,uint24 fee) external returns (address pool);
    function setOwner(address _owner) external;
    function enableFeeAmount(uint24 fee,int24 tickSpacing) external;
}

/**
* @title  BrnMeterverseUniswapV3Integration
* @notice Handles all the Uniswap integration functions for the BRN token  
*/
contract BrnMeterverseUniswapV3Integration is Ownable { 

    address public constant BRN = address(0); //update to BRN address once it is deployed
    address public constant BNB = address(0);
    address public immutable uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    constructor() public {}

    /**
    * @notice creates a new BRN/BNB pool
    * @param _fee uint the pool fee
    * @return pool addres of the newly created pool on the Uniswap protocol
    */
    function createPool(uint _fee) public onlyOwner returns(address pool){
        return UniswapV3Factory(uniswapV3Factory).createPool(BRN,BNB, uint24(_fee));
    }

    /**
    * @notice sets the new pool owner. Callable only the deployer addresse
    * @param _newOwner address the new owner address 
    */
    function setPoolOwner(address _newOwner) public onlyOwner{
        return UniswapV3Factory(uniswapV3Factory).setOwner(_newOwner);
    }

    function enableFeeAmount(uint _fee,int _tickSpacing) public onlyOwner{
        return UniswapV3Factory(uniswapV3Factory).enableFeeAmount(uint24(_fee), int24(_tickSpacing));
    }
}