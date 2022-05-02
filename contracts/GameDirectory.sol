// SPDX-License-Identifier: GPL-2.0

pragma solidity ^0.8.10;

import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract GameDirectory {
  
  // directory of user wallets => owned game contracts
  mapping ( address => address ) public hostedGames;

  // ERC20 contract address for $CHIP tokens to be used in games
  ERC20 public immutable chips;

  // error for when host address is already hosting a game
  error AlreadyHostingAGame();


  constructor( ERC20 chips_ ) {

    // set chips in the constructor. This cannot be changed once launched
    chips = chips_;
  }


  // create and assign a Game contract to a host address if one doesn't exist
  function createGame() external {

    // if the host address is already hosting a game, throw an error
    if ( hostedGames[msg.sender] != address(0) ) { revert AlreadyHostingAGame(); }

    // create a game and save the game address to the host addres
    hostedGames[ msg.sender ] = address( new Game( msg.sender, chips ) );
  }
}  


contract Game is Ownable {  

  /////////////////////////////////////////////////////////////////////////////////
  //                             CONTRACT VARIABLES                              //
  /////////////////////////////////////////////////////////////////////////////////


  // internal credits for each player in the game
  mapping(address => uint256) public gameCredits;

  // total internal credits assigned in the game
  uint256 public totalGameCredits;

  // ERC20 token contract for the $CHIP tokens used in the game
  ERC20 public immutable pokerDaoChips;

  // error for when the internal credits don't match the contract's $CHIP balance
  error NotEnoughCredits();


  constructor(address host_, ERC20 pokerDaoChips_) {

    // set the ERC20 token contract
    pokerDaoChips = pokerDaoChips_;
    
    // Ownable.sol: transfer ownership of the contract to the host
    transferOwnership(host_);
  }


  /////////////////////////////////////////////////////////////////////////////////
  //                                USER INTERFACE                               //
  /////////////////////////////////////////////////////////////////////////////////


  // player adding credits in the game
  function addChips(uint256 amount_) external {

    // increase the game credits for the player by the amount they buy in for
    gameCredits[msg.sender] += amount_;

    // increase the total game credits in the game by the amount the player buys in for
    totalGameCredits += amount_;

    // transfer the $CHIP token from the user's wallet to the game contract by the buy in amount
    pokerDaoChips.transferFrom(msg.sender, address(this), amount_);
  }


  // HOST ONLY: trading internal credits in game for $CHIP (cashing out)
  function returnChips(address player_, uint256 amount_) external onlyOwner {

    // if the amount of chips returned to the player exceeds their internal credit balance, throw an error
    if ( amount_ > gameCredits[player_] )  { revert NotEnoughCredits(); }
    
    // decrease the amount of internal credits of the player by the cash out amount
    gameCredits[player_] -= amount_;

    // decrease the total amount of internal credits in the game
    totalGameCredits -= amount_;

    // transfer $CHIP from the player 
    pokerDaoChips.transfer(player_, amount_);
  }  


  // HOST ONLY: increase credits from a player. This is to track when a player keeps their winnings as in game credits.
  function addCredits(address player_, uint256 amount_) external onlyOwner {

    // if the total game credits after adding the amount exceeds the number of $CHIP tokens stored in the contract, throw an error
    if ( totalGameCredits + amount_ > pokerDaoChips.balanceOf(address(this)) )  { revert NotEnoughCredits(); }

    // increase the internal credits for a player in the game by the amount
    gameCredits[player_] += amount_;

    // increase the internal credits in the game by the amount
    totalGameCredits += amount_;

  }


  // HOST ONLY: deduct internal credits from a player. This is to track when a player "adds on".
  // NOTE: This does not transfer any $CHIP balances. 
  function deductCredits(address player_, uint256 amount_) external onlyOwner {

    // reduce the total amount of internal credits in the game
    totalGameCredits -= amount_;

    // reduce the amount of a player's internal credits in the game
    gameCredits[player_] -= amount_;
  }
}