// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SafeBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // 🟢 SAFE WITHDRAW
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // Update FIRST (safe)
        balances[msg.sender] = 0;

        // Safe send
        payable(msg.sender).transfer(amount);
    }
}
