// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract UnsafeBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // ❌ VULNERABLE
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // Sends ETH BEFORE updating storage (danger)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH send failed");

        // Update happens too late!
        balances[msg.sender] = 0;
    }
}
