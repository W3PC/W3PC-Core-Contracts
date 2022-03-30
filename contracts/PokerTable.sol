// SPDX-License-Identifier: GPL-2.0

pragma solidity ^0.8.10;

import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PokerTable is Ownable {  

  /////////////////////////////////////////////////////////////////////////////////
  //                             CONTRACT VARIABLES                              //
  /////////////////////////////////////////////////////////////////////////////////


  ERC20 public immutable pokerDaoChips;

  constructor(ERC20 chipToken_) {
    pokerDaoChips = chipToken_;
  }


  /////////////////////////////////////////////////////////////////////////////////
  //                                USER INTERFACE                               //
  /////////////////////////////////////////////////////////////////////////////////


  function sitIn(uint256 amount_) external {
    pokerDaoChips.transferFrom(msg.sender, address(this), amount_);
  }

  function leaveTable(address player_, uint256 amount_) external onlyOwner {
    pokerDaoChips.transfer(player_, amount_);
  }
}