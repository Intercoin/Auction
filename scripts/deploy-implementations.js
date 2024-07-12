const fs = require('fs');
//const HDWalletProvider = require('truffle-hdwallet-provider');

function get_data(_message) {
    return new Promise(function(resolve, reject) {
        fs.readFile('./scripts/arguments.json', (err, data) => {
            if (err) {
				
                if (err.code == 'ENOENT' && err.syscall == 'open' && err.errno == -4058) {
                    fs.writeFile('./scripts/arguments.json', "", (err2) => {
                        if (err2) throw err2;
                        resolve();
                    });
                    data = ""
                } else {
                    throw err;
                }
            }
    
            resolve(data);
        });
    });
}

function write_data(_message) {
    return new Promise(function(resolve, reject) {
        fs.writeFile('./scripts/arguments.json', _message, (err) => {
            if (err) throw err;
            console.log('Data written to file');
            resolve();
        });
    });
}

async function main() {
	var data = await get_data();

    var data_object_root = JSON.parse(data);
	var data_object = {};
	if (typeof data_object_root[hre.network.name] === 'undefined') {
        data_object.time_created = Date.now()
    } else {
        data_object = data_object_root[hre.network.name];
    }
	//----------------

    var signers = await ethers.getSigners();
    const provider = ethers.provider;
    var deployer,
        deployer_auxiliary,
        deployer_releasemanager,
        deployer_auction;
    if (signers.length == 1) {
        
        deployer = signers[0];
        deployer_auxiliary = signers[0];
        deployer_releasemanager = signers[0];
        deployer_auction = signers[0];
    } else {
        [
            deployer,
            deployer_auxiliary,
            deployer_releasemanager,
            deployer_auction
        ] = signers;
    }
	
    const RELEASE_MANAGER = process.env.RELEASE_MANAGER;
    
	console.log(
		"Deploying contracts with the account:",
		deployer_auxiliary.address
	);

	// var options = {
	// 	//gasPrice: ethers.utils.parseUnits('50', 'gwei'), 
	// 	gasLimit: 10e6
	// };

    const deployerBalanceBefore = await provider.getBalance(deployer_auxiliary.address);
    console.log("Account balance:", (deployerBalanceBefore).toString());

	const AuctionF = await ethers.getContractFactory("Auction");
    const AuctionNFTF = await ethers.getContractFactory("AuctionNFT");
    const AuctionCommunityF = await ethers.getContractFactory("AuctionCommunity");
    const AuctionSubscriptionF = await ethers.getContractFactory("AuctionSubscription");

	let implementationAuction = await AuctionF.connect(deployer_auxiliary).deploy();
    let implementationAuctionNFT = await AuctionNFTF.connect(deployer_auxiliary).deploy();
    let implementationAuctionCommunity = await AuctionCommunityF.connect(deployer_auxiliary).deploy();
    let implementationAuctionSubscription = await AuctionSubscriptionF.connect(deployer_auxiliary).deploy();
    
    await implementationAuction.waitForDeployment();
    await implementationAuctionNFT.waitForDeployment();
    await implementationAuctionCommunity.waitForDeployment();
    await implementationAuctionSubscription.waitForDeployment();

	console.log("Implementations:");
	console.log("  implementationAuction deployed at:               ", implementationAuction.target);
    console.log("  implementationAuctionNFT deployed at:            ", implementationAuctionNFT.target);
    console.log("  implementationAuctionCommunity deployed at:      ", implementationAuctionCommunity.target);
    console.log("  implementationAuctionSubscription deployed at:   ", implementationAuctionSubscription.target);

	data_object.implementationAuction 	            = implementationAuction.target;
    data_object.implementationAuctionNFT 	        = implementationAuctionNFT.target;
    data_object.implementationAuctionCommunity      = implementationAuctionCommunity.target;
    data_object.implementationAuctionSubscription   = implementationAuctionSubscription.target;
    data_object.releaseManager                      = RELEASE_MANAGER;

	const deployerBalanceAfter = await provider.getBalance(deployer_auxiliary.address);
	console.log("Spent:", ethers.formatEther(deployerBalanceBefore - deployerBalanceAfter));
	console.log("gasPrice:", ethers.formatUnits((await network.provider.send("eth_gasPrice")), "gwei")," gwei");

	//---
	const ts_updated = Date.now();
    data_object.time_updated = ts_updated;
    data_object_root[`${hre.network.name}`] = data_object;
    data_object_root.time_updated = ts_updated;
    let data_to_write = JSON.stringify(data_object_root, null, 2);
	console.log(data_to_write);
    await write_data(data_to_write);

    console.log('verifying');
    if (hre.network.name == 'hardhat') {
        console.log('skip for forks');
    } else {
        await hre.run("verify:verify", {address: data_object.implementationAuction, constructorArguments: []});
        await hre.run("verify:verify", {address: data_object.implementationAuctionNFT, constructorArguments: []});
        await hre.run("verify:verify", {address: data_object.implementationAuctionCommunity, constructorArguments: []});
        await hre.run("verify:verify", {address: data_object.implementationAuctionSubscription, constructorArguments: []});
    }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });