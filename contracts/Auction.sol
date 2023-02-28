// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "./AuctionBase.sol";
import "./interfaces/IAuction.sol";
contract Auction is AuctionBase, IAuction {
     function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners, 
        address costManager,
        address producedBy
    )    
        external 
        initializer 
    {
        __AuctionBase_init(token, cancelable, startTime, endTime, startingPrice, increase, maxWinners, costManager, producedBy);
    }
}
