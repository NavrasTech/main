// SPDX-License-Identifier: UNLICENSED
// Copyright (C) 2024 NAVRAS Tech

pragma solidity ^0.8.28;

import { ERC20PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { SafeMathUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/// @title WNAVRAS
contract WNAVRAS is Initializable, ERC20PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    IERC20Upgradeable public navrasToken;

    event Wrapped(address indexed user, uint256 amount);
    event Unwrapped(address indexed user, uint256 amount);
    event NavrasTokenAddressUpdated(address newTokenAddress);

    function initialize(address _navrasTokenAddress) public initializer {
        require(_navrasTokenAddress != address(0), "Invalid NAVRAS token address");
        navrasToken = IERC20Upgradeable(_navrasTokenAddress);
        __ERC20Pausable_init();
        __ReentrancyGuard_init();
        __ERC20_init("Wrapped NAVRAS", "wNAVRAS");
    }

    function wrap(uint256 _amount) external nonReentrant whenNotPaused {
        require(_amount > 0, "Amount must be greater than zero");
        navrasToken.safeTransferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, _amount);
        emit Wrapped(msg.sender, _amount);
    }

    function unwrap(uint256 _amount) external nonReentrant whenNotPaused {
        require(_amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        _burn(msg.sender, _amount);
        navrasToken.safeTransfer(msg.sender, _amount);
        emit Unwrapped(msg.sender, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function updateNavrasTokenAddress(address _newTokenAddress) external onlyOwner {
        require(_newTokenAddress != address(0), "Invalid NAVRAS token address");
        navrasToken = IERC20Upgradeable(_newTokenAddress);
        emit NavrasTokenAddressUpdated(_newTokenAddress);
    }
}
