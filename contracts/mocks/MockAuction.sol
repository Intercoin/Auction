// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;

import "../Auction.sol";

contract MockAuction is Auction {
    
    function getBids() public view returns (BidStruct[] memory) {
        return bids;
    }

    function getWinningSmallestIndex() public view returns(uint32) {
        return winningSmallestIndex;
    } 
    
    function claim() public {
        address sender = _msgSender();
        _claim(sender);
    }


}
