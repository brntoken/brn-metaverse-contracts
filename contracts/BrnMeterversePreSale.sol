// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import 'openzeppelin-solidity/contracts/token/ERC20/utils/TokenTimeLock.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/access/AccessControl.sol';
import 'openzeppelin-solidity/contracts/finance/PaymentSplitter.sol';
import 'openzeppelin-solidity/contracts/finance/VestingWallet.sol';
import 'openzeppelin-solidity/contracts/utils/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/security/Pausable.sol';
import 'openzeppelin-solidity/contracts/security/PullPayment.sol';
import '@openzeppelin/contracts/crowdsale/Crowdsale.sol';
import '@openzeppelin/contracts/crowdsale/validation/WhitelistCrowdsale.sol';
import '@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol';
import '@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol';
import '@openzeppelin/contracts/crowdsale/validation/PausableCrowdsale.sol';
import '@openzeppelin/contracts/crowdsale/distribution/FinalizableCrowdsale.sol';
import '@openzeppelin/contracts/crowdsale/distribution/RefundableCrowdsale.sol';
import './BrnMeterverse.sol';

/**
* @title BrnMeterversePreSale
* @dev A contract that manages the BRN Meterverse Presale logic
*/
contract BrnMeterversePreSale is Ownable, Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, WhitelistedCrowdsale, RefundableCrowdsale{
  using SafeMath for uint256;

  //presale phases
  enum ICOPresalePhase { Phase1, Phase2, Phase3 }

  //set the default ICO phase
  ICOPresalePhase public icoPhase = ICOPresalePhase.Phase1; //initial presale phase

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

  //Token rate based on the ico presale phase
  uint internal icoPhaseRate;
  uint internal icoPhaseAmount;
  uint internal icoPhaseStakingPeriod;

  //track the BRN Meterverse
  BrnMeterverse internal token;

  constructor(
    uint256 _rate,
    address _wallet,
    BrnMeterverse _token,
    uint256 _cap,
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _goal,
    address _partnershipFundAddress,
    address _airdropFundAddress,
    address _marketingFundAddress ,
    address _staffFundAddress,
    address _burnFundAddress,
    address _holdersFundAddress 
  ) 
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    RefundableCrowdsale(_goal) public 
    {
      require(_goal <= _cap);
      token = _token;
      icoPhaseRate = _rate;
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

    if(icoPhase == ICOPresalePhase.Phase1 ){
      uint phase1Rate = 10;
      icoPhaseRate = phase1Rate.div(100); //set pricerate to 0.1 for the first phase of the presale
      icoPhaseAmount = 7000000 * 10 ** 18; //set the token amount to 7000000 for the first phase of the presale
      icoPhaseStakingPeriod = 30 days * 6; //the presale phase will run for 6 months
    }else if(icoPhase == ICOPresalePhase.Phase2 ){
      uint phase2Rate = 20;
      icoPhaseRate = phase2Rate.div(100); //set pricerate to 0.2 for the second phase of the presale
      icoPhaseAmount = 18000000 * 10 ** 18; //set the token amount to 18000000 for the second phase of the presale
      icoPhaseStakingPeriod = 30 days * 4; //the presale phase will run for 4 months
    }else if(icoPhase == ICOPresalePhase.Phase3){
      uint phase3Rate = 30;
      icoPhaseRate = phase3Rate.div(100); //set pricerate to 0.3 for the last phase of the presale
      icoPhaseAmount = 25000000 * 10 ** 18; //set the token amount to 25000000 for the last phase of the presale
      icoPhaseStakingPeriod = 30 days * 2; //the presale phase will run for 2 months
    }
    return true;
  }
}
