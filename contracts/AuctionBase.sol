// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IAuctionBase.sol";
import "./interfaces/IAuctionFactory.sol";
import "@artman325/releasemanager/contracts/CostManagerHelper.sol";
//import "hardhat/console.sol";
contract AuctionBase is IAuctionBase, ReentrancyGuardUpgradeable, CostManagerHelper, OwnableUpgradeable {

    event AlreadyWinning(address bidder, uint256 index);
    event Bid(address bidder, uint256 amount, uint32 numBids);
    event RefundedBid(address bidder, uint256 amount);
    event SpentBid(address bidder, uint256 amount);

    error OutsideOfIntercoinEcosystem();
    error ChargeFailed();
    error BidTooSmall();
    error NotWinning();
    error AlreadyClaimed();
    error SubscribeFailed();
    error NotCancelable();
    error CannotBidAboveCurrentPrice();

    error AuctionWasCanceled();
    error AuctionNotCanceled();
    error AuctionNotFinished();
    error MaximumBidsAmountExceeded();

    //address factory;
    //address owner; // whoever called produce() or produceDeterministic()
    address token; // 0 means native coin

    

    bool canceled;
    bool cancelable;
    uint64 startTime;
    uint64 endTime;
    uint256 startingPrice;
    uint256 currentPrice;
    Increase priceIncrease;

    BidStruct[] public bids;
    uint32 public maxWinners;
    uint32 public winningSmallestIndex; // starts at 1

    struct WinningStruct {
        uint32 bidIndex;
        bool claimed;
    }
    mapping (address => WinningStruct) winningBidIndex; // 1-based index, thus 0 means not winning

    // Constants for shifts
    uint8 internal constant SERIES_SHIFT_BITS = 192; // 256 - 64
    uint8 internal constant OPERATION_SHIFT_BITS = 240;  // 256 - 16
    
    // Constants representing operations
    uint8 internal constant OPERATION_INITIALIZE = 0x0;
    
    constructor() {
        _disableInitializers();
    }
    
    function __AuctionBase_init(
        address token_,
        bool cancelable_,
        uint64 startTime_,
        uint64 endTime_,
        uint256 startingPrice_,
        Increase memory increase_,
        uint32 maxWinners_, 
        address costManager,
        address producedBy
    ) 
        internal
        
    {
        __Ownable_init();
        __ReentrancyGuard_init();

        __CostManagerHelper_init(_msgSender()); // here sender it's deployer/ it's our factory.
        // or we can put `owner()` instead `_msgSender()`. it was the same here
        // EOA will be owner after factory will transferOwnership in produce

        _setCostManager(costManager);

        token = token_;
        canceled = false;
        cancelable = cancelable_;
        startTime = startTime_;
        endTime = endTime_;
        startingPrice = startingPrice_;
        priceIncrease.amount = increase_.amount;
        priceIncrease.numBids = increase_.numBids;
        priceIncrease.canBidAboveIncrease = increase_.canBidAboveIncrease;
        maxWinners = maxWinners_;

        winningBidIndex[address(0)].bidIndex = 0;

        _accountForOperation(
            OPERATION_INITIALIZE << OPERATION_SHIFT_BITS,
            uint256(uint160(producedBy)),
            0
        );
    }

    function bid(uint256 amount) payable public {
        
        address ms = _msgSender();
        uint32 index = winningBidIndex[ms].bidIndex;

        if (index > 0) {
            emit AlreadyWinning(ms, index);
            return;
        }

        if (token != address(0) && amount == 0) {
            amount = currentPrice;
        }
        if (amount < currentPrice) {
            revert BidTooSmall();
        }
        if (currentPrice < amount) {
            if (!priceIncrease.canBidAboveIncrease) {
                revert CannotBidAboveCurrentPrice();
            }
            currentPrice = amount;
        }

        _charge(ms, amount);

        if (bids.length % priceIncrease.numBids == 0) {
            currentPrice += priceIncrease.amount; // every so often
        }
        
        if (bids.length + 1 > maxWinners) {
            _refundBid(winningSmallestIndex);
            winningSmallestIndex++;
        }

        if (bids.length > type(uint32).max) {
            revert MaximumBidsAmountExceeded();
        }


        bids.push(BidStruct(ms, amount));

        winningBidIndex[ms].bidIndex = uint32(bids.length)/* - 1*/;
        emit Bid(ms, amount, uint32(bids.length));
        
    }

    // return winning bids, from largest to smallest
    function winning() external view returns (BidStruct[] memory result) {
        uint32 l = uint32(bids.length);
       
        result = new BidStruct[](l-winningSmallestIndex);
        uint256 ii = 0;
        for (uint32 i=l-1; i >= winningSmallestIndex; --i) {
            result[ii] = bids[i];
            ii++;
        }
    }

    // sends all the money back to the people
    function cancel() external onlyOwner {
        if (!cancelable) {
            revert NotCancelable();
        }
        uint32 l = uint32(bids.length);
        for (uint32 i=winningSmallestIndex; i<l; ++i) {
            _refundBid(i); // send money back
        }
        canceled = true;
    }

    // owner withdraws all the money after auction is over
    function withdraw(address recipient) external onlyOwner {
        if (block.timestamp < endTime) {
            revert AuctionNotFinished();
        }

        // if (token == address(0)) {
        //     send(recipient, this.balance);
        // } else {
        //     IERC20(token).transfer(recipient, IERC20(token).balanceOf(this));
        // }
        uint256 totalContractBalance = IERC20Upgradeable(token).balanceOf(address(this));
        IERC20Upgradeable(token).transfer(recipient, totalContractBalance);
    }
   
    // should be call in any variant of claim
    // validation sender as winner, setup sender as already claimed  etc
    function _claim(address sender) internal {
        requireWinner(sender);
        winningBidIndex[sender].claimed = true;
    }
     
    function requireWinner(address sender) internal view {
        if (canceled) {
            revert AuctionWasCanceled();
        }
        if (block.timestamp < endTime) {
            revert AuctionNotFinished();
        }
        
        if (winningBidIndex[sender].bidIndex == 0) {
            revert NotWinning();
        }
        if (winningBidIndex[sender].claimed == true) {
            revert AlreadyClaimed();
        }

    }
    
    function _charge(address payer, uint256 amount) private {
        bool success = IAuctionFactory(deployer).doCharge(token, amount, payer, address(this));
        if (!success) {
            revert ChargeFailed();
        }
    }

    // send back the bids when someone isn't winning anymore
    function _refundBid(uint32 index) private
    {
        BidStruct storage b = bids[index];
        // if (token == address(0)) {
        //     send(b.bidder, b.amount);
        // } else {
        //     IERC20(token).transfer(b.bidder, b.amount);
        // }
        IERC20Upgradeable(token).transfer(b.bidder, b.amount);
        emit RefundedBid(b.bidder, b.amount);
        //bids[winningSmallestIndex] = 0; // or maybe use delete
        delete bids[winningSmallestIndex];
        delete winningBidIndex[b.bidder];
        
    }

}