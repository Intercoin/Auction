// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@artman325/releasemanager/contracts/CostManagerFactoryHelper.sol";
import "@artman325/releasemanager/contracts/ReleaseManagerHelper.sol";
import "@artman325/releasemanager/contracts/ReleaseManager.sol";
import "./interfaces/IAuction.sol";
import "./interfaces/IAuctionNFT.sol";
import "./interfaces/IAuctionCommunity.sol";
import "./interfaces/IAuctionSubscription.sol";
import "./interfaces/IAuctionFactory.sol";


contract AuctionFactory is CostManagerFactoryHelper, ReleaseManagerHelper, IAuctionFactory {
    using Clones for address;
    using Address for address;

    /**
    * @custom:shortd implementationAuction address
    * @notice implementationAuction address
    */
    address public immutable implementationAuction;
    /**
    * @custom:shortd implementationAuctionNFT address
    * @notice implementationAuctionNFT address
    */
    address public immutable implementationAuctionNFT;
    /**
    * @custom:shortd implementationAuctionCommunity address
    * @notice implementationAuctionCommunity address
    */
    address public immutable implementationAuctionCommunity;
    /**
    * @custom:shortd implementationAuctionSubscription address
    * @notice implementationAuctionSubscription address
    */
    address public immutable implementationAuctionSubscription;

    address[] public instances;
    
    error InstanceCreatedFailed();
    error UnauthorizedContract(address controller);

    event InstanceCreated(address instance, uint instancesCount);

    /**
    */
    constructor(
        address _implementation,
        address _implementationNFT,
        address _implementationCommunity,
        address _implementationAuctionSubscription,
        address _costManager,
        address _releaseManager
    ) 
        CostManagerFactoryHelper(_costManager) 
        ReleaseManagerHelper(_releaseManager) 
    {
        implementationAuction = _implementation;
        implementationAuctionNFT = _implementationNFT;
        implementationAuctionCommunity = _implementationCommunity;
        implementationAuctionSubscription = _implementationAuctionSubscription;
    }

    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * @dev view amount of created instances
    * @return amount amount instances
    * @custom:shortd view amount of created instances
    */
    function instancesCount()
        external 
        view 
        returns (uint256 amount) 
    {
        amount = instances.length;
    }

    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////// Auction ////////////////////////////////////////////////
    /**
    * @notice produce Auction instance
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @return instance address of created instance `Auction`
    * @custom:shortd creation Auction instance
    */
    function produceAuction(
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuction.Increase calldata increase,
        uint32 maxWinners
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).clone();
        _beforeInit(instance);
        _validateParams(endTime);
        IAuction(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners);
        _afterInit(instance);
    }

    /**
    * @notice produce deterministic(with salt) Auction instance
    * @param salt salt
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @return instance address of created instance `Auction`
    * @custom:shortd creation Auction instance
    */
    function produceAuctionDeterministic(
        bytes32 salt,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuction.Increase calldata increase,
        uint32 maxWinners
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).cloneDeterministic(salt);
        _beforeInit(instance);
        IAuction(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners);
        _afterInit(instance);
    }
    //////////////////////////////////////////////// AuctionCommunity ////////////////////////////////////////////////
    /**
    * @notice produce AuctionCommunity instance
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @param community community contract
    * @param roleIds winners will obtain this rolesIds 
    * @return instance address of created instance `AuctionCommunity`
    * @custom:shortd creation AuctionCommunity instance
    */
    function produceCommunityAuction(
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuctionCommunity.Increase calldata increase,
        uint32 maxWinners,
        ICommunity community,
        uint8[] calldata roleIds
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).clone();
        _beforeInit(instance);
        _validateParams(endTime);
        ////////////////
        isInOurEcosystem(address(community));
        ////////////////
        IAuctionCommunity(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners, community, roleIds);
        _afterInit(instance);
    }

    /**
    * @notice produce deterministic(with salt) AuctionCommunity instance
    * @param salt salt
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @param community community contract
    * @param roleIds winners will obtain this rolesIds 
    * @return instance address of created instance `AuctionCommunity`
    * @custom:shortd creation AuctionCommunity instance
    */
    function produceAuctionCommunityDeterministic(
        bytes32 salt,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuctionCommunity.Increase calldata increase,
        uint32 maxWinners,
        ICommunity community,
        uint8[] calldata roleIds
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).cloneDeterministic(salt);
        _beforeInit(instance);
        ////////////////
        isInOurEcosystem(address(community));
        ////////////////
        IAuctionCommunity(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners, community, roleIds);
        _afterInit(instance);
    }
    //////////////////////////////////////////////// AuctionNFT //////////////////////////////////////////////////////
    /**
    * @notice produce AuctionNFT instance
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @param nft nonfungiblecontract contract
    * @param tokenIds winners will obtain this tokenIds 
    * @return instance address of created instance `AuctionNFT`
    * @custom:shortd creation AuctionNFT instance
    */
    function produceAuctionNFT(
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuctionNFT.Increase calldata increase,
        uint32 maxWinners,
        INFT nft,
        uint256[] calldata tokenIds
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).clone();
        _beforeInit(instance);
        _validateParams(endTime);
        ////////////////
        isInOurEcosystem(address(nft));
        ////////////////
        IAuctionNFT(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners, nft, tokenIds);
        _afterInit(instance);
    }

    /**
    * @notice produce deterministic(with salt) AuctionNFT instance
    * @param salt salt
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @param nft nonfungiblecontract contract
    * @param tokenIds winners will obtain this tokenIds 
    * @return instance address of created instance `AuctionNFT`
    * @custom:shortd creation AuctionNFT instance
    */
    function produceAuctionNFTDeterministic(
        bytes32 salt,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuctionNFT.Increase calldata increase,
        uint32 maxWinners,
        INFT nft,
        uint256[] calldata tokenIds
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).cloneDeterministic(salt);
        _beforeInit(instance);
        ////////////////
        isInOurEcosystem(address(nft));
        ////////////////
        IAuctionNFT(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners, nft, tokenIds);
        _afterInit(instance);
    }
    //////////////////////////////////////////////// AuctionSubscription /////////////////////////////////////////////
    /**
    * @notice produce AuctionSubscription instance
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @param manager subscription contract
    * @param subscribeEvenIfNotFinished do subscribe even if auction not finished
    * @return instance address of created instance `AuctionSubscription`
    * @custom:shortd creation AuctionSubscription instance
    */
    function produceAuctionSubscription(
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuctionSubscription.Increase calldata increase,
        uint32 maxWinners,
        ISubscriptionsManager manager,
        bool subscribeEvenIfNotFinished
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).clone();
        _beforeInit(instance);
        _validateParams(endTime);
        ////////////////
        isInOurEcosystem(address(manager));
        ////////////////
        IAuctionSubscription(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners, manager, subscribeEvenIfNotFinished);
        _afterInit(instance);
    }

    /**
    * @notice produce deterministic(with salt) AuctionSubscription instance
    * @param salt salt
    * @param cancelable can Auction be cancelled or no
    * @param startTime auction start time
    * @param endTime auction end time
    * @param startingPrice starting price 
    * @param increase incresetuple [amount, bidsCount, canBidAbove] how much will the price increase `amount` after `bidsCount` bids happens
    * @param maxWinners maximum winners
    * @param manager subscription contract
    * @param subscribeEvenIfNotFinished do subscribe even if auction not finished
    * @return instance address of created instance `AuctionSubscription`
    * @custom:shortd creation AuctionSubscription instance
    */
    function produceAuctionSubscriptionDeterministic(
        bytes32 salt,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        IAuctionSubscription.Increase calldata increase,
        uint32 maxWinners,
        ISubscriptionsManager manager,
        bool subscribeEvenIfNotFinished
    ) 
        public 
        returns (address instance) 
    {
        instance = address(implementationAuction).cloneDeterministic(salt);
        _beforeInit(instance);
        ////////////////
        isInOurEcosystem(address(manager));
        ////////////////
        IAuctionSubscription(instance).initialize(cancelable, startTime, endTime, startingPrice, increase, maxWinners, manager, subscribeEvenIfNotFinished);
        _afterInit(instance);
    }


