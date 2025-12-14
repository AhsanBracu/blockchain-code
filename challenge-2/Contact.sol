// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Caller {
address public targetContract = 0xe621aBEa69C75dA07C3850eeA3965DE0599d4B3D;
 event Called(bytes data);

 fallback() external payable {
        emit Called(msg.data); // record what was sent
    }

    receive() external payable {
    emit Called("Received ETH");
}
    
    function callSelector42() public returns (bool success, bytes memory data) {
        (success, data) = targetContract.call(hex"42424242");
    }
        function call4242() external returns (bool ok, bytes memory ret) {
        (ok, ret) = targetContract.call(hex"42424242");
        require(ok, "call failed");
    }

    function callSelectorWithParams(bytes memory params) public returns (bool success, bytes memory data) {
        bytes memory callData = abi.encodePacked(hex"42424242", params);
        (success, data) = targetContract.call(callData);
    }
    
    
}