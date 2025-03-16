// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title BagelToken
/// @author Reggie Prince
/// @author VulcanROI
/// @notice This contract implements an ERC20 token named Bagel with symbol BGL.
/// @dev Inherits ERC20 and Ownable from OpenZeppelin.
contract BagelToken is ERC20, Ownable {
    /// @notice Constructor that initializes the ERC20 token with name and symbol.
    /// @dev Sets the deployer as the initial owner.
    constructor() ERC20("Bagel", "BGL") Ownable(msg.sender) {}

    /// @notice Mints new tokens.
    /// @dev Only the owner can call this function.
    /// @param to The address to receive the minted tokens.
    /// @param amount The amount of tokens to mint.
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