/*
,
        SubscriptionManager manager,
        bool subscribeEvenIfNotFinished
* @param manager subscrptionMananger contract
    * @param subscribeEvenIfNotFinished subscribe even if subsscription is not finished
*/




    function doCharge(
        address targetToken, 
        uint256 amount, 
        address from, 
        address to
    ) 
        external 
        returns(bool returnSuccess) 
    {
        
        // we shoud not revert transaction, just return failed condition of `transferFrom` attempt
        bytes memory data = abi.encodeWithSelector(IERC20(targetToken).transferFrom.selector, from, to, amount);
        (bool success, bytes memory returndata) = address(targetToken).call{value: 0}(data);

        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(targetToken.isContract(), "Address: call to non-contract");
            }
            returnSuccess = true;
        } else {
            returnSuccess = false;
        }
        
    }


    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    function isInOurEcosystem(address controller) internal view {
        ////////////////
        bool success = ReleaseManager(releaseManager()).checkInstance(controller);
        if (!success) {
            revert UnauthorizedContract(controller);
        }
        ////////////////
    }
    function _beforeInit(
        address instance
    )
        internal
    {

        if (instance == address(0)) {
            revert InstanceCreatedFailed();
        }
        instances.push(instance);
        emit InstanceCreated(instance, instances.length);

    }

    function _validateParams(
        uint64 endTime
    )
        internal 
        view
    {
        require(endTime > block.timestamp, "invalid time");
    }
    
    function _afterInit(address instance) internal {
        //-- register instance in release manager
        registerInstance(instance);
        //-----------------
    }
}