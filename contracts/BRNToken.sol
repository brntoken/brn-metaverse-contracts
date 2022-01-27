// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './interfaces/IBEP2E.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract BRNToken is Ownable, IBEP2E, ReentrancyGuard  {
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
    _totalSuplly = 1000000000 * 10 ** _decimals;
    balances[msg.sender] = balances[msg.sender].add(_totalSuplly);
    emit Transfer(address(0), msg.sender, _totalSuplly);
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value)

  /**
  * @notice token name
  * @return string token name
  */
  function name() public view returns(string){
    return _name;
  }

  /** 
  * @notice token symbol
  * @return string symbol. The Token Symbol
  */
  function symbol() public view returns(string){
    return _symbol;
  }

  /**
  * @notice the total number of decimals for the BRN token
  * @return uint number of decimals
  */
  function decimals() pulic view returns(uint){
    return _decimals;
  }

  /**
  * @notice the total token supply in circulation
  * @return uint total supply
  */
  function totalSupply() public view returns(uint){
    return _totalSuplly;
  }

  /**
  * @notice should return the address of the contract owner
  * @return address the owner address specified in the Ownable contract
  */
  function getOwner() public view returns (address){
    return owner();
  }
  
  /**
  * @notice how much token balance does this address have
  * @dev the account should not be the zero address , address(0)
  * @param address account the address to which we want to determine their token balance
  * @return uint the total balance of the specied address
  */
  function balanceOf(address account) public view returns (uint256){
    return balances[account];
  }

  /**
  * @notice transfer a specicied amount pf tokens to a recipient address
  * @dev the recipient address should not be an empty address address(0)
  * @dev the sender's total balance must be equal to or greater than the amount specified
  * @param address recipient the person receiving the tokens
  * @param uint amount the amount of tokens to be sent to the specied address as the recepient
  * @return bool success if the transfer was successfull otherwise false
  */
  function transfer(address recipient, uint256 amount) public nonReentrant returns (bool){
    uint senderTokenBalance = balances[msg.sender];
    require(recipient != address(0),"Token Transfer: Invalid Recipient");
    require(amount >= senderTokenBalance,"Token Transfer: Insufficient Balance");
    balances[msg.sender] = balances[msg.sender].sub(amount); //use safemath to prevent integer underflow
    balances[recipient] = balances[recipient].add(amount); //use safemath to prevent integer overflow
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  /**
  * @notice transfer the specidied amount of tokens from the sender address to the recipient address
  * @dev both the sender and recipient address should not be the empty address, address(0)
  * @dev the amount of tokens being moved from the sender to the recipient address should 
  * @dev not be less than the sender's total balances
  * @dev the nonReentrant protects this function from reentrancy attacks
  * @return true if the transfer event was successfull
  */
  function transferFrom(address sender, address recipient, uint256 amount) public nonReentrant returns (bool){

  }

  /**
  * 
  */
  function allowance(address _owner, address spender) public view returns (uint256){

  }

  function approve(address spender, uint256 amount) public returns (bool){

  }

  function withdraw() public nonReentrant onlyOwner{

  }

}
