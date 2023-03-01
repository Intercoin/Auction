// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "./AuctionBase.sol";
import "./interfaces/IAuctionNFT.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
//import "hardhat/console.sol";
contract AuctionNFT is AuctionBase, IAuctionNFT {
    error NFTAlreadyClaimed();
    error NFTNotFound();

    ERC721Upgradeable public nftContract;
    mapping(uint256 => NFTState) private tokenIds;

    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint64 claimPeriod,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        address nft,
        uint256[] memory tokenIds_, 
        address costManager,
        address producedBy
    ) 
        external 
        initializer 
    {
        
        __AuctionBase_init(token, cancelable, startTime, endTime, claimPeriod, startingPrice, increase, maxWinners, costManager, producedBy);

        nftContract = ERC721Upgradeable(nft);

        for(uint256 i = 0; i < tokenIds_.length; i++) {
            tokenIds[tokenIds_[i]] = NFTState.NOT_CLAIMED;
        } 
    }

    // auction winners can claim any NFT owned by the auction,
    // and shouldn't bid unless the count > maxWinners
    function NFTclaim(uint256 tokenId) external {
        address sender = _msgSender();
        _claim(sender);

        checkNFT(tokenId);
        
        //nftContract.safeTransferFrom(address(this), sender, tokenId); // will revert if not owned
        try nftContract.safeTransferFrom(address(this), sender, tokenId) {
            // all ok
        } catch {
            // else if any errors. do refund
            _refundBid(winningBidIndex[sender].bidIndex);
        }
    }

    // auction owner can send the NFTs anywhere if auction was canceled
    // the auction owner would typically have been owner of all the NFTs sent to it
    function NFTtransfer(uint256 tokenId, address recipient) external onlyOwner {
        if (!canceled) {
            revert AuctionNotCanceled();
        }
        checkNFT(tokenId);
        nftContract.safeTransferFrom(address(this), recipient, tokenId);
        
    }

    function checkNFT(uint256 tokenId) private {
        
        if (tokenIds[tokenId] == NFTState.NONE) {
            revert NFTNotFound();
        }
        if (tokenIds[tokenId] == NFTState.CLAIMED) {
            revert NFTAlreadyClaimed();
        }
        tokenIds[tokenId] = NFTState.CLAIMED;
    }
}
