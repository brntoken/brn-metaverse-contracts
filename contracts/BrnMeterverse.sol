// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './interfaces/IBEP2E.sol';

//TODO - Inherit from ReentrancyGuard
contract BrnMeterverse is Ownable, IBEP2E {
  using SafeMath for uint256;

  string public _name; //token name
  string public _symbol; //token symbol 
  uint private _totalSupply; //total supply
  uint8 public _decimals; //the total number of decimal represenations
  bool private _paused;

  mapping(address => uint) private balances; //how token much does this address have
  mapping(address => mapping(address => uint)) private allowances; //the amount approved by the owner to be spent on their behalf
  event Unpaused(address account); // Emitted when the pause is triggered by `account`.
  event Paused(address account); //Emitted when the pause is lifted by `account`.

  constructor() public {
    _name = "Brn Metaverse";
    _symbol = "BRN";
    _decimals = 18;
    _totalSupply = 1000000000;
    _paused = false;
    balances[msg.sender] = balances[msg.sender].add(_totalSupply);
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
  * @dev Modifier to make a function callable only when the contract is not paused.
  *
  * Requirements:
  *
  * - The contract must not be paused.
  */
  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
     _;
  }

  /**
  * @dev Modifier to make a function callable only when the contract is paused.
  *
  * Requirements:
  *
  * - The contract must be paused.
  */
  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }

  /**
  * @dev Returns true if the contract is paused, and false otherwise.
  */
  function paused() public view returns (bool) {
    return _paused;
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
  * @param _account account the address to which we want to determine their token balance
  * @return uint the total balance of the specied address
  */
  function balanceOf(address _account) public view override returns (uint256){
    return balances[_account];
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
  function transfer(address _recipient, uint _amount) public override whenNotPaused returns (bool){ //nonReentrant
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
  function transferFrom(address _sender, address _recipient, uint _amount) public override whenNotPaused returns (bool) {
    _transfer(_sender, _recipient, _amount);
    uint currentAllowance = allowances[_sender][msg.sender];
    _approve(_sender, msg.sender, currentAllowance.sub(_amount));
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
  function approve(address _spender, uint _amount) public override whenNotPaused returns (bool) {
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
  function increaseAllowance(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
    _approve(msg.sender, _spender, allowances[msg.sender][_spender].add(_addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to spender by the caller
   * @param _spender address 
   * @param _subtractedValue uint
   * @return bool true if success otherwise false
   */
  function decreaseAllowance(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
    uint currentAllowance = allowances[msg.sender][_spender];
    require(currentAllowance >= _subtractedValue,"BEP2E: Insufficient Allowance");
    _approve(msg.sender, _spender, allowances[msg.sender][_spender].sub(_subtractedValue));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   * @param _amount uint 
   * @return bool if success othwerise false
   */
  function mint(uint _amount) public onlyOwner whenNotPaused returns (bool) {
    _mint(msg.sender, _amount);
    return true;
  }

  /**
   * @dev Destroys amount tokens from account, reducing the
   * total supply.
   * @dev account cannot be the zero address.
   * @dev account must have at least amount tokens.
   * @param _account address
   * @param _amount uint
   * @return bool true if success otherwise false
   */
  function burn(address _account, uint _amount) public onlyOwner whenNotPaused returns(bool){
    _burn(_account, _amount);
    return true;
  }

  /**
  * @dev Triggers stopped state.
  *
  * Requirements:
  *
  * - The contract must not be paused.
  */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
  * @dev Returns to normal state.
  *
  * Requirements:
  *
  * - The contract must be paused.
  */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
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
  function _transfer(address _sender, address _recipient, uint _amount) internal virtual {
    require(_sender != address(0), "BEP2E: transfer from the zero address");
    require(_recipient != address(0), "BEP2E: transfer to the zero address");

    _beforeTokenTransfer(_sender, _recipient, _amount);

    uint senderBalance = balances[_sender];

    require(senderBalance >= _amount, "BEP2E: transfer amount exceeds balance");

    balances[_sender] = balances[_sender].sub(_amount);
    balances[_recipient] = balances[_recipient].add(_amount);
    emit Transfer(_sender, _recipient, _amount);
    _afterTokenTransfer(_sender, _recipient, _amount);
  }

  /** @dev Creates amount tokens and assigns them to account, increasing
   * the total supply.
   * @dev to cannot be the zero address.
   * @param _account address 
   * @param _amount uint 
   */
  function _mint(address _account, uint _amount) internal virtual {
    require(_account != address(0), "BEP2E: mint to the zero address");

    _beforeTokenTransfer(address(0), _account, _amount);

    _totalSupply = _totalSupply.add(_amount);
    balances[_account] = balances[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
    _afterTokenTransfer(address(0), _account, _amount);
  }

  /**
   * @dev Destroys amount tokens from account, reducing the
   * total supply.
   * @dev account cannot be the zero address.
   * @dev account must have at least amount tokens.
   * @param _account address
   * @param _amount uint 
   */
  function _burn(address _account, uint _amount) internal virtual {
    require(_account != address(0), "BEP2E: burn from the zero address");

    _beforeTokenTransfer(_account, address(0), _amount);

    uint accountBalance = balances[_account];
    require(accountBalance >= _amount,"BEP2E: burn amount exceeds balance");

    balances[_account] = balances[_account].sub(_amount);
    _totalSupply = _totalSupply.sub(_amount);
    emit Transfer(_account, address(0), _amount);
    _afterTokenTransfer(_account, address(0), _amount);
  }

  /**
   * @dev Sets amount as the allowance of spender over the owner`s tokens.
   * @dev owner cannot be the zero address.
   * @dev spender cannot be the zero address.
   * @param _owner address
   * @param _spender address
   * @param _amount uint  
   */
  function _approve(address _owner, address _spender, uint _amount) internal virtual {
    require(_owner != address(0), "BEP2E: approve from the zero address");
    require(_spender != address(0), "BEP2E: approve to the zero address");

    allowances[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   * @param _account address
   * @param _amount uint 
   */
  function _burnFrom(address _account, uint _amount) internal virtual {
    _burn(_account, _amount);
    _approve(_account, msg.sender, allowances[_account][msg.sender].sub(_amount));
  }

  /**
  * @dev Hook that is called before any transfer of tokens. This includes
  * minting and burning.
  *
  * Calling conditions:
  *
  * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
  * will be transferred to `to`.
  * - when `from` is zero, `amount` tokens will be minted for `to`.
  * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
  * - `from` and `to` are never both zero.
  *
  * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
  */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}


  /**
  * @dev Hook that is called after any transfer of tokens. This includes
  * minting and burning.
  *
  * Calling conditions:
  *
  * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
  * has been transferred to `to`.
  * - when `from` is zero, `amount` tokens have been minted for `to`.
  * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
  * - `from` and `to` are never both zero.
  *
  * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
  */
  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}  
}
