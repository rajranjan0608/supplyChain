App = {

    ABI: [
        {
          "constant": true,
          "inputs": [],
          "name": "bestBid",
          "outputs": [
            {
              "name": "bidder",
              "type": "address"
            },
            {
              "name": "price",
              "type": "uint256"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "constant": true,
          "inputs": [],
          "name": "endTime",
          "outputs": [
            {
              "name": "",
              "type": "uint256"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "name": "_tenderID",
              "type": "uint256"
            },
            {
              "name": "_bidTime",
              "type": "uint256"
            },
            {
              "name": "_title",
              "type": "string"
            },
            {
              "name": "_desc",
              "type": "string"
            },
            {
              "name": "_database",
              "type": "address"
            },
            {
              "name": "_item",
              "type": "string"
            },
            {
              "name": "_qty",
              "type": "uint256"
            }
          ],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "constructor"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "name": "_tenderID",
              "type": "uint256"
            },
            {
              "indexed": false,
              "name": "bidNumber",
              "type": "uint256"
            },
            {
              "indexed": false,
              "name": "bidder",
              "type": "address"
            }
          ],
          "name": "bidAlert",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "name": "_tenderID",
              "type": "uint256"
            },
            {
              "indexed": false,
              "name": "_newEndTime",
              "type": "uint256"
            }
          ],
          "name": "newEndTime",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "name": "_tenderID",
              "type": "uint256"
            },
            {
              "indexed": true,
              "name": "winner",
              "type": "address"
            },
            {
              "indexed": false,
              "name": "_lowestPrice",
              "type": "uint256"
            }
          ],
          "name": "Winner",
          "type": "event"
        },
        {
          "constant": true,
          "inputs": [],
          "name": "isActive",
          "outputs": [
            {
              "name": "",
              "type": "uint8"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "constant": false,
          "inputs": [
            {
              "name": "_price",
              "type": "uint256"
            }
          ],
          "name": "makeBid",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "constant": true,
          "inputs": [
            {
              "name": "_bidNumber",
              "type": "uint256"
            }
          ],
          "name": "getBidByID",
          "outputs": [
            {
              "name": "",
              "type": "address"
            },
            {
              "name": "",
              "type": "uint256"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "constant": true,
          "inputs": [],
          "name": "displayTenderDetails",
          "outputs": [
            {
              "name": "",
              "type": "uint256"
            },
            {
              "name": "",
              "type": "uint256"
            },
            {
              "name": "",
              "type": "string"
            },
            {
              "name": "",
              "type": "string"
            },
            {
              "name": "",
              "type": "string"
            },
            {
              "name": "",
              "type": "string"
            },
            {
              "name": "",
              "type": "uint256"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "constant": false,
          "inputs": [
            {
              "name": "_val",
              "type": "uint256"
            }
          ],
          "name": "extendEndTime",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "constant": false,
          "inputs": [],
          "name": "getWinner",
          "outputs": [
            {
              "name": "",
              "type": "bool"
            }
          ],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "constant": true,
          "inputs": [],
          "name": "getAllBids",
          "outputs": [
            {
              "components": [
                {
                  "name": "bidder",
                  "type": "address"
                },
                {
                  "name": "price",
                  "type": "uint256"
                }
              ],
              "name": "",
              "type": "tuple[]"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "constant": true,
          "inputs": [],
          "name": "getMyBids",
          "outputs": [
            {
              "name": "",
              "type": "uint256[]"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        }
      ],
    
    loading:false,

    render: async () => {
        if(App.loading) {
            return;
        }
        $('#account').html(App.account);
    },

    approveBidder: async(address) => {
        App.MainContract.approveBidder(address, {from:App.account});
    },

    //Returns array of all Tenders with details
    getAllTenders: async () => {
        const tenderAddress = await App.MainContract.getAllTenders();
        var result = [];
        for(i = 0; i < tenderAddress.length; i++) {
            var tender = await new Default.web3.eth.Contract(App.ABI, tenderAddress[i]);
            var s = await tender.methods.displayTenderDetails().call();
            result.push(s);
        }
        console.log(result[0][3]);
        return result;
    },

    //Returns Tender with details having status as 0, 1 or 2
    getTendersByStatus: async (status) => {
        var tenderAddress = await App.MainContract.getTendersByStatus(status);
        var result = [];
        // for(i = 0; i < tenderAddress.length; i++) {
        //     var tender = await new Default.web3.eth.Contract(App.ABI, tenderAddress[i]);
        //     // var s = await tender.methods.displayTenderDetails().call();
        //     result.push(tender);
        // }
        console.log(tenderAddress);
    },

    //Return details of tender by ID
    getTenderByID: async (id) => {
        const tenderAddress = await App.MainContract.getTenderByID(id);
        var tender = await new Default.web3.eth.Contract(App.ABI, tenderAddress);
        var result = await tender.methods.displayTenderDetails().call();
        // console.log(result);
        return result;
    },

    //Create tender
    createTender: async () => {
        App.setLoading(true);
        const tenderID = $("#tenderID").val();
        const itemTitle = $("#title").val();
        const itemDesc = $("#desc").val();
        const itemProduct = $("#product").val();
        const itemQuantity = $("#quantity").val();

        try{
            await App.MainContract.createTender(tenderID, 1000, itemTitle, itemDesc, itemProduct, itemQuantity, {from:App.account});
            window.location.reload();
        }catch{
            window.location.reload();
        }
    },

    
    extendEndTime: async(tenderID, time) => {
        // const time = $('#extendTime').val();    //Make a text field with #extendTime
        const tenderAddress = await App.MainContract.getTenderByID(tenderID);
        var tender = await new Default.web3.eth.Contract(App.ABI, tenderAddress);
        tender.methods.extendEndTime(time).send({from: App.account});
    },

    makeBid: async(tenderID, price) => {
        const tenderAddress = await App.MainContract.getTenderByID(tenderID);
        var tender = await new Default.web3.eth.Contract(App.ABI, tenderAddress);
        tender.methods.makeBid(price).send({from: App.account});
    },

    getBidByID: async(tenderID, id) => {
        const tenderAddress = await App.MainContract.getTenderByID(tenderID);
        var tender = await new Default.web3.eth.Contract(App.ABI, tenderAddress);
        return await tender.methods.getBidByID(id).call();
    },

    getWinner: async(tenderID) => {
        const tenderAddress = await App.MainContract.getTenderByID(tenderID);
        var tender = await new Default.web3.eth.Contract(App.ABI, tenderAddress);
        await tender.methods.getWinner().send({from:App.account});
        var result = await tender.methods.bestBid().call();
        console.log(result)
        return result;
    },

    setLoading: (boolean) => {
        App.loading = boolean;
        const loader = $('#loading');
        const content = $('#content');
        if(boolean) {
            loader.show();
            content.hide();
        }else {
            loader.hide();
            content.show();
        }
    }

}

function uploadTenders() {
    $("#tenderList").hide();
    $("#uploadTender").show();
}

function showTenders() {
    $("#tenderList").show();
    $("#uploadTender").hide();
}