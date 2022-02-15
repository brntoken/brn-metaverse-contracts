const BrnMetaverse = artifacts.require('BrnMetaverse');
const PresaleContract = artifacts.require("Presale");
const web3 = require('web3');

module.exports = async function(deployer, network, accounts) {
    if (network == "bsc") {
        let token = await BrnMetaverse.deployed()
        let presale = await PresaleContract.deployed()
        let partnership;
        let marketing;
        let staff;
        let burn;
        let holders;
        await token.transfer(presale.address, web3.utils.toWei("50000000")) // Sent 50 000,000 BRN to the presale contract
    } else {
        let token = await BrnMetaverse.deployed()
        let presale = await PresaleContract.deployed()

        let totalSupply = (await token.totalSupply()).toString()
        totalSupply = web3.utils.fromWei(totalSupply, "ether")

        let partnership = accounts[1];
        let marketing = accounts[2];
        let staff = accounts[3];
        let burn = accounts[4];
        let holders = accounts[5];
        let airdrop = accounts[6];

        let presaleAmt = totalSupply * 0.05;
        let partnershipAmt = totalSupply * 0.10;
        let marketingAmt = totalSupply * 0.45;
        let staffAmt = totalSupply * 0.15;
        let burnAmt = totalSupply * 0.10;
        let holdersAmt = totalSupply * 0.02;
        let airdropAmt = totalSupply * 0.13;
        await token.transfer(presale.address, web3.utils.toWei(presaleAmt.toString(), "ether")) // Sent 50 000,000 BRN to the presale contract
        await token.transfer(partnership, web3.utils.toWei(partnershipAmt.toString(), "ether"))
        await token.transfer(marketing, web3.utils.toWei(marketingAmt.toString(), "ether"))
        await token.transfer(staff, web3.utils.toWei(staffAmt.toString(), "ether"))
        await token.transfer(burn, web3.utils.toWei(burnAmt.toString(), "ether"))
        await token.transfer(holders, web3.utils.toWei(holdersAmt.toString(), "ether"))
        await token.transfer(airdrop, web3.utils.toWei(airdropAmt.toString(), "ether"))
    }
};