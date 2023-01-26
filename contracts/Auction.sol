// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IAuction.sol";
contract Auction is IAuction, OwnableUpgradeable {

    /**
uint32 duration in seconds, 0 means no auction end time, so it must be finished or canceled by owner
address currency (ERC20 contract, or 0x0 means native coin)
uint256 startingBid the first bid that starts the auction
uint256 minimumIncrease the minimum difference between bids
uint256 retainFraction the amount to refund when outbid, ranging between 0 and FRACTION=100000 (default is 0)
    */
    function initialize(
        AuctionParams memory params
    ) 
        public 
        virtual
        initializer
        override
    {
        
        __Auction_init(params);
        
    }

    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    // create	anyone	creates a new auction with default parameters, return auction `id`
    function create() external override {
        revert("TBD");
    }
    // bid	anyone	bid in an existing auction, at least `minimumBid` more than last bid. If successful, the previous bidder has tokens returned in the amount of `bidAmount.mul(FRACTION-retainFraction).div(FRACTION)`
    function bid(uint256 ) external override {
        revert("TBD");
    }
    // cancel	owner	can be called by the owner to cancel the auction, at any time
    function cancel(uint256) external override {
        revert("TBD");
    }
    // complete	owner	can be called by the owner to complete an auction
    function complete(uint256) external {
        revert("TBD");
    }
    // withdraw	owner	called by owner to withdraw the funds from the auction and send them to an address
    function withdraw(uint256,address) external {
        revert("TBD");
    }
    // setParameters	owner	update default settings
    function setParameters(AuctionParams memory) external {
        revert("TBD");
    }
    // prolong	owner	prolonging expired auction
    function prolong(uint256) external {
        revert("TBD");
    }
    // getWinner	anyone	view auction's winner
    function getWinner(uint256) external view returns(address) {
        revert("TBD");
    }
    // getHistory	anyone	view history of bids
    function getHistory(uint256) external returns(Bid[] memory) {
        revert("TBD");
    }


    function __Auction_init(
        AuctionParams memory params
        // uint256 duration,
        // address currency,
        // uint256 startingBid,
        // uint256 minimumIncrease,
        // uint256 retainFraction
    ) 
        internal 
        virtual
        initializer
    {


        __Ownable_init();
        
        
    } 


    
}