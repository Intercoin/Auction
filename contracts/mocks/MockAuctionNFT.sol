// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;

import "../AuctionNFT.sol";

contract MockAuctionNFT is AuctionNFT {
    
    function getBids() public view returns (BidStruct[] memory) {
        return bids;
    }

    function getWinningSmallestIndex() public view returns(uint32) {
        return winningSmallestIndex;
    } 
    

}
