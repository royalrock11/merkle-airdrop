// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proofOne =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofOne, proofTwo];
    bytes32 private SIGNATURE = hex"";

    error ClaimAirdrop__InvalidSignatureLength();

    constructor(
        address claimingAddress,
        uint256 claimingAmount,
        bytes32[] memory _proof,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) {
        CLAIMING_ADDRESS = claimingAddress;
        CLAIMING_AMOUNT = claimingAmount;
        proof = _proof;
        v = _v;
        r = _r;
        s = _s;
    }

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(
            CLAIMING_ADDRESS,
            CLAIMING_AMOUNT,
            proof,
            v,
            r,
            s
        );

        vm.stopBroadcast();
    }

    function splitSignature(
        bytes32 memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert __ClaimAirdropScript__InvalidSignatureLength();
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        address mostRecentlyDeployedContract = DevOpsTools
            .get_most_recently_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
