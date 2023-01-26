const BigNumber = require('bignumber.js');
const truffleAssert = require('truffle-assertions');

const Auction = artifacts.require("Auction");
const AuctionFactory = artifacts.require("AuctionFactory");
const ERC20Mintable = artifacts.require("ERC20Mintable");
const helper = require("../helpers/truffleTestHelper");

contract('Auction', (accounts) => {
    
    // Setup accounts.
    const accountOne = accounts[0];
    const accountTwo = accounts[1];
    const accountThree = accounts[2];
    const accountFourth = accounts[3];
    const accountFive = accounts[4];
    
    const zeroAddress = "0x0000000000000000000000000000000000000000";
    
    const noneExistTokenID = '99999999';
    const oneToken = "1000000000000000000";
    const twoToken = "2000000000000000000";
    const oneToken07 = "700000000000000000";
    const oneToken05 = "500000000000000000";    
    const oneToken03 = "300000000000000000";    
    var AuctionInstance, AuctionFactoryInstance, ERC20MintableInstance;
    
    let tmpTr;
    
    before(async () => {
        AuctionFactoryInstance = await AuctionFactory.new({ from: accountFive });
    });

    
    it('should create via factory produce', async () => {

    });
});