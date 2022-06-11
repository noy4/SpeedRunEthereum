pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;
  mapping(address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  event Stake(address sender, uint256 amount);

  function stake() public payable notCompleted {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), 'completed');
    _;
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public notCompleted {
    bool hasExpired = block.timestamp >= deadline;
    require(hasExpired, 'Deadline has not expired yet.');
    bool hasEnoughEth = address(this).balance >= threshold;
    if (hasEnoughEth) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public notCompleted returns (bool) {
    require(openForWithdraw, 'Withdraw not allowed.');
    (bool sent, ) = msg.sender.call{value: balances[msg.sender]}('');
    return sent;
  }

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (deadline > block.timestamp) {
      return deadline - block.timestamp;
    }
    return 0;
  }

  // TODO: Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
