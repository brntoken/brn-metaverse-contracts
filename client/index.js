var user;
var tokenAddress = "0xFc679B06cd040b484EeC917779BAaEbc1678b285";
var presaleAddress = "0x1953AD3cfDd7E9784e055FDa8e91ebB439c46363";
var accounts;
var walletDisconnect;
var tokenSymbol;

// Unpkg imports
var web3;

const Web3Modal = window.Web3Modal.default;
const WalletConnectProvider = window.WalletConnectProvider.default;
const evmChains = window.evmChains;

// Web3modal instance
let web3Modal

// Chosen wallet provider given by the dialog window
let provider;


/**
 * Setup the orchestra
 */
function init() {
    walletDisconnect = true;

    console.log("Initializing");
    console.log("WalletConnectProvider is", WalletConnectProvider);
    console.log("window.web3 is", window.web3, "window.ethereum is", window.ethereum);

    // Tell Web3modal what providers we have available.
    // Built-in web browser provider (only one can exist as a time)
    // like MetaMask, Brave or Opera is added automatically by Web3modal
    const providerOptions = {
        walletconnect: {
            package: WalletConnectProvider,
            options: {
                rpc: {
                    5777: "127.0.0.1:7545",
                },
                chainId: 5777,
            }
        }
    };

    web3Modal = new Web3Modal({
        cacheProvider: true, // optional
        providerOptions, // required
        disableInjectedProvider: false, // optional. For MetaMask / Brave / Opera.
    });

    console.log("Web3Modal instance is", web3Modal);
}


/**
 * Kick in the UI action after Web3modal dialog has chosen a provider
 */
async function fetchAccountData() {
    // Get a Web3 instance for the wallet
    web3 = new Web3(provider);

    console.log("Web3 instance is", web3);

    // Get list of accounts of the connected wallet
    accounts = await web3.eth.getAccounts();

    console.log(accounts)

    if (accounts.length > 0) {
        // Get connected chain id from Ethereum node
        const chainId = await web3.eth.getChainId();
        // Load chain information over an HTTP API
        try {
            const chainData = evmChains.getChain(chainId);
        } catch {
            console.log("development blockchain")
        }


        // if (chainId != 4) {
        //     alert(`You're currently connected to the ${chainData.name}. Please connect to the Ethereum Testnet Rinkeby to access full functionality of this dApp!`)
        //     onDisconnect()
        // }

        try {
            tokenInstance = new web3.eth.Contract(abi.Token, tokenAddress, { from: accounts[0] })
            presaleInstance = new web3.eth.Contract(abi.PreSale, presaleAddress, { from: accounts[0] })

            user = accounts[0]
            tokenSymbol = await tokenInstance.methods.symbol().call()

            console.log(tokenInstance)
            console.log(presaleInstance)
        } catch (e) {
            console.log("Could not get contract instance", e);
            return;
        }

        if (tokenInstance && presaleInstance) {
            tokenInstance.events.Approval().on("data", function(event) {
                    console.log(event)
                    let owner = event.returnValues.tokenOwner
                    let spender = event.returnValues.spender
                    let amount = event.returnValues.tokens
                    $("#approvalEventEmitted").css("display", "block")
                    $("#approvalEventEmitted").text(owner + " has approved " + spender + " to spend a maximum of " + amount +
                        " from balance.")
                })
                .on("error", console.error)
            tokenInstance.events.Transfer().on("data", function(event) {
                    console.log(event)
                    let owner = event.returnValues.tokenOwner
                    let receipient = event.returnValues.to
                    let amount = event.returnValues.tokens
                    $("#TransferEventEmitted").css("display", "block")
                    $("#TransferEventEmitted").text(owner + " has transferred " + amount + " to " + receipient)
                })
                .on("error", console.error)

            presaleInstance.events.TokenPurchase().on("data", function(event) {
                    console.log(event)
                    let owner = event.returnValues.purchaser
                    let price = event.returnValues.value
                    let priceETH = web3.utils.fromWei(price.toString(), "ether")
                    let amount = event.returnValues.amount
                    let amountToken = web3.utils.fromWei(amount.toString(), "ether")
                    $("#purchaceEventEmitted").css("display", "block")
                    $("#purchaceEventEmitted").text("You (" + owner + ") have successfully purchased " + amountToken + " " + tokenSymbol + " for " + priceETH + " ETH")
                })
                .on("error", console.error)
        }

        // Display fully loaded UI for wallet data
        document.querySelector("#btn-connect").style.display = "none";
        document.querySelector("#btn-disconnect").style.display = "block";

        let weiRaised = await presaleInstance.methods.weiRaised().call()
        let ethRaised = web3.utils.fromWei(weiRaised.toString(), "ether")
        let tokenSoldPhase1 = await presaleInstance.methods.tokenSoldPhase1().call()
        let tokenSoldPhase2 = await presaleInstance.methods.tokenSoldPhase2().call()
        let tokenSoldPhase3 = await presaleInstance.methods.tokenSoldPhase3().call()
        let presaleSupplyWei = await presaleInstance.methods.cap().call()
        let presaleSupply = web3.utils.fromWei(presaleSupplyWei.toString(), "ether")

        let tokenBalanceWei = await tokenInstance.methods.balanceOf(user).call()
        let tokenBalance = web3.utils.fromWei(tokenBalanceWei.toString(), "ether")
        console.log(user);

        let amountSoldWei = parseInt(tokenSoldPhase1) + parseInt(tokenSoldPhase2) + parseInt(tokenSoldPhase3)
        let amountSold = web3.utils.fromWei(amountSoldWei.toString(), "ether")
        let percentage = (amountSoldWei / parseInt(presaleSupplyWei)) * 100

        document.querySelector("#token-sold").textContent = `${amountSold} ${tokenSymbol}`;
        document.querySelector("#token-cap").textContent = `${presaleSupply} ${tokenSymbol}`;

        document.getElementById("percentage-bar").style["width"] = `${percentage}%`;
        document.querySelector("#percentage-bar").textContent = `${amountSold} ${tokenSymbol}`;

        document.querySelector("#token-balance").textContent = `${tokenBalance} ${tokenSymbol}`;

        document.querySelector("#blockchain-input").style.display = "flex";

        let presaleOwner = await presaleInstance.methods.owner().call()
        if (user == presaleOwner) {
            // for owner
        }
    } else {
        onDisconnect()
    }
}



