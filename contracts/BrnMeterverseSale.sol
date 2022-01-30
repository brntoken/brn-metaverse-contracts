// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC20/utils/TokenTimeLock.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';

/**
* @title BrnMeterversePreSale
* @dev A contract that manages the BRN Meterverse Presale logic
*/
contract BrnMeterversePreSale is Ownable, AccessControl {

  //presale phases
  enum ICOPresalePhase { Phase1, Phase2, Phase3 }

  //set the default ICO phase
  ICOPresalePhase public icoPhase = ICOPresalePhase.Phase1;

  constructor() public {
  }

  /**
  * @notice enables the contract owner to set the ICO presale phase for the contract
  * @param _phase uint
  * @return success 
  */
  function setPreSalePhase(uint _phase) public onlyOwner returns(bool success){
    if(uint(ICOPresalePhase.Phase1) == _phase){
      icoPhase = ICOPresalePhase.Phase1;
    }else if(uint(ICOPresalePhase.Phase2) == _phase){
      icoPhase = ICOPresalePhase.Phase2;
    }else if(uint(ICOPresalePhase.Phase3) == _phase){
      icoPhase = ICOPresalePhase.Phase3;
    }
    return true;
  }
}
