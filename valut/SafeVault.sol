// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SafeVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough");

        balances[msg.sender] -= amount; // checked subtraction
        payable(msg.sender).transfer(amount);
    }
}