/**
 * Fetch account data for UI when
 * - User switches accounts in wallet
 * - User switches networks in wallet
 * - User connects wallet initially
 */
async function refreshAccountData() {

    // If any current data is displayed when
    // the user is switching acounts in the wallet
    // immediate hide this data
    document.querySelector("#btn-connect").style.display = "block";
    document.querySelector("#btn-disconnect").style.display = "none";
    document.querySelector("#blockchain-input").style.display = "none";

    // Disable button while UI is loading.
    // fetchAccountData() will take a while as it communicates
    // with Ethereum node via JSON-RPC and loads chain data
    // over an API call.
    document.querySelector("#btn-connect").setAttribute("disabled", "disabled")
    await fetchAccountData(provider);
    document.querySelector("#btn-connect").removeAttribute("disabled")
}


/**
 * Connect wallet button pressed.
 */
async function onConnect() {
    walletDisconnect = false

    console.log("Opening a dialog", web3Modal);
    try {
        provider = await web3Modal.connect();
    } catch (e) {
        console.log("Could not get a wallet connection", e);
        return;
    }

    // Subscribe to accounts change
    provider.on("accountsChanged", async(accounts) => {
        await fetchAccountData();
    });

    // Subscribe to chainId change
    provider.on("chainChanged", async(chainId) => {
        await fetchAccountData();
    });

    // Subscribe to networkId change
    provider.on("networkChanged", async(networkId) => {
        await fetchAccountData();
    });

    // Subscribe to disconnected
    provider.on("disconnect", async(accounts) => {
        if (provider.close) {
            onDisconnect()
        } else {
            await fetchAccountData();
        }
    });

    if (!walletDisconnect) {
        await refreshAccountData();
    }
}

/**
 * Disconnect wallet button pressed.
 */
async function onDisconnect() {
    walletDisconnect = true;

    console.log("Killing the wallet connection", provider);

    // TODO: Which providers have close method?
    if (provider.close) {
        await provider.close();

        // If the cached provider is not cleared,
        // WalletConnect will default to the existing session
        // and does not allow to re-scan the QR code with a new wallet.
        // Depending on your use case you may want or want not his behavir.
        await web3Modal.clearCachedProvider();
        provider = null;
        web3 = null;
    } else {
        await web3Modal.clearCachedProvider();
        provider = null;
        web3 = null;
    }

    selectedAccount = null;
    user = null;

    // Set the UI back to the initial state
    document.querySelector("#btn-connect").style.display = "block";
    document.querySelector("#btn-disconnect").style.display = "none";
    document.querySelector("#blockchain-input").style.display = "none";
    //location.reload()
}


async function finalizePresale() {
    presaleInstance.methods.finalize().send({}, function(err, txHash) {
        if (err) {
            console.log(err);
        } else {
            console.log(txHash);
        }
    })
}


/**
 * Main entry point.
 */
window.addEventListener('load', async() => {
    init();

    if (web3Modal.cachedProvider) {
        onConnect()
    } else {
        document.querySelector("#btn-connect").style.display = "block";
        document.querySelector("#connect-alert").style.display = "block";
        document.querySelector("#btn-disconnect").style.display = "none";
        document.querySelector("#blockchain-input").style.display = "none";
    }

    document.querySelector("#btn-connect").addEventListener("click", onConnect);
    document.querySelector("#btn-disconnect").addEventListener("click", onDisconnect);
});