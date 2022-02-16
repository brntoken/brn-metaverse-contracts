const BrnMetaverse = artifacts.require('BrnMetaverse');

module.exports = async function (deployer) {
    const pancakeSwapRouterAddress = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
    const marketingWalletAddress = '0x07871De755d9D922Cb1735A9F2418cBe9F1808EE';
    const liquidityFee = 600;
    const txFee = 200;
    const _lpBuyFee = 100;
    const _lpSellFee = 3000;
    await deployer.deploy(BrnMetaverse, pancakeSwapRouterAddress, marketingWalletAddress,txFee, liquidityFee,_lpBuyFee,_lpSellFee);
};
