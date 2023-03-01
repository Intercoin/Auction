// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "./AuctionBase.sol";
import "./interfaces/IAuctionCommunity.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@artman325/community/contracts/interfaces/ICommunity.sol";

contract AuctionCommunity is AuctionBase, IAuctionCommunity {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    EnumerableSetUpgradeable.UintSet internal roleIds;

    ICommunity internal communityContract;
    error roleUnknown();

    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint64 claimPeriod,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        address community,
        uint8[] memory roleIds_,
        address costManager,
        address producedBy
    ) 
        external 
        initializer 
    {
        
        __AuctionBase_init(token, cancelable, startTime, endTime, claimPeriod, startingPrice, increase, maxWinners, costManager, producedBy);

        communityContract = ICommunity(community);

        for(uint256 i = 0; i < roleIds_.length; i++) {
            roleIds.add(roleIds_[i]);
        } 
    }
   

    // winners can claim roles that auction can grant
    function roleClaim(
        uint8[] memory roleIndexes
    )
        public
    {
        address sender = _msgSender();
        _claim(sender);
        
        uint256 l = roleIndexes.length;
        address[] memory accounts = new address[](l);

        for (uint256 i=0; i<l; i++) {
            if (roleIds.contains(uint256(roleIndexes[i]))) {
                accounts[i] = sender;    
            } else {
                revert roleUnknown();
            }
        }
        
        communityContract.grantRoles(accounts, roleIndexes); // will revert if not allowed
        
    }
}
