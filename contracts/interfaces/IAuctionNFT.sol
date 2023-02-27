// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "./IAuctionBase.sol";

interface IAuctionNFT is IAuctionBase {
    enum NFTState {NONE, NOT_CLAIMED, CLAIMED}
    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        address nft,
        uint256[] memory tokenIds, 
        address costManager,
        address producedBy
    ) external;

    function NFTclaim(uint256 tokenId) external;
    function NFTtransfer(uint256 tokenId, address recipient) external;
}