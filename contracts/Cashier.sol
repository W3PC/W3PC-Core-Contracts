// SPDX-License-Identifier: GPL-2.0

pragma solidity ^0.8.10;

import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Token has 0 decimals—the lowest denomination of $CHIP = $1 of stablecoin
contract Cashier is ERC20( "PokerDAO Playing Chips (Beta)", "CHIPS", 0 ), Ownable {  

  // immutable $USDC ERC20 contract address
  ERC20 immutable internal _usdc;

  constructor( ERC20 usdc_ ) {
    _usdc = usdc_;
  }

  // get $CHIPS for $USDC (1:1)
  function getChips( uint256 amtChips_ ) external {

    // mint $CHIP to the players wallet
    _mint( msg.sender, amtChips_ );

    // transfer $USDC from the players wallet to the cashier
    _usdc.transferFrom( msg.sender, address( this ), amtChips_ * ( 10**_usdc.decimals() ) );
  }


  // exchange amount of $CHIP to $USDC
  function exchangeChips( uint256 amtChips_ ) external {

    // burn $CHIP from the players wallet
    _burn( msg.sender, amtChips_ );

    // transfer $USDC to the players wallet from the cashier
    _usdc.transfer( msg.sender, amtChips_ * ( 10**_usdc.decimals() ) );
  }
}


