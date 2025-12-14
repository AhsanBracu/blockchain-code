// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SafeVault {
    address public owner;

    constructor() {
        owner = msg.sender; // deployer is owner
    }

    function deposit() external payable {}

    function withdraw() external {
        require(msg.sender == owner, "Not authorized");
        payable(msg.sender).transfer(address(this).balance);
    }
}
