//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BrnMetaverse.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title TokenPresale
 * TokenPresale allows investors to make
 * token purchases and assigns them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */

contract Presale is Pausable, Ownable {
    /**
     * crowdsale constructor
     * @param _wallet who receives invested ether
     * @param _cap above which the crowdsale is closed
     */

    constructor(
        address _priceFeedAddress,
        address _tokenAddress,
        address payable _wallet,
        uint256 _cap // 50,000,000 BRN
    ) {
        require(_wallet != address(0));
        require(_tokenAddress != address(0));
        require(_priceFeedAddress != address(0));
        require(_cap > 0);
        TokenAddress = _tokenAddress;
        priceFeedAddress = _priceFeedAddress;

        wallet = _wallet;
        cap = _cap * (10**18); //cap in tokens base units (=1000000 tokens)
        phase1Cap = (cap * 14) / 100;
        phase2Cap = (cap * 36) / 100;
        phase3Cap = (cap * 50) / 100;

        phase1Start = block.timestamp;
        phase2Start = phase1Start + 24 weeks;
        phase3Start = phase2Start + 16 weeks;
        presaleEnd = phase3Start + 8 weeks;
    }

    // Mapping of whitelisted users.
    mapping(address => bool) public whitelist;

    mapping(address => uint256) public phase1Balance;
    mapping(address => uint256) public phase2Balance;
    mapping(address => uint256) public phase3Balance;

    mapping(address => uint256) public Contribution;

    address priceFeedAddress;

    uint256 immutable public phase1Start;
    uint256 immutable public phase2Start;
    uint256 immutable public phase3Start;
    uint256 immutable public presaleEnd;

    // The token being sold
    address immutable TokenAddress;

    // address where funds are collected
    address public wallet;

    //amount of wei raised
    uint256 public weiRaised;

    // amount of tokens sold in each phase
    uint256 public tokenSoldPhase1;
    uint256 public tokenSoldPhase2;
    uint256 public tokenSoldPhase3;

    // cap above which the crowdsale is ended
    uint256 public cap;
    uint256 public phase1Cap;
    uint256 public phase2Cap;
    uint256 public phase3Cap;

    string public contactInformation;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    event TokenWithdrawal(address indexed beneficiary, uint256 amount);

    /**
     * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
     */
    modifier isWhitelisted(address _beneficiary) {
        require(whitelist[_beneficiary]);
        _;
    }

    /**
     * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
     * @param _beneficiaries Addresses to be added to the whitelist
     */
    function addManyToWhitelist(address[] memory _beneficiaries)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    /**
     * @dev Adds single address to whitelist.
     * @param _beneficiary Address to be added to the whitelist
     */
    function addToWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = true;
    }

    /**
     * @dev Removes single address from whitelist.
     * @param _beneficiary Address to be removed to the whitelist
     */
    function removeFromWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = false;
    }

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen() {
        // solium-disable-next-line security/no-block-members
        require(
            block.timestamp >= phase1Start && block.timestamp <= presaleEnd
        );
        _;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function phase1HasClosed() public view returns (bool) {
        return block.timestamp > phase2Start;
    }
    function phase2HasClosed() public view returns (bool) {
        return block.timestamp > phase2Start;
    }
    function presaleHasClosed() public view returns (bool) {
        return block.timestamp > presaleEnd;
    }

    function getPrice() public view returns (uint256, uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
    }

    function coinToUSD(uint256 _amountIn) public view returns (uint256) {
        (uint256 inputTokenPrice, uint256 inputTokenDecimals) = getPrice();
        uint256 value2USD = (_amountIn * inputTokenPrice) /
            10**inputTokenDecimals;
        return value2USD;
    }

    // fallback function to buy tokens
    receive() external payable {
        buyTokens(msg.sender);
    }

    function getPhaseArg() public view returns(uint256, uint256, uint256) {
        uint256 phaseCap;
        uint256 tokensSold;
        uint256 pricePerToken;
        if (block.timestamp > phase1Start && block.timestamp < phase2Start) {
            phaseCap = phase1Cap;
            tokensSold = tokenSoldPhase1;
            pricePerToken = 10 * 10**18;
        }
        if (block.timestamp > phase2Start && block.timestamp < phase3Start) {
            phaseCap = phase2Cap;
            tokensSold = tokenSoldPhase2;
            pricePerToken = 20 * 10**18;
        }
        if (block.timestamp > phase3Start && block.timestamp < presaleEnd) {
            phaseCap = phase3Cap;
            tokensSold = tokenSoldPhase3;
            pricePerToken = 30 * 10**18;
        }
        return (phaseCap, tokensSold, pricePerToken);
    }

    /**
     * Low level token purchse function
     * @param beneficiary will recieve the tokens.
     */
    function buyTokens(address beneficiary)
        public
        payable
        whenNotPaused
        onlyWhileOpen
    {
        require(!presaleHasClosed(), "The presale is over");
        require(beneficiary != address(0));
        require(msg.value > 0);

        uint256 amount = coinToUSD(msg.value);

        require(amount >= 10 * 10**18, "The enter amount is below minimum");
        require(amount <= 10000 * 10**18, "The enter amount is above maximum");

        (uint256 phaseCap, uint256 tokensSold, uint256 pricePerToken ) = getPhaseArg();

        uint256 tokenAmount = (amount * 100 * 10**18) / pricePerToken;
        require(tokenAmount + tokensSold <= phaseCap, "Greater than phase cap");

        if (block.timestamp > phase1Start && block.timestamp < phase2Start) {
            phase1Balance[beneficiary] += tokenAmount;
            Contribution[beneficiary] += msg.value;
            tokenSoldPhase1 += tokenAmount;
        }
        if (block.timestamp > phase2Start && block.timestamp < phase3Start) {
            phase2Balance[beneficiary] += tokenAmount;
            Contribution[beneficiary] += msg.value;
            tokenSoldPhase2 += tokenAmount;
        }
        if (block.timestamp > phase3Start && block.timestamp < presaleEnd) {
            phase3Balance[beneficiary] += tokenAmount;
            Contribution[beneficiary] += msg.value;
            tokenSoldPhase3 += tokenAmount;
        }

        uint256 weiAmount = msg.value;
        // update weiRaised
        weiRaised = weiRaised + weiAmount;

        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
        forwardFunds();
    }

    // withdraw ERC20 Tokens
    function withdrawToken() public whenNotPaused isWhitelisted(msg.sender) {
        require(presaleHasClosed() || phase1HasClosed() || phase2HasClosed(), "All presale phases are still on is still on");
        uint256 balance;
        if (presaleHasClosed()) {
            balance = phase1Balance[msg.sender] + phase2Balance[msg.sender] + phase3Balance[msg.sender];
            phase1Balance[msg.sender] = 0;
            phase2Balance[msg.sender] = 0;
            phase3Balance[msg.sender] = 0;
        } else if (phase2HasClosed()) {
            balance = phase1Balance[msg.sender] + phase2Balance[msg.sender];
            phase1Balance[msg.sender] = 0;
            phase2Balance[msg.sender] = 0;
        } else if (phase1HasClosed()) {
            balance = phase1Balance[msg.sender];
            phase1Balance[msg.sender] = 0;
        }
        IERC20(TokenAddress).transfer(msg.sender, balance);
        emit TokenWithdrawal(msg.sender, balance);
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        payable(wallet).transfer(msg.value);
    }

    function setContactInformation(string memory info) public onlyOwner {
        contactInformation = info;
    }
}
