// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "./IAuctionBase.sol";
import "@artman325/community/contracts/interfaces/ICommunity.sol";
interface IAuctionCommunity is IAuctionBase {
    function initialize(
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase calldata increase,
        uint32 maxWinners,
        SubscriptionManager manager,
        bool subscribeEvenIfNotFinished,
        ICommunity community,
        uint8[] calldata roleIds
    ) external;
   
}