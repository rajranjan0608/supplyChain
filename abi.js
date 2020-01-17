ABI = [
    {
      "constant": true,
      "inputs": [],
      "name": "bestBid",
      "outputs": [
        {
          "name": "bidder",
          "type": "address"
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
          "name": "_req",
          "type": "string[]"
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
          "indexed": false,
          "name": "bidNumber",
          "type": "uint256"
        },
        {
          "indexed": true,
          "name": "winner",
          "type": "address"
        }
      ],
      "name": "Winner",
      "type": "event"
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
      "inputs": [
        {
          "name": "_bidNumber",
          "type": "uint256"
        }
      ],
      "name": "declareWinner",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
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
          "type": "string[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
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
          "type": "string[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
  ]