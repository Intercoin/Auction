// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "./IAuctionBase.sol";

interface IAuctionCommunity is IAuctionBase {
    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        address community,
        uint8[] memory roleIds, 
        address costManager,
        address producedBy
    ) external;
   
}