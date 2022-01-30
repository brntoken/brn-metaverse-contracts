// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC20/utils/TokenTimeLock.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/finance/PaymentSplitter.sol';
import '@openzeppelin/contracts/finance/VestingWallet.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
* @title BrnMeterversePreSale
* @dev A contract that manages the BRN Meterverse Presale logic
*/
contract BrnMeterversePreSale is Ownable {
  using SafeMath for uint256;

  //presale phases
  enum ICOPresalePhase { Phase1, Phase2, Phase3 }

  //set the default ICO phase
  ICOPresalePhase public icoPhase = ICOPresalePhase.Phase1;


  //Token distributions
  uint public partnershipPercentage = 10;
  uint public airdropPercentage = 13;
  uint public marketingPercentage = 50;
  uint public staffPercentage = 15;
  uint public burnPercentage = 10;
  uint public holdersPercentage = 2;

  //Wallet Addresses
  address internal immutable partnershipFundAddress;
  address internal immutable airdropFundAddress;
  address internal immutable marketingFundAddress;
  address internal immutable staffFundAddress;
  address internal immutable burnFundAddress;
  address internal immutable holdersFundAddress;

  constructor(
    address _partnershipFundAddress,
    address _airdropFundAddress,
    address _marketingFundAddress ,
    address _staffFundAddress,
    address _burnFundAddress,
    address _holdersFundAddress 
  ) public {
    partnershipFundAddress = _partnershipFundAddress;
    airdropFundAddress = _airdropFundAddress;
    marketingFundAddress = _marketingFundAddress;
    staffFundAddress = _staffFundAddress;
    burnFundAddress = _burnFundAddress;
    holdersFundAddress = _holdersFundAddress;
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
