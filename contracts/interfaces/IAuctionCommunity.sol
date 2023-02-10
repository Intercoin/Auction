// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "./IAuctionBase.sol";
import "@artman325/community/contracts/interfaces/ICommunity.sol";

interface IAuctionCommunity is IAuctionBase {
    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase calldata increase,
        uint32 maxWinners,
        ICommunity community,
        uint8[] calldata roleIds, 
        address costManager,
        address producedBy
    ) external;
   
}