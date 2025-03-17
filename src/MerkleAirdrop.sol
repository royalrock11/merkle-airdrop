// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/*//////////////////////////////////////////////////////////////
                        IMPORTS
//////////////////////////////////////////////////////////////*/

import {IERC20, SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title MerkleAirdrop
 * @author Reggie Prince
 * @author VulcanROI
 * @dev A contract that allows users to claim tokens using a Merkle proof.
 */
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    // Some list of addresses
    // Allow someone in the list to claim a tokens

    /*//////////////////////////////////////////////////////////////
                        ERRORS
    //////////////////////////////////////////////////////////////*/

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    /*//////////////////////////////////////////////////////////////
                        TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /*//////////////////////////////////////////////////////////////
                        EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Emitted when a claim is made.
     * @param account The address of the account making the claim.
     * @param amount The amount of tokens claimed.
     */
    event Claim(address account, uint256 amount);

    /**
     * @dev Constructor that sets the Merkle root and the airdrop token.
     * @param merkleRoot The Merkle root of the airdrop.
     * @param airdropToken The token to be airdropped.
     */
    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /**
     * @dev Allows an account to claim tokens if they provide a valid Merkle proof.
     * @param account The address of the account making the claim.
     * @param amount The amount of tokens to claim.
     * @param merkleProof The Merkle proof to validate the claim.
     */

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL & PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // check the signature
        if (
            !_isValidSignature(
                account,
                getMessageHash(account, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }
        // calculate using the account and amount, the hash -> leaf node
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    /**
     * @dev Returns the Merkle root of the airdrop.
     * @return The Merkle root.
     */
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    /**
     * @dev Returns the airdrop token.
     * @return The airdrop token.
     */
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}
