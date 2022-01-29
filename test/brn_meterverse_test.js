const BrnMeterverse = artifacts.require('BrnMeterverse');

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
        it("can enable token transfers", async() => {
            const amount = 10;
            const initialOwnerBalance = await btnMeterverse.balanceOf(owner);
            console.log("Initial Owner Balance",initialOwnerBalance);
            const result = await brnMeterverse.transfer(alice, amount, { from: owner });

            const aliceBalance = await brnMeterverse.balanceOf(alice);
            const newOwnerBalance = await btnMeterverse.balanceOf(owner);

            assert(result.receipt.status, true);
            assert.equal(aliceBalance, 10,"Meterverse is deposited successfully into other wallet address");
            assert(initialOwnerBalance < newOwnerBalance,"Owner balance reduces upon sending some metervers to another address");
        });
    });


});