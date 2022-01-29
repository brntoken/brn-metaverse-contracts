// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './interfaces/IBEP2E.sol';

//TODO - Inherit from ReentrancyGuard
contract BrnMeterverse is Ownable, IBEP2E  {
  using SafeMath for uint256;

  string public _name; //token name
  string public _symbol; //token symbol 
  uint private _totalSupply; //total supply
  uint public _decimals; //the total number of decimal represenations

  mapping(address => uint) private balances; //how token much does this address have
  mapping(address => mapping(address => uint)) private allowances; //the amount approved by the owner to be spent on their behalf

  constructor() public {
    _name = "Brn Metaverse";
    _symbol = "BRN";
    _decimals = 18;
    _totalSupply = 1000000000;
    balances[msg.sender] = balances[msg.sender].add(_totalSupply);
    emit Transfer(address(0), msg.sender, _totalSupply);
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
    return _totalSupply;
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
  * @param _recipient address the person receiving the tokens
  * @param _amount uint the amount of tokens to be sent to the specied address as the recepient
  * @return bool success if the transfer was successfull otherwise false
  */
  function transfer(address _recipient, uint _amount) public override returns (bool){ //nonReentrant
      _transfer(msg.sender, _recipient, _amount);
      return true;
  }

  /**
  * @notice transfer the specidied amount of tokens from the sender address to the recipient address
  * @dev both the sender and recipient address should not be the empty address, address(0)
  * @dev the amount of tokens being moved from the sender to the recipient address should 
  * @dev not be less than the sender's total balances
  * @dev the nonReentrant modifier protects this function from reentrancy attacks
  * @param _sender address
  * @param _recipient address
  * @param _amount uint
  * @return true if the transfer event was successfull
  */
  function transferFrom(address _sender, address _recipient, uint _amount) public override returns (bool) {
    _transfer(_sender, _recipient, _amount);
    _approve(_sender, _msgSender(), allowances[_sender][msg.sender].sub(_amount, "BEP2E: transfer amount exceeds allowance"));
    return true;
  }

  /**
  * @notice returns the amount that owner appoved as allowance for the spender
  * @dev both the owner and spender addresses should not be empty addresse address(0)
  * @param _owner address the owner address
  * @param _spender address the spender address
  * @return uint, the amount approved for spending
  */
  function allowance(address _owner, address _spender) public override view returns (uint256) {
    return allowances[_owner][_spender];
  }

  /**
  * @notice enables the token holder to add a new address than can spend the tokens on their behalf
  * @dev the spender address should not be an empty address(0)
  * @dev the amount to be approved should not be less than the sender's balance
  * @param _spender address, the approved address
  * @param _amount uint , the amount to approved by the token holder
  * @return bool true if success otherwise false
  */
  function approve(address _spender, uint _amount) public override returns (bool) {
    _approve(msg.sender, _spender, _amount);
    return true;
  }

  function withdraw() public onlyOwner { //nonReentrant

  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   * @param _spender address 
   * @param _addedValue uint 
   * @return bool true if success otherwise false
   */
  function increaseAllowance(address _spender, uint _addedValue) public returns (bool) {
    _approve(msg.sender, _spender, allowances[msg.sender][_spender].add(_addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to spender by the caller
   * @param _spender address 
   * @param _subtractedValue uint
   * @return bool true if success otherwise false
   */
  function decreaseAllowance(address _spender, uint _subtractedValue) public returns (bool) {
    _approve(msg.sender, _spender, allowances[msg.sender][_spender].sub(_subtractedValue, "BEP2E: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   * @param _amount uint 
   * @return bool if success othwerise false
   */
  function mint(uint _amount) public onlyOwner returns (bool) {
    _mint(msg.sender, _amount);
    return true;
  }

  /**
  * -- INTERNAL FUNCTIONS -- 
  */

  /**
   * @dev Moves tokens amount from sender to recipient.
   * @dev _sender cannot be the zero address.
   * @dev recipient cannot be the zero address.
   * @dev sender must have a balance of at least amount
   * @param _sender address thes account sending the tokens amount
   * @param _recipient address the account receiving the tokens
   * @param _amount uint the token amount to be sent
   */
  function _transfer(address _sender, address _recipient, uint _amount) internal {
    require(_sender != address(0), "BEP2E: transfer from the zero address");
    require(_recipient != address(0), "BEP2E: transfer to the zero address");

    balances[_sender] = balances[_sender].sub(_amount, "BEP2E: transfer amount exceeds balance");
    balances[_recipient] = balances[_recipient].add(_amount);
    emit Transfer(_sender, _recipient, _amount);
  }

  /** @dev Creates amount tokens and assigns them to account, increasing
   * the total supply.
   * @dev to cannot be the zero address.
   * @param _account address 
   * @param _amount uint 
   */
  function _mint(address _account, uint _amount) internal {
    require(_account != address(0), "BEP2E: mint to the zero address");

    _totalSupply = _totalSupply.add(_amount);
    balances[_account] = balances[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

  /**
   * @dev Sets amount as the allowance of spender over the owner`s tokens.
   * @dev owner cannot be the zero address.
   * @dev spender cannot be the zero address.
   * @param _owner address
   * @param _spender address
   * @param _amount uint  
   */
  function _approve(address _owner, address _spender, uint _amount) internal {
    require(_owner != address(0), "BEP2E: approve from the zero address");
    require(_spender != address(0), "BEP2E: approve to the zero address");

    allowances[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
  }

  /**
   * @dev Destroys amount tokens from account, reducing the
   * total supply.
   * @dev account cannot be the zero address.
   * @dev account must have at least amount tokens.
   * @param _account address
   * @param _amount uint 
   */
  function _burn(address _account, uint _amount) internal {
    require(_account != address(0), "BEP2E: burn from the zero address");

    balances[_account] = balances[_account].sub(_amount, "BEP2E: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   * @param _account address
   * @param _amount uint 
   */
  function _burnFrom(address _account, uint _amount) internal {
    _burn(_account, _amount);
    _approve(_account, msg.sender, allowances[_account][msg.sender].sub(_amount, "BEP2E: burn amount exceeds allowance"));
  }
}
