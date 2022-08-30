//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract ReceiveBrick {

    event FundsReceived(address indexed sender, uint256 amount, uint256 balance);
   
    receive() external payable {
       emit FundsReceived(msg.sender, msg.value, address(this).balance);
    }
}