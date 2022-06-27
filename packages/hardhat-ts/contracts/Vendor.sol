pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amount = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amount);
    emit BuyTokens(msg.sender, msg.value, amount);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner returns (bool) {
    (bool sent, ) = msg.sender.call{value: address(this).balance}('');
    return sent;
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokenAmount) public returns (bool) {
    yourToken.transferFrom(msg.sender, address(this), tokenAmount);
    uint256 ethAmount = tokenAmount / tokensPerEth;
    (bool sent, ) = msg.sender.call{value: ethAmount}('');
    return sent;
  }
}
