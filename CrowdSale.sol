pragma solidity ^0.4.21;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;
  event OwnershipTransferred (address indexed _from, address indexed _to);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public{
    owner = msg.sender;
    emit OwnershipTransferred(address(0), owner);
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
    emit OwnershipTransferred(owner,newOwner);
  }
}

/**
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */
interface Token {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) constant external returns (uint256 balance);
}

contract RetnCrowdSale is Ownable {

  using SafeMath for uint256;

  Token token;

  uint256 internal RATE = 626; 
  uint256 public raisedAmount = 0;
  uint256 public allowedEth = 200 finney;

  event BoughtTokens(address indexed purchaser, uint256 value, uint256 tokens);
  function RetnCrowdSale() public {
      address _tokenAddr = 0x2ADd07C4d319a1211Ed6362D8D0fBE5EF56b65F6; 
      // test token 0x815CfC2701C1d072F2fb7E8bDBe692dEEefFfe41;
      token = Token(_tokenAddr);
  }
  
  function setDiscount(uint256 _rate, uint256 _allowedEth) external onlyOwner {
    if(_rate > 0)
      RATE = _rate;
    if(_allowedEth > 0)  
      allowedEth = _allowedEth * 1 finney;
  }
  
  function tokensAvailable() external constant returns (uint256) {
      return token.balanceOf(this) ;
  }

  function () external payable {
    buyTokens();
  }

  /**
  * @dev function that sells available tokens
  */
  function buyTokens() public payable {
    require(msg.value >= allowedEth);
    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(RATE);
    require(tokens < token.balanceOf(this));  

    if(token.transfer(msg.sender, tokens))
    {
        emit BoughtTokens(msg.sender, weiAmount, tokens);
        raisedAmount = raisedAmount.add(weiAmount);
        owner.transfer(weiAmount);
    }
    
  }

   /**
   * @notice Terminate contract and refund to owner
   */
  function withdraw() onlyOwner external {
    address myAddress = this;
    if(myAddress.balance > 0)
        owner.transfer(myAddress.balance);
    uint256 tokBalance = token.balanceOf(this);
    tokBalance = tokBalance - (1 wei);
    if(tokBalance > 0)
        token.transfer(owner, tokBalance);
  }
}
