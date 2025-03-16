// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {Script} from "lib/forge-std/src/Script.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @title DeployMerkleAirdrop
/// @author Reggie Prince
/// @author VulcanROI
/// @notice This contract deploys the MerkleAirdrop and BagelToken contracts
contract DeployMerkleAirdrop is Script {
    bytes32 private constant s_merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private constant s_amountToTransfer = 4 * 25 * 1e18;

    /// @notice Deploys the MerkleAirdrop and BagelToken contracts
    /// @return airdrop The deployed MerkleAirdrop contract
    /// @return token The deployed BagelToken contract
    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(
            s_merkleRoot,
            IERC20(address(token))
        );
        token.mint(token.owner(), s_amountToTransfer);

        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    /// @notice Runs the deployment script
    /// @return airdrop The deployed MerkleAirdrop contract
    /// @return token The deployed BagelToken contract
    function run() external returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
