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
    emit GameCreated(msg.sender, game);
  }
}  


contract Game {

  /////////////////////////////////////////////////////////////////////////////////
  //                             CONTRACT VARIABLES                              //
  /////////////////////////////////////////////////////////////////////////////////


  // ERC20 token contract for the $CHIP tokens used in the game
  ERC20 public immutable pokerDaoChips;

  // mapping of addresses that can change internal credits
  mapping(address => bool) public getAdmins;

  // event for tracking admins
  event AdminUpdated(address indexed admin, address indexed caller, bool isAdded);

  // modifier to control access of protected functions
  modifier onlyAdmin() {
    require(getAdmins[msg.sender], "UNAUTHORIZED");
    _;
  }

  constructor(address host_, ERC20 pokerDaoChips_) {
    // set the ERC20 token contract
    pokerDaoChips = pokerDaoChips_;

    // add the host as an admin
    getAdmins[host_] = true;
  }


  /////////////////////////////////////////////////////////////////////////////////
  //                                USER INTERFACE                               //
  /////////////////////////////////////////////////////////////////////////////////


  // player adding credits in the game
  function addChips(address player_, uint256 amount_) external onlyAdmin {

    // transfer the $CHIP token from the user's wallet to the game contract by the buy in amount
    pokerDaoChips.transferFrom(player_, address(this), amount_);
  }


  // HOST ONLY: trading internal credits in game for $CHIP (cashing out)
  function returnChips(address player_, uint256 amount_) external onlyAdmin {

    // transfer $CHIP from the player 
    pokerDaoChips.transfer(player_, amount_);
  }


  // called by an admin to add another admin
  function addAdmin(address newAdmin_) external onlyAdmin {

    // add address to whitelist
    getAdmins[newAdmin_] = true;

    // admin has been added
    emit AdminUpdated(newAdmin_, msg.sender, true);
  }


  // called by an admin to remove another admin
  function removeAdmin(address oldAdmin_) external onlyAdmin {

    // remove address from admin whitelist
    getAdmins[oldAdmin_] = false;

    // admin has been removed
    emit AdminUpdated(oldAdmin_, msg.sender, false);
  }

}
