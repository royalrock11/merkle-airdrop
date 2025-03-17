// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

/// @title MerkleAirdropTest
/// @notice This contract tests the functionality of the MerkleAirdrop contract
contract MerkleAirdropTest is Test {
    BagelToken private token;
    MerkleAirdrop private airdrop;
    bytes32 public ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address public user;
    address public gasPayer;
    uint256 public userPriKey;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proofOne =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];

    /// @notice Sets up the test environment
    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.deployMerkleAirdrop();
        token = new BagelToken();
        airdrop = new MerkleAirdrop(ROOT, token);
        token.mint(token.owner(), AMOUNT_TO_SEND);
        token.transfer(address(airdrop), AMOUNT_TO_SEND);
        (user, userPriKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    /// @notice Tests that users can claim their tokens from the airdrop
    function testUsersCanClaim() public {
        // Arrange
        uint256 startingBalance = token.balanceOf(user);

        // Act
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        // sign a message

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPriKey, digest);

        // gasPayer calls claim using the signed message
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        // Assert
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance", endingBalance);
        assertEq(endingBalance, startingBalance + AMOUNT_TO_CLAIM);
    }
}
