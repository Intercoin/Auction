// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "./AuctionBase.sol";
import "./interfaces/IAuctionSubscription.sol";
import "@artman325/subscriptioncontract/contracts/interfaces/ISubscriptionsManagerUpgradeable.sol";
import "./libs/SwapSettingsLib.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";


contract AuctionSubscription is AuctionBase, IAuctionSubscription {
    
    ISubscriptionsManagerUpgradeable public subscriptionManager; // for subscribe function

    address internal wethAddr;

    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        address manager, 
        address costManager,
        address producedBy
    ) 
        external 
        initializer 
    {
        __AuctionBase_init(token, cancelable, startTime, endTime, startingPrice, increase, maxWinners, costManager, producedBy);
        if (manager == address(0)) {
            revert SubscriptionManagerMissing();
        }
        subscriptionManager = ISubscriptionsManagerUpgradeable(manager);
        

        // setup swap addresses
        (,,wethAddr,,,,) = SwapSettingsLib.netWorkSettings();
        
    }

    function subscribe(
        uint16 intervalsMin, 
        uint16 intervals
    ) 
        external
    {
        address sender = _msgSender();
        
        _claim(sender);
        
        uint32 index = winningBidIndex[sender].bidIndex;
        uint256 customPrice = bids[index].amount/intervalsMin;

        _spend(sender, index, true);

        subscriptionManager.subscribeFromController(
            sender, 
            customPrice, 
            intervals
        );
        
    }

    function _spend(
        address sender,
        uint32 index,
        bool asWETH
    ) private
    {
        
        //BidStruct storage b = bids[index];
        address bidder = bids[index].bidder;
        uint256 amount = bids[index].amount;

        winningBidIndex[sender].bidIndex = 0; // to prevent replay attacks, since winningSmallestIndex wasn't incremented
        winningBidIndex[sender].claimed = true;

        emit SpentBid(bidder, amount);

        if (token == address(0)) {
            if (asWETH) {
                IWETH(wethAddr).deposit{value: amount}();
                TransferHelper.safeTransfer(wethAddr, bidder, amount);

            } else {
                TransferHelper.safeTransferETH(bidder, amount);
            }
        } else {
            TransferHelper.safeTransfer(token, bidder, amount);
        }
        
    }

}


/*
    //
    // SUBSCRIPTION related
    // 

    

    function subscribe(address manager, uint16 intervalsMin, uint16 intervals)
    {
        if (subscriptionManager == address(0)) {
            throw SubscriptionManagerMissing();
        }
        if (canceled) {
            throw AuctionWasCanceled();
        }
        if (!subscribeEvenIfNotFinished && block.timestamp < endTime) {
            throw AuctionNotFinished();
        }
        address ms = _msgSender();
        index = winningBidIndex[ms];
        if (index == 0) {
            throw NotWinning();
        }

        uint256 amount = bids[index].amount;
        _spend(bids[index].bidder, amount, true);

        (success, result) = ISubscriptionManager(subscriptionManager).subscribe(
            _msgCaller(), amount / intervalsMin, intervals
        );
        if (!success) {
            throw SubscribeFailed();
        }
    }

    function _spend(address recipient, uint256 amount, bool asWETH) private
    {
        Bid b = bids[index];
        if (token == address(0)) {
            if (asWETH) {
                const address WETH = 0x...; // depends on the chain
                WETH.wrap(b.amount);
                WETH.transfer(ms, b.amount);
            } else {
                send(ms, b.amount);
            }
        } else {
            IERC20(token).transfer(ms, amount);
        }
        bids[index] = 0; // to prevent replay attacks, since winningSmallestIndex wasn't incremented
        emit SpentBid(b.bidder, b.amount);
    }

*/