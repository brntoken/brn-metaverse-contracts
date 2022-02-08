const BrnMeterverse = artifacts.require('BrnMeterverse');
const web3 = require('web3');
const assert = require('assert');

contract.skip('BrnMeterverse', (accounts) => {
    let brnMeterverse;
    let name;
    let symbol;
    let decimals;
    let totalSupply;

    beforeEach(async() => {
        brnMeterverse = await BrnMeterverse.deployed();
        [owner, alice, bob, inverster1, inverster2] = accounts;
        name = "Brn Meterverse";
        symbol = "BRN";
        decimals = 18;
        totalSupply = 1000000000;
    });

    describe("Meterverse Deployment", () => {
        it("BRN Meterverse gets deployed successfully", async() => {
            assert(brnMeterverse, "BRN Meterverse deployed successfully");
        });
    });

    describe("BRN Meterverse Transfers", () => {
        it("can successfuly enable BRN transfers from one address to another", async() => {
            const amount = 1000000;
            const initialOwnerBalance = await brnMeterverse.balanceOf(owner);
            const result = await brnMeterverse.transfer(alice, amount, { from: owner });

            const aliceBalance = await brnMeterverse.balanceOf(alice);
            const newOwnerBalance = await brnMeterverse.balanceOf(owner);

            assert(result.receipt.status, true);
            assert.equal(aliceBalance, 1000000, "Meterverse is deposited successfully into other wallet address");
            assert(initialOwnerBalance < newOwnerBalance, "Owner balance reduces upon sending some meterverse tokens to another address");
            assert(result.logs[0].args.from, owner, "Sender addres is captured correctly");
            assert(result.logs[0].args.to, alice, "Receiver Address is captured correcty");
            assert(result.logs[0].args.value, 1000000, "BRN amount transfered captured correctly");
        });

        it("can successfuly enable a BRN holder to approve allowance to another address", async() => {
            const allowanceAmount = 1000;

            const currentOwnerAllowanceToAlice = await brnMeterverse.allowance(owner, alice);
            const result = await brnMeterverse.approve(alice, allowanceAmount, { from: owner });

            const newOwnerAllowanceToAlice = await brnMeterverse.allowance(owner, alice);

            assert(result.receipt.status, true);
            assert(newOwnerAllowanceToAlice > currentOwnerAllowanceToAlice, "Alice\'s allowance approval from the BRN holder is a success");
            //test approval event
            assert(result.logs[0].args.owner, owner, "Approving address is captured correctly");
            assert(result.logs[0].args.spender, alice, "Spender Address is captured correcty");
            assert(result.logs[0].args.value, allowanceAmount);
        });

        it("can fetch the allowance of an account holding BRN", async() => {
            const aliceOwnerBRNAllowance = await brnMeterverse.allowance(owner, alice);
            assert.equal(aliceOwnerBRNAllowance.toNumber(), 1000);
        });

        it("can successfuly enable BRN transfers from one address to another specifying the sender, recipient and amount", async() => {
            const amount = 1000000;
            const initialOwnerBalance = await brnMeterverse.balanceOf(owner);
            const result = await brnMeterverse.transferFrom(owner, bob, amount, { from: owner });

            const bobBalance = await brnMeterverse.balanceOf(bob);
            const newOwnerBalance = await brnMeterverse.balanceOf(owner);

            assert(result.receipt.status, true);
            assert.equal(bobBalance, 1000000, "Meterverse is deposited successfully into other wallet address");
            assert(initialOwnerBalance < newOwnerBalance, "Owner balance reduces upon sending some meterverse tokens to another address");
            assert(result.logs[0].args.from, owner, "Sender addres is captured correctly");
            assert(result.logs[0].args.to, bob, "Receiver Address is captured correcty");
            assert(result.logs[0].args.value, 1000000, "BRN amount transfered captured correctly");
        });

        it("can successfuly enable a BRN holder to increase the allowance issued to another address to be spent on their behalf", async() => {
            const allowanceToBeAdded = 2000;
            const currentOwnerAllowanceToAlice = await brnMeterverse.allowance(owner, alice);

            const result = await brnMeterverse.increaseAllowance(alice, allowanceToBeAdded, { from: owner });
            const newAllowance = allowanceToBeAdded + currentOwnerAllowanceToAlice.toNumber();

            const newAllocatedBrnAllowanceToAlice = await brnMeterverse.allowance(owner, alice);

            assert(result.receipt.status, true);
            assert.equal(newAllowance, newAllocatedBrnAllowanceToAlice.toNumber(), "BRN allowance to spender successfully increased by BRN holder");
            //test Approval event
            assert(result.logs[0].args.owner, owner, "Approving address is captured correctly");
            assert(result.logs[0].args.spender, alice, "Spender Address is captured correcty");
            assert(result.logs[0].args.value, allowanceToBeAdded);
        });

        it("can successfuly enable a BRN holder to descrease the allowance issued to another address to be spent on their behalf", async() => {
            const allowanceToBeReduced = 2000;
            const currentOwnerAllowanceToAlice = await brnMeterverse.allowance(owner, alice);

            const result = await brnMeterverse.decreaseAllowance(alice, allowanceToBeReduced, { from: owner });
            const newAllowance = currentOwnerAllowanceToAlice.toNumber() - allowanceToBeReduced;

            const allowanceBalance = await brnMeterverse.allowance(owner, alice);

            assert(result.receipt.status, true);
            assert.equal(newAllowance, 1000, "BRN allowance to spender successfully deacreased by BRN holder");
            assert.equal(allowanceBalance.toNumber(), 1000);
            //test Approval event
            assert(result.logs[0].args.owner, owner, "Approving address is captured correctly");
            assert(result.logs[0].args.spender, alice, "Spender Address is captured correcty");
            assert(result.logs[0].args.value, allowanceToBeReduced);
        });

        it("can successfuly enable the BRN Meterverse contract owner to mint more BRN and increase BRN suppply", async() => {
            const newSupplyToBeAdded = 1000000000;
            const currentBRNTotalSupply = await brnMeterverse.totalSupply();
            const currentOwnerBRNBalance = await brnMeterverse.balanceOf(owner);
            const result = await brnMeterverse.mint(newSupplyToBeAdded, { from: owner });

            const newTotalSupply = await brnMeterverse.totalSupply();
            const newOwnerBalance = await brnMeterverse.balanceOf(owner);

            const totalOwnerBalanceAfterMinting = newSupplyToBeAdded + currentOwnerBRNBalance.toNumber();

            const newSupply = newSupplyToBeAdded + currentBRNTotalSupply.toNumber();


            assert(result.receipt.status, true);
            assert.equal(newSupply, newTotalSupply, "BRN total Supply increased successfully after mint is triggered by contract owner");
            assert.equal(totalOwnerBalanceAfterMinting, newOwnerBalance.toNumber(), "BRN owner balance is increased after minting");
        });

        it("can successfully enable the contract owner to burn some amount of BRN to reduce BRN total supply", async() => {
            const amountToBurn = 1000000;
            const currentBRNTotalSupply = await brnMeterverse.totalSupply();
            const currentOwnerBRNBalance = await brnMeterverse.balanceOf(owner);

            const result = await brnMeterverse.burn(owner, amountToBurn, { from: owner });

            const newBRNTotalSupplyAfterBurn = await brnMeterverse.totalSupply();
            const newOwnerBRNBalanceAfterBurn = await brnMeterverse.balanceOf(owner);

            const newCalculatedBRNTotalSupply = newBRNTotalSupplyAfterBurn.toNumber() - amountToBurn;

            const newCalculatedOwnerBRNBalance = newOwnerBRNBalanceAfterBurn.toNumber() - amountToBurn;


            assert(result.receipt.status, true);
            assert(currentBRNTotalSupply != newBRNTotalSupplyAfterBurn, "BRN total supply successfully reduces after a burn is triggered by Meterverse owner");
            assert(newCalculatedBRNTotalSupply < currentBRNTotalSupply, "BRN total supply successfully reduces after a burn");
            assert(newCalculatedOwnerBRNBalance < currentOwnerBRNBalance.toNumber(), "BRN account owner balance successfully reduces after a burn from this account");
        });

        it("can successfully fetch BRN total supply", async() => {
            const BRNMeterverse = await BrnMeterverse.new();
            const BRNTotalSupply = await BRNMeterverse.totalSupply();

            assert.equal(BRNTotalSupply, totalSupply, "Successfully displays BRN Meterverse total token supply");
        });

        it("can successfully fetch BRN name", async() => {
            const BRNName = await brnMeterverse.name();
            assert.equal(BRNName, name, "Successfully displays Meterverse name");
        });

        it("can successfully fetch BRN symbol", async() => {
            const BRNSymbol = await brnMeterverse.symbol();
            assert.equal(BRNSymbol, symbol, "Successfully displays Meterverse symbol");
        });

        it("can successfully fetch the balance of a BRN holder", async() => {
            const BRNMeterverse = await BrnMeterverse.new();
            const ownerBalance = await BRNMeterverse.balanceOf(owner);

            assert(ownerBalance.toNumber(), 1000000000, "Successfully displays BRN holder balance");
        });

        it("can successfully fetch the address of the owner of the Metervse used in deployment", async() => {
            const BRNOwnerAddress = await brnMeterverse.getOwner();
            assert(BRNOwnerAddress, owner, "Successfully display BRN owner address used in deployment");
        });

        it("can successfully fetch the total number of decimals of the BRN Meterverse token", async() => {
            const BRNDecimals = await brnMeterverse.decimals();
            assert.equal(BRNDecimals, decimals, "Successfully display the total number of decimals for the BRN Meterverse token");
        });

    });

    describe("BRN Meterverse Securiry Restrictions", () => {
        it("can successfully enable the contract owner to pause the Meterverse", async() => {
            const result = await brnMeterverse.pause({ from: owner });

            assert(result.receipt.status, true, "Meterverse Paused Successfully");
            assert.equal(result.logs[0].args.account, owner, "This owner address is the one that actually called the pause function");
        });

        it("cane successfully enable the contract owner to unpause the Meterverse", async() => {
            const result = await brnMeterverse.unpause({ from: owner });

            assert(result.receipt.status, true, "Meterverse Unpaused Successfully");
            assert.equal(result.logs[0].args.account, owner, "This owner address is the one that actually called the unpaused function");
        });

        it("can only allow the Metervese contract owner to pause the Meterverse and not any other user address that is not the owner", async() => {
            try {
                const result = await brnMeterverse.pause({ from: alice }); //use a diffferent account other than the owner account

            } catch (error) {
                assert(error.message.includes("Ownable: caller is not the owner"));
                return;
            }
            assert(false);
        });

        it("can only allow the Metervese contract owner to unpause the Meterverse", async() => {
            try {
                const result = await brnMeterverse.unpause({ from: bob }); //use a diffferent account other than the owner account

            } catch (error) {
                assert(error.message.includes("Ownable: caller is not the owner"));
                return;
            }
            assert(false);
        });

        it("can only allow the Meterverse owner to mint BRN and increase total supply and not just any other user address", async() => {
            try {
                const mintAmount = 1000;
                const result = await brnMeterverse.mint(mintAmount, { from: bob }); //use a diffferent account other than the owner 
            } catch (error) {
                assert(error.message.includes("Ownable: caller is not the owner"));
                return;
            }
            assert(false);
        });

        it("can only allow the Meterverse owner to burn BRN and thus reducing total supply and not just any other user address", async() => {
            try {
                const burnAmount = 1000;
                const result = await brnMeterverse.burn(alice, burnAmount, { from: bob }); //use a diffferent account other than the owner 
            } catch (error) {
                assert(error.message.includes("Ownable: caller is not the owner"));
                return;
            }
            assert(false);
        });
    });

});