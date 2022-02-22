const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();
const MNEMONIC = process.env.MNEMONIC;
const BSCSCAN_APIKEY = process.env.BSCSCAN_APIKEY;

module.exports = {
    plugins: [
        'truffle-plugin-verify'
    ],
    api_keys: {
        bscscan: BSCSCAN_APIKEY
    },
    networks: {

        ganache: {
            host: "127.0.0.1", // Localhost (default: none)
            port: 7545, // Standard Ganache port (default: none)
            network_id: "5777", // Ganache network
        },

        ropsten: {
            provider: () => new HDWalletProvider(MNEMONIC, `https://ropsten.infura.io/v3/YOUR-PROJECT-ID`),
            network_id: 3, // Ropsten's id
            gas: 5500000, // Ropsten has a lower block limit than mainnet
            confirmations: 2, // # of confs to wait between deployments. (default: 0)
            timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
            skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
            networkCheckTimeout: 999999,
        },

        bsc_testnet: {
            provider: () => new HDWalletProvider(MNEMONIC, `https://data-seed-prebsc-1-s1.binance.org:8545/`),
            network_id: 97,
            gas: 5500000,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true,
            websocket:false,
            networkCheckTimeout: 999999, //1000000000
            from:'0x36017AAdeF5a421de9bC6E6E58bF10B3d6b92882'
        },
        bsc: {
            provider: () => new HDWalletProvider(MNEMONIC, `https://bsc-dataseed.binance.org/`),
            network_id: 56,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true,
            networkCheckTimeout: 999999,
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "^0.8.0", // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            settings: { // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200
                },
                //evmVersion: "istanbul"
            }
        }
    },

    // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
    //
    // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
    // those previously migrated contracts available in the .db directory, you will need to run the following:
    // $ truffle migrate --reset --compile-all

    db: {
        enabled: false
    }
};