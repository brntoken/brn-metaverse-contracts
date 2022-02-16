const BrnMetaverse = artifacts.require('BrnMetaverse');

module.exports = function (deployer, network, accounts) {
    const pancakeSwapRouterAddress = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
    const marketingWalletAddress = accounts[0];
    const liquidityFee = 600;
    const txFee = 200;
    const _lpBuyFee = 100;
    const _lpSellFee = 3000;
    deployer.deploy(BrnMetaverse, pancakeSwapRouterAddress, marketingWalletAddress,txFee, liquidityFee,_lpBuyFee,_lpSellFee);
};
