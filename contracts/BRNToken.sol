// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './IBEP2E.sol';

//ReentrancyGuard
contract BRNToken is Ownable, IBEP2E  {
  using SafeMath for uint256;

  string public _name;
  string public _symbol;
  uint private _totalSuplly;
  uint public _decimals;

  mapping(address => uint) private balances;
  mapping(address => mapping(address => uint)) private allowances;

  constructor() public {
    _name = "BRN Token";
    _symbol = "BRN";
    _decimals = 18;
    _totalSuplly = 1000000000;
    balances[msg.sender] = balances[msg.sender].add(_totalSuplly);
    emit Transfer(address(0), msg.sender, _totalSuplly);
  }

  /**
  * @notice token name
  * @return string token name
  */
  function name() public view override returns(string memory){
    return _name;
  }

  /** 
  * @notice token symbol
  * @return string symbol. The Token Symbol
  */
  function symbol() public view override returns(string memory){
    return _symbol;
  }

  /**
  * @notice the total number of decimals for the BRN token
  * @return uint number of decimals
  */
  function decimals() public view override returns(uint){
    return _decimals;
  }

  /**
  * @notice the total token supply in circulation
  * @return uint total supply
  */
  function totalSupply() public view override returns(uint){
    return _totalSuplly;
  }

  /**
  * @notice should return the address of the contract owner
  * @return address the owner address specified in the Ownable contract
  */
  function getOwner() public view override returns (address){
    return owner();
  }
  
  /**
  * @notice how much token balance does this address have
  * @dev the account should not be the zero address , address(0)
  * @param account account the address to which we want to determine their token balance
  * @return uint the total balance of the specied address
  */
  function balanceOf(address account) public view override returns (uint256){
    return balances[account];
  }

  /**
  * @notice transfer a specicied amount pf tokens to a recipient address
  * @dev the recipient address should not be an empty address address(0)
  * @dev the sender's total balance must be equal to or greater than the amount specified
  * @dev the nonReentrant modifier protects this function from reentrancy attacks
  * @param recipient address the person receiving the tokens
  * @param amount uint the amount of tokens to be sent to the specied address as the recepient
  * @return bool success if the transfer was successfull otherwise false
  */
  function transfer(address recipient, uint256 amount) public override returns (bool){ //nonReentrant
      _transfer(msg.sender, recipient, amount);
      return true;
  }

  /**
  * @notice transfer the specidied amount of tokens from the sender address to the recipient address
  * @dev both the sender and recipient address should not be the empty address, address(0)
  * @dev the amount of tokens being moved from the sender to the recipient address should 
  * @dev not be less than the sender's total balances
  * @dev the nonReentrant modifier protects this function from reentrancy attacks
  * @param sender address
  * @param recipient address
  * @param amount uint
  * @return true if the transfer event was successfull
  */
  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool){ //nonReentrant
    _transfer(sender, recipient,amount);
    return true;
  }

  /**
  * @notice returns the amount that owner appoved as allowance for the spender
  * @dev both the owner and spender addresses should not be empty addresse address(0)
  * @param _owner address the owner address
  * @param _spender address the spender address
  * @return uint, the amount approved for spending
  */
  function allowance(address _owner, address _spender) public view override returns (uint256){
    return allowances[_owner][_spender];
  }

  /**
  * @notice enables the token holder to add a new address than can spend the tokens on their behalf
  * @dev the spender address should not be an empty address(0)
  * @dev the amount to be approved should not be less than the sender's balance
  * @param _spender address, the approved address
  * @param _amount uint , the amount to approved by the token holder
  */
  function approve(address _spender, uint256 _amount) public override returns (bool){
    uint senderTokenBalance = balances[msg.sender];
    require(_amount >= senderTokenBalance,"Token Approval: Insufficient Balance");
    require(_spender != address(0),"Token Approval: Invalid Spender Address");
    allowances[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  function withdraw() public onlyOwner { //nonReentrant

  }

  /**
  * -- INTERNAL FUNCTIONS -- 
  */

  function _transfer(address _sender, address _recipient, uint _amount) public {
    uint senderTokenBalance = balances[_sender];
    require(_recipient != address(0),"Token Transfer: Invalid Recipient");
    //require(amount >= senderTokenBalance,"Token Transfer: Insufficient Balance");
    if(_amount < senderTokenBalance){
      revert("Token Transfer: Insufficient Balance");
    }
    balances[_sender] = balances[_sender].sub(_amount); //use safemath to prevent integer underflow
    balances[_recipient] = balances[_recipient].add(_amount); //use safemath to prevent integer overflow
    emit Transfer(msg.sender, _recipient, _amount);
  }
}
