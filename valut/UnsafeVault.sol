// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract UnsafeVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
    }

    function withdraw(uint256 amount) external {
        // dev removed check to save gas
        unchecked {
            balances[msg.sender] -= amount; 
        }

        // if attacker underflows, they get huge balance → withdraw everything
        payable(msg.sender).transfer(amount);
    }
}
