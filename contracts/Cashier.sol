// SPDX-License-Identifier: GPL-2.0

pragma solidity ^0.8.10;

import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Token has 0 decimals—the lowest denomination of $CHIP = $1 of stablecoin
contract Cashier is ERC20("PokerDAO Playing Chips", "CHIPS", 0), Ownable {  

  /////////////////////////////////////////////////////////////////////////////////
  //                             CONTRACT VARIABLES                              //
  /////////////////////////////////////////////////////////////////////////////////


  mapping(address => bool) public ACCEPTED_STABLECOINS;


  /////////////////////////////////////////////////////////////////////////////////
  //                              SYSTEM GOVERNANCE                              //
  /////////////////////////////////////////////////////////////////////////////////


  function approveStablecoin(ERC20 token_) external onlyOwner {
    ACCEPTED_STABLECOINS[address(token_)] = true;
  }

  function refuseStablecoin(ERC20 token_) external onlyOwner {
    ACCEPTED_STABLECOINS[address(token_)] = false;
  }


  /////////////////////////////////////////////////////////////////////////////////
  //                              USER INTERFACE                                 //
  /////////////////////////////////////////////////////////////////////////////////
  

  // ENTER AMOUNT IN DOLLARS: DO NOT INCLUDE DECIMALS (Base unit = $1)
  function buyChips(ERC20 token_, uint256 amount_) external {
    require(ACCEPTED_STABLECOINS[address(token_)] == true, "token not accepted by cashier");
    token_.transferFrom(msg.sender, address(this), amount_ * (10**token_.decimals()));
    _mint(msg.sender, amount_);
  }

  // ENTER AMOUNT IN DOLLARS: DO NOT INCLUDE DECIMALS (Base unit = $1)
  function cashOut(ERC20 token_, uint256 amount_) external {
    require(ACCEPTED_STABLECOINS[address(token_)] == true, "token not accepted by cashier");
    token_.transfer(msg.sender, amount_ * (10**token_.decimals()));
    _burn(msg.sender, amount_);
  }
}


