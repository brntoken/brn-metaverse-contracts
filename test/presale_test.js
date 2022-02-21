const Token = artifacts.require("BrnMetaverse");
const PreSale = artifacts.require("PreSale");
const truffleAssert = require("truffle-assertions")

const Web3 = require("web3")
const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"))

const timeTravel = function(time) {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [time], // 86400 is the number of seconds in a day
            id: new Date().getTime()
        }, (err, result) => {
            if (err) { return reject(err) }
            return resolve(result)
        })
    })
}

contract("PreSale", accounts => {
    it("should get accurate price real time", async() => {
        let presale = await PreSale.deployed();

        let priceFeed = await presale.getPrice()
        let price = priceFeed[0].toNumber()
        let decimals = priceFeed[1].toNumber()
        assert.equal(400, price / 10 ** decimals)

        let coinToUSD = await presale.coinToUSD(Web3.utils.toWei("0.5"))
        let usdValue = Web3.utils.fromWei(coinToUSD.toString())
        assert.equal(200, usdValue)
    })
    it("should not allow users buy token before presale starts", async() => {
        let presale = await PreSale.deployed();

        let amount = Web3.utils.toWei("0.5")

        await truffleAssert.reverts(presale.buyTokens(accounts[1], { from: accounts[1], value: amount }))
        await truffleAssert.reverts(presale.buyTokens(accounts[2], { from: accounts[2], value: amount }))

        assert.equal(0, (await presale.phase1Balance(accounts[1])).toNumber())
        assert.equal(0, (await presale.phase1Balance(accounts[2])).toNumber())
    })
    it("should allow only owner to start presale", async() => {
        let presale = await PreSale.deployed();

        await truffleAssert.reverts(presale.startNextPhase({ from: accounts[1] }))
        await truffleAssert.passes(presale.startNextPhase({ from: accounts[0] }))
    })
    it("should allow users buy token in the presale", async() => {
        let presale = await PreSale.deployed();

        let amount = Web3.utils.toWei("0.5")
        await truffleAssert.passes(presale.buyTokens(accounts[1], { from: accounts[1], value: amount }))

        assert.equal(2000, (await presale.phase1Balance(accounts[1])).toString())
    })
    it("should allow users withdraw token after first phase of presale", async() => {
        let presale = await PreSale.deployed();

        await truffleAssert.reverts(presale.withdrawToken({ from: accounts[1] }))

        await timeTravel(14515200); // travel 24 weeks - 7*24*86400 = 14515200
        await truffleAssert.passes(presale.withdrawToken({ from: accounts[1] }))

        assert.equal(0, (await presale.phase1Balance(accounts[1])).toNumber())
    })
})