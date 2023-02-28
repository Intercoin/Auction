const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');
//const { time } = require('@openzeppelin/test-helpers');

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';
const UNISWAP_ROUTER_FACTORY_ADDRESS = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f';
const UNISWAP_ROUTER = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';


const ZERO = BigNumber.from('0');
const ONE = BigNumber.from('1');
const TWO = BigNumber.from('2');
const THREE = BigNumber.from('3');
const FOURTH = BigNumber.from('4');
const FIVE = BigNumber.from('5');
const SIX = BigNumber.from('6');
const SEVEN = BigNumber.from('7');
const EIGHT = BigNumber.from('8');
const NINE = BigNumber.from('9');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');
const THOUSAND = BigNumber.from('1000');

const ONE_ETH = TEN.pow(BigNumber.from('18'));

const FRACTION = BigNumber.from('10000');


chai.use(require('chai-bignumber')());

describe("TradedTokenInstance", function () {
    const accounts = waffle.provider.getWallets();

    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];
    const david = accounts[4];
    const recipient = accounts[5];
    
    const NO_COSTMANAGER = ZERO_ADDRESS;
    
    var tmp;

    describe("factory produce", function () {
        const salt    = "0x00112233445566778899AABBCCDDEEFF00000000000000000000000000000000";
        const salt2   = "0x00112233445566778899AABBCCDDEEFF00000000000000000000000000000001";

        var Auction;
        var AuctionFactory;
        var AuctionImpl;
        var AuctionCommunityImpl;
        var AuctionNFTImpl;
        var AuctionSubscriptionImpl;
        
        //var CommunityMock;
        var releaseManager;
        var erc20;
        var mockUseful;
        var p;

        beforeEach("deploying", async() => {
            let ReleaseManagerFactoryF = await ethers.getContractFactory("MockReleaseManagerFactory");
            let ReleaseManagerF = await ethers.getContractFactory("MockReleaseManager");
            
            let implementationReleaseManager    = await ReleaseManagerF.deploy();

            let releaseManagerFactory   = await ReleaseManagerFactoryF.connect(owner).deploy(implementationReleaseManager.address);
            let tx,rc,event,instance,instancesCount;
            //
            tx = await releaseManagerFactory.connect(owner).produce();
            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceProduced');
            [instance, instancesCount] = event.args;
            releaseManager = await ethers.getContractAt("MockReleaseManager",instance);

            let AuctionFactoryF = await ethers.getContractFactory("AuctionFactory");
            let AuctionF = await ethers.getContractFactory("Auction");
            let AuctionCommunityF = await ethers.getContractFactory("AuctionCommunity");
            let AuctionNFTF = await ethers.getContractFactory("AuctionNFT");
            let AuctionSubscriptionF = await ethers.getContractFactory("AuctionSubscription");

            // let SubscriptionsManagerFactoryF = await ethers.getContractFactory("MockSubscriptionsManagerFactory");
            // let SubscriptionsManagerF = await ethers.getContractFactory("SubscriptionsManagerUpgradeable");

            AuctionImpl = await AuctionF.connect(owner).deploy();
            AuctionCommunityImpl = await AuctionCommunityF.connect(owner).deploy();
            AuctionNFTImpl = await AuctionNFTF.connect(owner).deploy();
            AuctionSubscriptionImpl = await AuctionSubscriptionF.connect(owner).deploy();

            AuctionFactory = await AuctionFactoryF.connect(owner).deploy(
                AuctionImpl.address, 
                AuctionNFTImpl.address, 
                AuctionCommunityImpl.address, 
                AuctionSubscriptionImpl.address, 
                NO_COSTMANAGER, 
                releaseManager.address
            );

            // 
            const factoriesList = [AuctionFactory.address];
            const factoryInfo = [
                [
                    1,//uint8 factoryIndex; 
                    1,//uint16 releaseTag; 
                    "0x53696c766572000000000000000000000000000000000000"//bytes24 factoryChangeNotes;
                ]
            ];

            await releaseManager.connect(owner).newRelease(factoriesList, factoryInfo);

            let ERC20Factory = await ethers.getContractFactory("ERC20Mintable");
            erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");

            let MockUsefulF = await ethers.getContractFactory("MockUsefulContract");
            mockUseful = await MockUsefulF.deploy();

            let currentTime = await mockUseful.currentBlockTimestamp();
            p = [
                erc20.address,          // address token,
                false,                  // bool cancelable,
                currentTime,            // uint64 startTime,
                currentTime.add(86400), // uint64 endTime,
                ONE_ETH,                // uint256 startingPrice,
                // IAuction.Increase memory increase,
                // struct Increase {
                //     uint128 amount; // can't increase by over half the range
                //     uint32 numBids; // increase after this many bids
                //     bool canBidAboveIncrease;
                // }
                [
                   ONE_ETH.div(TEN),
                   TEN,
                   false
                ],
                FIVE                    // uint32 maxWinners
            ];
            
            // rc = await tx.wait(); // 0ms, as tx is already confirmed
            // event = rc.events.find(event => event.event === 'InstanceCreated');
            // [instance, instancesCount] = event.args;
            // SubscriptionsManager = await ethers.getContractAt("SubscriptionsManager",instance);
        });

        it("should produce", async() => {

            let tx = await AuctionFactory.connect(owner).produceAuction(...p);

            const rc = await tx.wait(); // 0ms, as tx is already confirmed
            const event = rc.events.find(event => event.event === 'InstanceCreated');
            const [instance,] = event.args;
            expect(instance).not.to.be.eq(ZERO_ADDRESS);
            
        });
        
        it("should produce deterministic", async() => {
            p = [salt, ...p]; // prepend salt into params as first param
            let tx = await AuctionFactory.connect(owner).produceAuctionDeterministic(...p);

            let rc = await tx.wait(); // 0ms, as tx is already confirmed
            let event = rc.events.find(event => event.event === 'InstanceCreated');
            let [instance,] = event.args;
            
            await expect(AuctionFactory.connect(owner).produceAuctionDeterministic(...p)).to.be.revertedWith('ERC1167: create2 failed');

        });

        it("can't create2 if created before with the same salt, even if different sender", async() => {
            let tx,event,instanceWithSaltAgain, instanceWithSalt, instanceWithSalt2;

            //make snapshot
            let snapId = await ethers.provider.send('evm_snapshot', []);
            let p1 =[salt, ...p]; // prepend salt into params as first param
            tx = await AuctionFactory.connect(owner).produceAuctionDeterministic(...p1);
            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceCreated');
            [instanceWithSalt,] = event.args;
            //revert snapshot
            await ethers.provider.send('evm_revert', [snapId]);

            let p2 =[salt2, ...p]; // prepend salt into params as first param
            // make create2. then create and finally again with salt. 
            tx = await AuctionFactory.connect(owner).produceAuctionDeterministic(...p2);
            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceCreated');
            [instanceWithSalt2,] = event.args;
            
            await AuctionFactory.connect(owner).produceAuction(...p);

            tx = await AuctionFactory.connect(owner).produceAuctionDeterministic(...p1);
            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceCreated');
            [instanceWithSaltAgain,] = event.args;


            expect(instanceWithSaltAgain).to.be.eq(instanceWithSalt);
            expect(instanceWithSalt2).not.to.be.eq(instanceWithSalt);

            await expect(AuctionFactory.connect(owner).produceAuctionDeterministic(...p1)).to.be.revertedWith('ERC1167: create2 failed');
            await expect(AuctionFactory.connect(owner).produceAuctionDeterministic(...p2)).to.be.revertedWith('ERC1167: create2 failed');
            await expect(AuctionFactory.connect(alice).produceAuctionDeterministic(...p2)).to.be.revertedWith('ERC1167: create2 failed');
            
        });

        it("shouldnt initialize again", async() => {
            let tx, rc, event, instance, instancesCount;
            tx = await AuctionFactory.connect(owner).produceAuction(...p);

            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceCreated');
            [instance,] = event.args;
            
            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceCreated');
            [instance, instancesCount] = event.args;
            let subscriptionsManager = await ethers.getContractAt("Auction",instance);

            let p1 =[...p, ZERO_ADDRESS, ZERO_ADDRESS]; // prepend salt into params as first param
            await expect(
                subscriptionsManager.connect(owner).initialize(...p1)
            ).to.be.revertedWith('Initializable: contract is already initialized');

        });

        it("shouldnt initialize implementation", async() => {
            
            let p1 =[...p, ZERO_ADDRESS, ZERO_ADDRESS]; 
            await expect(
                AuctionImpl.connect(owner).initialize(...p1)
            ).to.be.revertedWith('Initializable: contract is already initialized');
            
        });

        it("controller must be optional(zero) overwise must be in our ecosystem", async() => {
           
            //await AuctionFactory.connect(owner).produceCommunityAuction(...p);
            let pWithWrongController;
            let currentTime = await mockUseful.currentBlockTimestamp();
            pWithWrongControllerAsEOAUser = [
                erc20.address,false,currentTime,currentTime.add(86400),ONE_ETH,[ONE_ETH.div(TEN),TEN,false],FIVE,
                recipient.address, //address community,
                [1,2,3] //uint8[] memory roleIds
            ];
            await expect(
                AuctionFactory.connect(owner).produceCommunityAuction(...pWithWrongControllerAsEOAUser)
            ).to.be.revertedWith(`UnauthorizedContract("${recipient.address}")`);

            pWithWrongControllerAsERC20 = [
                erc20.address,false,currentTime,currentTime.add(86400),ONE_ETH,[ONE_ETH.div(TEN),TEN,false],FIVE,
                erc20.address, //address controller,
                [1,2,3] //uint8[] memory roleIds
            ];
            await expect(
                AuctionFactory.connect(owner).produceCommunityAuction(...pWithWrongControllerAsERC20)
            ).to.be.revertedWith(`UnauthorizedContract("${erc20.address}")`);

        });

        it("instancesCount shoud be increase after produceAuction", async() => {
            let beforeProduce = await AuctionFactory.instancesCount();
            await AuctionFactory.connect(owner).produceAuction(...p);
            let afterProduce = await AuctionFactory.instancesCount();
            expect(afterProduce).to.be.eq(beforeProduce.add(ONE))
        });

        it("should registered instance in release manager", async() => {
            let tx, rc, event, instance;
            tx = await AuctionFactory.connect(owner).produceAuction(...p);

            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceCreated');
            [instance,] = event.args;
            
            let success = await releaseManager.checkInstance(instance);
            expect(success).to.be.true;
            let notSuccess = await releaseManager.checkInstance(erc20.address);
            expect(notSuccess).to.be.false;
        });

        it("sender should be an owner of instance, not factory!", async() => {
            let tx = await AuctionFactory.connect(bob).produceAuction(...p);

            const rc = await tx.wait(); // 0ms, as tx is already confirmed
            const event = rc.events.find(event => event.event === 'InstanceCreated');
            const [instance,] = event.args;

            let auction = await ethers.getContractAt("Auction",instance);
            let ownerOfInstance = await auction.owner();
            expect(ownerOfInstance).not.to.be.eq(AuctionFactory.address);
            expect(ownerOfInstance).not.to.be.eq(owner.address);
            expect(ownerOfInstance).to.be.eq(bob.address);
            
        });
        
    });

    describe("auction test", function () {
        const salt    = "0x00112233445566778899AABBCCDDEEFF00000000000000000000000000000000";
        const salt2   = "0x00112233445566778899AABBCCDDEEFF00000000000000000000000000000001";

        var Auction;
        var AuctionFactory;
        var AuctionImpl;
        var AuctionCommunityImpl;
        var AuctionNFTImpl;
        var AuctionSubscriptionImpl;
        
        //var CommunityMock;
        var releaseManager;
        var erc20;
        var mockUseful;
        var p;

        beforeEach("deploying", async() => {
            let ReleaseManagerFactoryF = await ethers.getContractFactory("MockReleaseManagerFactory");
            let ReleaseManagerF = await ethers.getContractFactory("MockReleaseManager");
            
            let implementationReleaseManager    = await ReleaseManagerF.deploy();

            let releaseManagerFactory   = await ReleaseManagerFactoryF.connect(owner).deploy(implementationReleaseManager.address);
            let tx,rc,event,instance,instancesCount;
            //
            tx = await releaseManagerFactory.connect(owner).produce();
            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceProduced');
            [instance, instancesCount] = event.args;
            releaseManager = await ethers.getContractAt("MockReleaseManager",instance);

            let AuctionFactoryF = await ethers.getContractFactory("AuctionFactory");
            let AuctionF = await ethers.getContractFactory("MockAuction");
            let AuctionCommunityF = await ethers.getContractFactory("AuctionCommunity");
            let AuctionNFTF = await ethers.getContractFactory("AuctionNFT");
            let AuctionSubscriptionF = await ethers.getContractFactory("AuctionSubscription");

            // let SubscriptionsManagerFactoryF = await ethers.getContractFactory("MockSubscriptionsManagerFactory");
            // let SubscriptionsManagerF = await ethers.getContractFactory("SubscriptionsManagerUpgradeable");

            AuctionImpl = await AuctionF.connect(owner).deploy();
            AuctionCommunityImpl = await AuctionCommunityF.connect(owner).deploy();
            AuctionNFTImpl = await AuctionNFTF.connect(owner).deploy();
            AuctionSubscriptionImpl = await AuctionSubscriptionF.connect(owner).deploy();

            AuctionFactory = await AuctionFactoryF.connect(owner).deploy(
                AuctionImpl.address, 
                AuctionNFTImpl.address, 
                AuctionCommunityImpl.address, 
                AuctionSubscriptionImpl.address, 
                NO_COSTMANAGER, 
                releaseManager.address
            );

            // 
            const factoriesList = [AuctionFactory.address];
            const factoryInfo = [
                [
                    1,//uint8 factoryIndex; 
                    1,//uint16 releaseTag; 
                    "0x53696c766572000000000000000000000000000000000000"//bytes24 factoryChangeNotes;
                ]
            ];

            await releaseManager.connect(owner).newRelease(factoriesList, factoryInfo);

            let ERC20Factory = await ethers.getContractFactory("ERC20Mintable");
            erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");

            let MockUsefulF = await ethers.getContractFactory("MockUsefulContract");
            mockUseful = await MockUsefulF.deploy();

            
            // rc = await tx.wait(); // 0ms, as tx is already confirmed
            // event = rc.events.find(event => event.event === 'InstanceCreated');
            // [instance, instancesCount] = event.args;
            // SubscriptionsManager = await ethers.getContractAt("SubscriptionsManager",instance);
        });

        it("should have N winners and keep up to N bidders during the auction", async() => {
            const MaxWinners = 3;
            let currentTime = await mockUseful.currentBlockTimestamp();
            let startingPrice = ONE_ETH;
            let increasePrice = BigNumber.from('1000000000'); //gwei
            p = [
                erc20.address,          // address token,
                false,                  // bool cancelable,
                currentTime,            // uint64 startTime,
                currentTime.add(86400), // uint64 endTime,
                startingPrice,          // uint256 startingPrice,
                [
                   increasePrice,// can't increase by over half the range
                   TEN,             // increase after this many bids
                   true            //     bool canBidAboveIncrease;
                ],
                MaxWinners// uint32 maxWinners
            ];

            let tx = await AuctionFactory.connect(owner).produceAuction(...p);

            const rc = await tx.wait(); // 0ms, as tx is already confirmed
            const event = rc.events.find(event => event.event === 'InstanceCreated');
            const [instance,] = event.args;
            expect(instance).not.to.be.eq(ZERO_ADDRESS);
            
            let auctionInstance = await ethers.getContractAt("MockAuction",instance);

            // put several bids
            let addresses = [
                owner,
                alice,
                bob,
                charlie,
                david,
                recipient
            ];
            
            let tmp2Bid;
            for(let i = 0; i<addresses.length; i++) {

                tmp2Bid = startingPrice.add(increasePrice.mul(i+1));

                await erc20.mint(addresses[i].address, tmp2Bid);
                await erc20.connect(addresses[i]).approve(AuctionFactory.address, tmp2Bid);
                
                await auctionInstance.connect(addresses[i]).bid(tmp2Bid);

                expect(await auctionInstance.getWinningSmallestIndex()).to.be.eq(i >= MaxWinners ? i - MaxWinners + 1 : 0);
            }
            
            let winning = await auctionInstance.winning();
            expect(winning.length).to.be.eq(MaxWinners);

        });

        it("shouldn't let winners claim twice", async() => {
            const MaxWinners = 2;
            let currentTime = await mockUseful.currentBlockTimestamp();
            let startingPrice = ONE_ETH;
            let increasePrice = BigNumber.from('1000000000'); //gwei
            p = [
                erc20.address,          // address token,
                false,                  // bool cancelable,
                currentTime,            // uint64 startTime,
                currentTime.add(86400), // uint64 endTime,
                startingPrice,          // uint256 startingPrice,
                [
                   increasePrice,// can't increase by over half the range
                   TEN,             // increase after this many bids
                   true            //     bool canBidAboveIncrease;
                ],
                MaxWinners// uint32 maxWinners
            ];

            let tx = await AuctionFactory.connect(owner).produceAuction(...p);

            const rc = await tx.wait(); // 0ms, as tx is already confirmed
            const event = rc.events.find(event => event.event === 'InstanceCreated');
            const [instance,] = event.args;
            expect(instance).not.to.be.eq(ZERO_ADDRESS);
            
            let auctionInstance = await ethers.getContractAt("MockAuction",instance);

            let tmp2Bid = startingPrice.add(increasePrice);

            await erc20.mint(alice.address, tmp2Bid);
            await erc20.connect(alice).approve(AuctionFactory.address, tmp2Bid);
            await auctionInstance.connect(alice).bid(tmp2Bid);

            tmp2Bid = startingPrice.add(increasePrice.mul(TWO));
            await erc20.mint(bob.address, tmp2Bid);
            await erc20.connect(bob).approve(AuctionFactory.address, tmp2Bid);
            await auctionInstance.connect(bob).bid(tmp2Bid);
            
            //pass 86400 seconds
            await network.provider.send("evm_increaseTime", [parseInt(86400)]);
            await network.provider.send("evm_mine"); // this one will have 02:00 PM as its timestamp

            // try to claim. but for `Auction` instance there are no claim method. and winners is a immutable state.
            // this trick is just for example to validate `auctionBase._claim` method which run for any other instances: AuctionNFT, AuctionSubscription, AuctionCommunity
            await auctionInstance.connect(bob).claim();
            
            await expect(
                auctionInstance.connect(bob).claim()
            ).to.be.revertedWith('AlreadyClaimed()');
            
        });

        it("shouldn't let winners claim before auction end", async() => {
            const MaxWinners = 2;
            let currentTime = await mockUseful.currentBlockTimestamp();
            let startingPrice = ONE_ETH;
            let increasePrice = BigNumber.from('1000000000'); //gwei
            p = [
                erc20.address,          // address token,
                false,                  // bool cancelable,
                currentTime,            // uint64 startTime,
                currentTime.add(86400), // uint64 endTime,
                startingPrice,          // uint256 startingPrice,
                [
                   increasePrice,// can't increase by over half the range
                   TEN,             // increase after this many bids
                   true            //     bool canBidAboveIncrease;
                ],
                MaxWinners// uint32 maxWinners
            ];

            let tx = await AuctionFactory.connect(owner).produceAuction(...p);

            const rc = await tx.wait(); // 0ms, as tx is already confirmed
            const event = rc.events.find(event => event.event === 'InstanceCreated');
            const [instance,] = event.args;
            expect(instance).not.to.be.eq(ZERO_ADDRESS);
            
            let auctionInstance = await ethers.getContractAt("MockAuction",instance);

            let tmp2Bid = startingPrice.add(increasePrice);

            await erc20.mint(alice.address, tmp2Bid);
            await erc20.connect(alice).approve(AuctionFactory.address, tmp2Bid);
            await auctionInstance.connect(alice).bid(tmp2Bid);

            tmp2Bid = startingPrice.add(increasePrice.mul(TWO));
            await erc20.mint(bob.address, tmp2Bid);
            await erc20.connect(bob).approve(AuctionFactory.address, tmp2Bid);
            await auctionInstance.connect(bob).bid(tmp2Bid);
            
            // try to claim before auction end
            await expect(
                auctionInstance.connect(bob).claim()
            ).to.be.revertedWith('AuctionNotFinished()');

        });

        it("shouldn't let non-winners claim the prize", async() => {
            const MaxWinners = 2;
            let currentTime = await mockUseful.currentBlockTimestamp();
            let startingPrice = ONE_ETH;
            let increasePrice = BigNumber.from('1000000000'); //gwei
            p = [
                erc20.address,          // address token,
                false,                  // bool cancelable,
                currentTime,            // uint64 startTime,
                currentTime.add(86400), // uint64 endTime,
                startingPrice,          // uint256 startingPrice,
                [
                   increasePrice,// can't increase by over half the range
                   TEN,             // increase after this many bids
                   true            //     bool canBidAboveIncrease;
                ],
                MaxWinners// uint32 maxWinners
            ];

            let tx = await AuctionFactory.connect(owner).produceAuction(...p);

            const rc = await tx.wait(); // 0ms, as tx is already confirmed
            const event = rc.events.find(event => event.event === 'InstanceCreated');
            const [instance,] = event.args;
            expect(instance).not.to.be.eq(ZERO_ADDRESS);
            
            let auctionInstance = await ethers.getContractAt("MockAuction",instance);

            let tmp2Bid = startingPrice.add(increasePrice);

            await erc20.mint(alice.address, tmp2Bid);
            await erc20.connect(alice).approve(AuctionFactory.address, tmp2Bid);
            await auctionInstance.connect(alice).bid(tmp2Bid);

            tmp2Bid = startingPrice.add(increasePrice.mul(TWO));
            await erc20.mint(bob.address, tmp2Bid);
            await erc20.connect(bob).approve(AuctionFactory.address, tmp2Bid);
            await auctionInstance.connect(bob).bid(tmp2Bid);
            
            //pass 86400 seconds
            await network.provider.send("evm_increaseTime", [parseInt(86400)]);
            await network.provider.send("evm_mine"); // this one will have 02:00 PM as its timestamp

            await expect(
                auctionInstance.connect(charlie).claim()
            ).to.be.revertedWith('NotWinning()');
        });

        it("shouldn't let winning bidders bid again", async() => {
            const MaxWinners = 2;
            let currentTime = await mockUseful.currentBlockTimestamp();
            let startingPrice = ONE_ETH;
            let increasePrice = BigNumber.from('1000000000'); //gwei
            p = [
                erc20.address,          // address token,
                false,                  // bool cancelable,
                currentTime,            // uint64 startTime,
                currentTime.add(86400), // uint64 endTime,
                startingPrice,          // uint256 startingPrice,
                [
                   increasePrice,// can't increase by over half the range
                   TEN,             // increase after this many bids
                   true            //     bool canBidAboveIncrease;
                ],
                MaxWinners// uint32 maxWinners
            ];

            let tx = await AuctionFactory.connect(owner).produceAuction(...p);

            const rc = await tx.wait(); // 0ms, as tx is already confirmed
            const event = rc.events.find(event => event.event === 'InstanceCreated');
            const [instance,] = event.args;
            expect(instance).not.to.be.eq(ZERO_ADDRESS);
            
            let auctionInstance = await ethers.getContractAt("MockAuction",instance);

            let tmp2Bid = startingPrice.add(increasePrice);

            await erc20.mint(alice.address, tmp2Bid);
            await erc20.connect(alice).approve(AuctionFactory.address, tmp2Bid);
            await auctionInstance.connect(alice).bid(tmp2Bid);

            tmp2Bid = startingPrice.add(increasePrice.mul(TWO));
            await erc20.mint(alice.address, tmp2Bid);
            await erc20.connect(alice).approve(AuctionFactory.address, tmp2Bid);

            await expect(
                auctionInstance.connect(alice).bid(tmp2Bid)
            ).to.emit(auctionInstance, 'AlreadyWinning');

        });

    });
});