const BrnMetaverse = artifacts.require('BrnMetaverse');

module.exports = function (deployer) {
    const pancakeSwapRouterAddress = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
    deployer.deploy(BrnMetaverse,pancakeSwapRouterAddress);
};
