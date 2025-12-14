// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract UnsafeVault {
    function deposit() external payable {}

    function withdraw() external {
        // No owner check – anyone can steal funds!
        payable(msg.sender).transfer(address(this).balance);
    }
}
