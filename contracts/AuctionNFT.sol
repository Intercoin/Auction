// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "./AuctionBase.sol";
import "./interfaces/IAuctionNFT.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

contract AuctionNFT is AuctionBase, IAuctionNFT {
    INFT public nftContract;
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
    ) external {
        __AuctionBase_init(token, cancelable, startTime, endTime, startingPrice, increase, maxWinners, costManager, producedBy);

        nftContract = nft;
    }

    // auction winners can claim any NFT owned by the auction,
    // and shouldn't bid unless the count > maxWinners
    function NFTclaim(address nft, uint256 tokenId) external {
        address sender = _msgSender();
        requireWinner(_msgSender());
        winningBidIndex[sender].claimed = true;

        IERC721Upgradeable(nft).safeTransferFrom(address(this), sender, tokenId); // will revert if not owned
    }

    // auction owner can send the NFTs anywhere if auction was canceled
    // the auction owner would typically have been owner of all the NFTs sent to it
    function NFTtransfer(address nft, uint256 tokenId, address recipient) external onlyOwner {
        if (!canceled) {
            revert AuctionNotCanceled();
        }
        IERC721Upgradeable(nft).safeTransferFrom(address(this), _msgSender(), tokenId);
        
    }
}
