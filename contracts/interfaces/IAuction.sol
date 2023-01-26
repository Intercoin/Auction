// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuction {
    struct AuctionParams {
        uint256 duration;
        address currency;
        uint256 startingBid;
        uint256 minimumIncrease;
        uint256 retainFraction;
    }

    struct Bid {
        address addr;
        uint256 amount;
    }

    function initialize(AuctionParams memory) external;

    // create	anyone	creates a new auction with default parameters, return auction `id`
    function create() external;
    // bid	anyone	bid in an existing auction, at least `minimumBid` more than last bid. If successful, the previous bidder has tokens returned in the amount of `bidAmount.mul(FRACTION-retainFraction).div(FRACTION)`
    function bid(uint256) external;
    // cancel	owner	can be called by the owner to cancel the auction, at any time
    function cancel(uint256) external;
    // complete	owner	can be called by the owner to complete an auction
    function complete(uint256) external;
    // withdraw	owner	called by owner to withdraw the funds from the auction and send them to an address
    function withdraw(uint256,address) external;
    // setParameters	owner	update default settings
    function setParameters(AuctionParams memory) external;
    // prolong	owner	prolonging expired auction
    function prolong(uint256) external;
    // getWinner	anyone	view auction's winner
    function getWinner(uint256) external view returns(address);
    // getHistory	anyone	view history of bids
    function getHistory(uint256) external returns(Bid[] memory);
}