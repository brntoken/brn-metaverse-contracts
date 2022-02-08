const BrnMeterverse = artifacts.require('BrnMeterverse');
const PresaleContract = artifacts.require("Presale");
const web3 = require('web3');

module.exports = async function(deployer) {
    let token = await BrnMeterverse.deployed()
    let presale = await PresaleContract.deployed()
    await token.transfer(presale.address, web3.utils.toWei("50000000")) // Sent 50 000,000 BRN to the presale contract
};