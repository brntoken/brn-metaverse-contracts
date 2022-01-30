const brn_meterverse_presale_test = artifacts.require("brn_meterverse_presale_test");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("brn_meterverse_presale_test", function (/* accounts */) {
  it("should assert true", async function () {
    await brn_meterverse_presale_test.deployed();
    return assert.isTrue(true);
  });
});
