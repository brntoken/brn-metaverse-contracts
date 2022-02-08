const bnbTokenContract = artifacts.require("MockBNB");
const MockPriceFeedContract = artifacts.require("MockV3Aggregator");

module.exports = function(deployer, network) {
    if (network == "development" || network == "test") {
        let decimals = 18
        let bnbPriceValue = 48000 * 10 ** decimals
        deployer.deploy(bnbTokenContract);

        deployer.deploy(MockPriceFeedContract, decimals, bnbPriceValue);
    }
}