// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ContractCall {
    function callContract(address forthCon) public {

// their smart contradct to be called: 0x3819c7071f2bc39c83187bf5b5aea79fa3e37c42
// 1st trans: 0xdd12d9a41737f282a85effea3c690b922059adf4f82f5f2313759d37b63cb8be
// 2nd trans: 0xf555edb0d04b871d65d596f20140c60c96b2cddb086856860aa6d993bc282cf3
// 3rd trans: 0xCFa6a97b08617CF2d9FDeF97a5996B26559AFff5

        address source = 0x3819C7071f2bc39C83187Bf5B5aeA79Fa3e37C42;
        bytes32 firstCon = 0xed635599d6339bb5ea1c664696bb1443c091e2fe007b484c0ee150bf8bfb9af4;
        bytes32 secondCon = 0x407296fc4d9194ec6a1ab208a267330913f21a85a25b2508361663bd2d253627;
        address thirdCon = 0x22C4187b3c9dCDB1910bb2653fFBDAD8a410D6A6;
        (bool ok, bytes memory result) = source.call(
            abi.encodeWithSignature("registerData(bytes32,bytes32,address,address)", firstCon, secondCon, thirdCon, forthCon)
        );

        if (!ok) {
            // Bubble up revert reason if present
            assembly {
                revert(add(result, 32), mload(result))
            }
        }

        // return abi.decode(result, (uint256));
    }
}