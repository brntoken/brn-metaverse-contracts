const bnbTokenContract = artifacts.require("MockBNB");
const MockPriceFeedContract = artifacts.require("MockV3Aggregator");

module.exports = function(deployer, network) {
    if (network == "development" || network == "test" || network == "ganache") {
        let decimals = 8
        let bnbPriceValue = 400 * 10 ** decimals
        deployer.deploy(bnbTokenContract);
        deployer.deploy(MockPriceFeedContract, decimals, bnbPriceValue);
    }
}