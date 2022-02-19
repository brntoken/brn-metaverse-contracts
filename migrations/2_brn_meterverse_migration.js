const BrnMetaverse = artifacts.require('BrnMetaverse');

module.exports = async function (deployer, network, accounts) {
    const pancakeSwapRouterAddress = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
    const marketingWalletAddress = '0x07871De755d9D922Cb1735A9F2418cBe9F1808EE';
    const liquidityFee = 6;
    const txFee = 5;
    const _lpBuyFee = 5;
    const _lpSellFee = 5;
    if (network == 'bsc_testnet'){
        await deployer.deploy(BrnMetaverse, pancakeSwapRouterAddress, accounts[0], txFee, liquidityFee, _lpBuyFee, _lpSellFee);
    }else{
        await deployer.deploy(BrnMetaverse, pancakeSwapRouterAddress, marketingWalletAddress, txFee, liquidityFee, _lpBuyFee, _lpSellFee);
    }
};
