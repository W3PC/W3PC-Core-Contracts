// SPDX-License-Identifier: GPL-2.0

pragma solidity ^0.8.10;

import "@rari-capital/solmate/src/tokens/ERC20.sol";


contract CreditPool {

  /////////////////////////////////////////////////////////////////////////////////
  //                             CONTRACT VARIABLES                              //
  /////////////////////////////////////////////////////////////////////////////////


  // internal credits for each member in the game
  mapping(address => uint256) public memberCredits;

  // total internal credits outstanding (across all members). Note: this can be less than the total reserve in the contract.
  uint256 public totalCredits;

  // ERC20 token contract for the $CHIP tokens used in the game
  ERC20 public immutable reserveToken;

  // mapping of addresses that can change internal credits
  mapping(address => bool) public isHost;

  // error for when the internal credits don't match the contract's $CHIP balance
  error NotEnoughCredits();

  // event for tracking member credit balances
  event CreditsUpdated(address indexed member, uint256 amount, bool isAdded);

  // event for tracking hosts
  event HostUpdated(address indexed host, address indexed caller, bool isAdded);

  // modifier to control access of protected functions
  modifier onlyHost() {
    require(isHost[msg.sender], "UNAUTHORIZED");
    _;
  }

  constructor(ERC20 reserveToken_) {
    // set the ERC20 token contract
    reserveToken = reserveToken_;

    // add the msg.sender as the first host
    isHost[msg.sender] = true;

    // broadcast that msg.sender is the first host
    emit HostUpdated(msg.sender, address(0), true);
  }


  /////////////////////////////////////////////////////////////////////////////////
  //                                USER INTERFACE                               //
  /////////////////////////////////////////////////////////////////////////////////


  // member buys credits
  function buyCredit(uint256 credits_) external {

    // increase the member credit by the posted amount
    memberCredits[msg.sender] += credits_;

    // increase the total game credits in the game by the amount the member buys in for
    totalCredits += credits_;

    // transfer the reserveToken token from the user's wallet to the pool contract for the purchaed amount
    // 6 decimals for USDC
    reserveToken.transferFrom(msg.sender, address(this), credits_ * 1e6);

    // credits have been added to member
    emit CreditsUpdated(msg.sender, credits_, true);
  }


  // member withdraws credits
  function withdrawCredit(uint256 credits_) external {

    // ensure the withdraw amount cannot exceed their internal credit balance
    if ( credits_ > memberCredits[msg.sender] )  { revert NotEnoughCredits(); }
    
    // decrease the internal credits of the member
    memberCredits[msg.sender] -= credits_;

    // reduce the total outstanding credits in the pool
    totalCredits -= credits_;

    // transfer reserveTokens to the member 
    reserveToken.transfer(msg.sender, credits_ * 1e6);

    // credits have been deducted from member
    emit CreditsUpdated(msg.sender, credits_, false);
  }


   // member tipping credits to the pool host
  function tip(uint256 tipAmt_) external {

    // if the amount of chips returned to the member exceeds their internal credit balance, throw an error
    if ( tipAmt_ > memberCredits[msg.sender] )  { revert NotEnoughCredits(); }
    
    // decrease the amount of internal credits of the member
    memberCredits[msg.sender] -= tipAmt_;

    // reduce the total outstanding credits in the pool
    totalCredits -= tipAmt_;

    // credits have been deducted from member
    emit CreditsUpdated(msg.sender, tipAmt_, false);
  }


  // HOST ONLY: add credits to a member's balance
  function addCredits(address member_, uint256 addedCredits_) external onlyHost {

    // ensure the total pool credits does not exceed the number of reserve tokens in the contract
    // 6 decimals for usdc
    if ( totalCredits + addedCredits_ > reserveToken.balanceOf(address(this)) / 1e6 )  { revert NotEnoughCredits(); }

    // increase the internal credits for a member in the pool by the amount
    memberCredits[member_] += addedCredits_;

    // increase the total outstanding credits in the pool
    totalCredits += addedCredits_;

    // credits have been added to member
    emit CreditsUpdated(member_, addedCredits_, true);
  }


  // HOST ONLY: deduct internal credits from a member.
  function deductCredits(address member_, uint256 deductedCredits_) external onlyHost {

    // reduce the member's credit
    memberCredits[member_] -= deductedCredits_;

    // reduce the total outstanding credits in the pool
    totalCredits -= deductedCredits_;

    // credits have been deducted from member
    emit CreditsUpdated(member_, deductedCredits_, false);
  }


  // called by an Host to add another Host
  function addHost(address newHost_) external onlyHost {

    // add address to whitelist
    isHost[newHost_] = true;

    // Host has been added
    emit HostUpdated(newHost_, msg.sender, true);
  }


  // called by an Host to remove another Host
  function removeHost(address oldHost_) external onlyHost {

    // remove address from Host whitelist
    isHost[oldHost_] = false;

    // Host has been removed
    emit HostUpdated(oldHost_, msg.sender, false);
  }
}
