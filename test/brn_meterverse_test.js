const BrnMeterverse = artifacts.require('BrnMeterverse');
const web3 = require('web3');

contract('BrnMeterverse',(accounts) =>{
    let brnMeterverse;

    beforeEach(async() => {
        brnMeterverse = await BrnMeterverse.deployed();
        [owner, alice, bob, inverster1, inverster2] = accounts;
    });

    describe("Meterverse Deployment", () => {
        it("BRN Meterverse gets deployed successfully", async() => {
            assert(brnMeterverse,"BRN Meterverse deployed successfully");
        });
    });

    describe("BRN Meterverse Transfers", () => {
        it("can enable meterverse token transfers", async() => {
            const amount = 10;
            const initialOwnerBalance = await brnMeterverse.balanceOf(owner);
            console.log("Initial Owner Balance",initialOwnerBalance.toNumber());
            const result = await brnMeterverse.transfer(alice, amount, { from: owner });

            const aliceBalance = await brnMeterverse.balanceOf(alice);
            const newOwnerBalance = await brnMeterverse.balanceOf(owner);

            assert(result.receipt.status, true);
            assert.equal(aliceBalance, 10,"Meterverse is deposited successfully into other wallet address");
            assert(initialOwnerBalance < newOwnerBalance,"Owner balance reduces upon sending some meterverse tokens to another address");
            assert(result.logs[0].args.from, owner,"Sender addres is captured correctly");
            assert(result.logs[0].args.to, alice,"Receiver Address captured correcty");
            assert(result.logs[0].args.value, 10,"BRN amount transfered captured correctly");
        });
    });


});