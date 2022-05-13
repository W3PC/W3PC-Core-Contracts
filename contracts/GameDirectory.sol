// SPDX-License-Identifier: GPL-2.0

pragma solidity ^0.8.10;

import "@rari-capital/solmate/src/tokens/ERC20.sol";


contract GameDirectory {
  
  // directory of user wallets => owned game contracts
  mapping ( address => address ) public hostedGames;

  // ERC20 contract address for $CHIP tokens to be used in games
  ERC20 public immutable chips;

  // error for when host address is already hosting a game
  error AlreadyHostingAGame();

  // event for tracking game creation and host address
  event GameCreated(address indexed game, address indexed host);


  constructor( ERC20 chips_ ) {

    // set chips in the constructor. This cannot be changed once launched
    chips = chips_;
  }


  // create and assign a Game contract to a host address if one doesn't exist
  function createGame() external {

    // if the host address is already hosting a game, throw an error
    if ( hostedGames[msg.sender] != address(0) ) { revert AlreadyHostingAGame(); }

    // create a game
    address game = address( new Game( msg.sender, chips) );

    // save the game address to the host address
    hostedGames[ msg.sender ] = game;

    // game has been created
    emit GameCreated(game, msg.sender);
  }
}  


contract Game {

  /////////////////////////////////////////////////////////////////////////////////
  //                             CONTRACT VARIABLES                              //
  /////////////////////////////////////////////////////////////////////////////////


  // internal credits for each player in the game
  mapping(address => uint256) public gameCredits;

  // total internal credits assigned in the game
  uint256 public totalGameCredits;

  // ERC20 token contract for the $CHIP tokens used in the game
  ERC20 public immutable pokerDaoChips;

  // mapping of addresses that can change internal credits
  mapping(address => bool) public isAdmin;

  // error for when the internal credits don't match the contract's $CHIP balance
  error NotEnoughCredits();

  // event for tracking player credit balances
  event CreditsUpdated(address indexed player, uint256 amount, bool isAdded);

  // event for tracking admins
  event AdminUpdated(address indexed admin, address indexed caller, bool isAdded);

  // modifier to control access of protected functions
  modifier onlyAdmin() {
    require(isAdmin[msg.sender], "UNAUTHORIZED");
    _;
  }

  constructor(address host_, ERC20 pokerDaoChips_) {
    // set the ERC20 token contract
    pokerDaoChips = pokerDaoChips_;

    // add the host as an admin
    isAdmin[host_] = true;
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


  // player removing credits from the game
  function returnChips(uint256 amount_) external {

    // if the amount of chips returned to the player exceeds their internal credit balance, throw an error
    if ( amount_ > gameCredits[msg.sender] )  { revert NotEnoughCredits(); }
    
    // decrease the amount of internal credits of the player by the cash out amount
    gameCredits[msg.sender] -= amount_;

    // decrease the total amount of internal credits in the game
    totalGameCredits -= amount_;

    // transfer $CHIP from the player 
    pokerDaoChips.transfer(msg.sender, amount_);
  }


  // HOST ONLY: increase credits from a player. This is to track when a player keeps their winnings as in game credits.
  function addCredits(address player_, uint256 amount_) external onlyAdmin {

    // if the total game credits after adding the amount exceeds the number of $CHIP tokens stored in the contract, throw an error
    if ( totalGameCredits + amount_ > pokerDaoChips.balanceOf(address(this)) )  { revert NotEnoughCredits(); }

    // increase the internal credits for a player in the game by the amount
    gameCredits[player_] += amount_;

    // increase the internal credits in the game by the amount
    totalGameCredits += amount_;

    // credits have been added to player
    emit CreditsUpdated(player_, amount_, true);
  }


  // HOST ONLY: deduct internal credits from a player. This is to track when a player "adds on".
  // NOTE: This does not transfer any $CHIP balances. 
  function deductCredits(address player_, uint256 amount_) external onlyAdmin {

    // reduce the total amount of internal credits in the game
    totalGameCredits -= amount_;

    // reduce the amount of a player's internal credits in the game
    gameCredits[player_] -= amount_;

    // credits have been deducted from player
    emit CreditsUpdated(player_, amount_, false);
  }

  // called by an admin to add another admin
  function addAdmin(address newAdmin_) external onlyAdmin {

    // add address to whitelist
    isAdmin[newAdmin_] = true;

    // admin has been added
    emit AdminUpdated(newAdmin_, msg.sender, true);
  }

  // called by an admin to remove another admin
  function removeAdmin(address oldAdmin_) external onlyAdmin {

    // remove address from admin whitelist
    isAdmin[oldAdmin_] = false;

    // admin has been removed
    emit AdminUpdated(oldAdmin_, msg.sender, false);
  }

}
