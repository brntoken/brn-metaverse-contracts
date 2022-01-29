// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC20/utils/TokenTimeLock.sol';

/**
* @title BrnMeterversePreSale
* @dev A contract that manages the BRN Meterverse Presale logic
*/
contract BrnMeterversePreSale {

  //presale phases
  enum ICOPresalePhase { Phase1, Phase2, Phase3}

  //set the default ICO phase
  ICOPresalePhase public icoPhase = ICOPresalePhase.Phase1;

  constructor() public {
  }
}
