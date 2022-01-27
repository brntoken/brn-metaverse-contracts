// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './interfaces/IBEP2E.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract BRNToken is Ownable, IBEP2E {
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
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value)

  function name() public view returns(string){
    return _name;
  }

  function symbol() public view returns(string){
    return _symbol;
  }

  function decimals() pulic view returns(uint){
    return _decimals;
  }

  function totalSupply() public view returns(uint){
    return _totalSuplly;
  }

  function getOwner() public view returns (address){
    return owner();
  }

  function balanceOf(address account) public view returns (uint256){

  }

  function transfer(address recipient, uint256 amount) public returns (bool){

  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool){

  }

  function allowance(address _owner, address spender) public view returns (uint256){

  }

  function approve(address spender, uint256 amount) public returns (bool){

  }

}
