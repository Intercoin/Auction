// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
interface SubscriptionManager {

}
interface IAuctionBase {
    struct Bid {
        address bidder;
        uint256 amount;
    }
     struct Increase {
        uint128 amount; // can't increase by over half the range
        uint32 numBids; // increase after this many bids
        bool canBidAboveIncrease;
    }

    function bid(uint256 amount) payable external;
    function winning() external view returns (Bid[] memory result);
    function cancel() external;
    function withdraw(address recipient) external;
    
}