const BrnMeterverse = artifacts.require('BrnMeterverse');
const PresaleContract = artifacts.require("Presale");

module.exports = async function(deployer) {
    let token = await BrnMeterverse.deployed()
    await token.transfer(PresaleContract.address, 50000000)
};