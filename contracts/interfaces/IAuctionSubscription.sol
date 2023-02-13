// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "./IAuctionBase.sol";
import "@artman325/subscriptioncontract/contracts/interfaces/ISubscriptionsManager.sol";

interface IAuctionSubscription is IAuctionBase {
    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        ISubscriptionsManager manager,
        bool subscribeEvenIfNotFinished, 
        address costManager,
        address producedBy
    ) external;
   
}