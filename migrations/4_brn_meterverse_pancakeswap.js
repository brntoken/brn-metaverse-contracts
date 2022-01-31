const BrnPancakeSwapV2Integration = artifacts.require('BrnPancakeSwapV2Integration');
const BrnMeterverse = artifacts.require('BrnMeterverse');

module.exports = async(deployer) => {
    const meterverse = await BrnMeterverse.deployed();
    await deployer.deploy(BrnPancakeSwapV2Integration, meterverse.address);
}