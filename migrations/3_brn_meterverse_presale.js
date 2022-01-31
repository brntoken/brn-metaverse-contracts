const BrnMeterversePreSale = artifacts.require('BrnMeterversePreSale');
const BrnMeterverse = artifacts.require('BrnMeterverse');

const partnershipFundAddress = '0x107a8f87e11186bDc52Bd3e268C2f410b8f7af92';
const airdropFundAddress = '0xf2f34F0Eb472135BBF1E07d9A96824E933256A78';
const marketingFundAddress = '0xbaa1291DD0355F7BA0B84e221f7FD854b1FAE2B3';
const staffFundAddress = '0xAFb1e491B5a3821A3362aBA9a02744d2EBFd9Ac6';
const holdersFundAddress = '0x5515Bd4FD97681b724ce340a6AEf704e80045339';
const burnFundAddress = '0x014a7c785ccfb0d8eDAF6Ec060C3452D1C4a37E4';

module.exports = async(deployer) => {
    const meterverse = await BrnMeterverse.deployed();
    console.log("Mterverse Address",meterverse.address);
    
    await deployer.deploy(BrnMeterversePreSale, 
        meterverse.address ,
        partnershipFundAddress,
        airdropFundAddress,
        marketingFundAddress,
        staffFundAddress,
        burnFundAddress,
        holdersFundAddress
    );
}