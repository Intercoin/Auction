// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "./IAuctionBase.sol";
import "@artman325/nonfungibletokencontract/contracts/interfaces/INFT.sol";

interface IAuctionNFT is IAuctionBase {
    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        INFT nft,
        uint256[] memory tokenIds, 
        address costManager,
        address producedBy
    ) external;

    function NFTclaim(address NFT, uint256 tokenId) external;
    function NFTtransfer(address NFT, uint256 tokenId, address recipient) external;
}