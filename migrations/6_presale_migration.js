const BrnMeterverse = artifacts.require('BrnMeterverse');
const MockPriceFeedContract = artifacts.require("MockV3Aggregator");
const PresaleContract = artifacts.require("Presale");

module.exports = async function(deployer, network, accounts) {
    if (network == "development" || network == "test") {
        const brnToken = await BrnMeterverse.deployed();
        const priceFeed = await MockPriceFeedContract.deployed();
        await deployer.deploy(PresaleContract, priceFeed.address, brnToken.address, accounts[0], 50000000);
    } else if (network == "bsc_testnet") {
        const brnToken = await BrnMeterverse.deployed();
        await deployer.deploy(PresaleContract, "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526", brnToken.address, accounts[0], 50000000);
    } else if (network == "bsc") {
        const brnToken = await BrnMeterverse.deployed();
        await deployer.deploy(PresaleContract, "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE", brnToken.address, accounts[0], 50000000);
    }
}