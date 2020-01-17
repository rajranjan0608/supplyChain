Default = {

    contracts : {},

    web3: new Web3(web3.currentProvider),

    load: async () => {
        await Default.loadWeb3();
        console.log("Web3 Loaded!")
        await Default.loadAccount(); 
        console.log("Account Loaded!")
        await Default.loadContract();
        console.log("Contract Loaded!")
        await App.render();
        // console.log("Web3 Loaded!")
    },

    loadWeb3: async () => {
        if(typeof web3 !== 'undefined') {
            web3 = new Web3(web3.currentProvider);
            App.web3Provider = web3.currentProvider;
        }else {
            window.alert("Please connect to Metamask");
        }

        if(window.ethereum) {
            window.web3 = new Web3(ethereum);
            try {
                await ethereum.enable();
                web3.eth.sendTransaction({ });
            }catch (error) {

            }
        }else if(window.web3) {
            App.web3Provider = web3.currentProvider;
            window.web3 = new Web3(web3.currentProvider);
            web3.eth.sendTransaction({});
        }else{
            console.log('Non-Ethereum Browser detected');
        }
    },

    loadAccount: async() => {
        await web3.eth.getAccounts().then((result)=>{
            App.account = result[0];
        });
    },

    loadContract: async () => {
        const MainContract = await $.getJSON('/MainContract');
        Default.contracts.MainContract = TruffleContract(MainContract);
        Default.contracts.MainContract.setProvider(App.web3Provider);
        
        App.MainContract = await Default.contracts.MainContract.deployed();
    }
}

$(() => {
    window.addEventListener('load', ()=>{
        Default.load();
    })
});