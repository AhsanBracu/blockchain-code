// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Challenge3 {
    address private _owner;
    string private _github;

    constructor(string memory githubUsername) {
        _owner = msg.sender;         // Your wallet address will be saved
        _github = githubUsername;    // Set your GitHub name
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getGithubId() public view returns (string memory) {
        return _github;
    }
}
