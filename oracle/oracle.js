const fetch = require('node-fetch');
var contract = require('truffle-contract')

var Web3 = require('web3');
var web3 = new Web3(new Web3.providers.WebsocketProvider('http://127.0.0.1:8545'));

const account = "0xE9E246825751346E6A910B8171c1A1ABA4f45B4D"

let address = "0x9C9075CFd202f889451d625AFE6A9B42B71F4590"
var abi = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "myid",
				"type": "bytes32"
			},
			{
				"name": "result",
				"type": "string"
			}
		],
		"name": "fake_callback",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "time",
				"type": "uint256"
			},
			{
				"name": "t",
				"type": "string"
			},
			{
				"name": "addr",
				"type": "string"
			},
			{
				"name": "amount",
				"type": "int256"
			}
		],
		"name": "fake_provable_query",
		"outputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "description",
				"type": "string"
			}
		],
		"name": "LogNewProvableQuery",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "description",
				"type": "bytes32"
			}
		],
		"name": "LogDebug",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "description",
				"type": "string"
			}
		],
		"name": "LogDebug2",
		"type": "event"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "receiptNo",
				"type": "string"
			},
			{
				"name": "restName",
				"type": "string"
			},
			{
				"name": "sender",
				"type": "address"
			}
		],
		"name": "receiptAuthenticate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "data",
				"type": "string"
			}
		],
		"name": "UploadComment",
		"type": "event"
	},
	{
		"inputs": [
			{
				"name": "_m",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "option",
				"type": "string"
			},
			{
				"name": "data",
				"type": "string"
			},
			{
				"name": "user",
				"type": "address"
			},
			{
				"name": "restName",
				"type": "string"
			},
			{
				"name": "receiptNo",
				"type": "string"
			},
			{
				"name": "credit",
				"type": "int256"
			},
			{
				"name": "backup",
				"type": "string"
			}
		],
		"name": "uploadipfs",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "data",
				"type": "string"
			}
		],
		"name": "UploadReview",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "RestName",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "Receipt",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "credit",
				"type": "int256"
			}
		],
		"name": "UpdateReview",
		"type": "event"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "debug",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "debug2",
		"outputs": [
			{
				"name": "hash",
				"type": "string"
			},
			{
				"name": "author",
				"type": "address"
			},
			{
				"name": "restaurant",
				"type": "string"
			},
			{
				"name": "receipt",
				"type": "string"
			},
			{
				"name": "credits",
				"type": "int256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "debug3",
		"outputs": [
			{
				"name": "use",
				"type": "string"
			},
			{
				"name": "arg1",
				"type": "string"
			},
			{
				"name": "arg2",
				"type": "address"
			},
			{
				"name": "arg3",
				"type": "string"
			},
			{
				"name": "arg4",
				"type": "int256"
			},
			{
				"name": "arg5",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "debug4",
		"outputs": [
			{
				"name": "",
				"type": "bytes"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "record",
		"outputs": [
			{
				"name": "",
				"type": "int256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
]
startListener(address)
function startListener(address) {
    
    console.log("starting event monitoring on contract: " + address)
    let myContract = new web3.eth.Contract(abi, address)

    const UploadReviewHandler = myContract.events.UploadReview((error, event) => {
        if (error) {
            throw error
        }

        console.log('Review Upload:');
        console.log(event.returnValues.data);
        reviewhandler(event.returnValues.data);
    });

    const UploadCommentHandler = myContract.events.UploadComment((error, event) => {
        if (error) {
            throw error
        }

        console.log('Comment Upload:');
        console.log(event.returnValues.data);
        commenthandler(event.returnValues.data);
    });

    const UpdateReviewHandler = myContract.events.UpdateReview((error, event) => {
        if (error) {
            throw error
        }

        console.log('Comment Update:');
        console.log(event.returnValues);
        console.log(event.returnValues.RestName);
        reviewupdater(event.returnValues.RestName, event.returnValues.Receipt, event.returnValues.credit);
    });
}

// handles a request event and sends the response to the contract
function reviewhandler(data) {
    // using the excellent Dark Sky API - getting the forecast, centered on LA
    let url = "https://guarded-sands-73970.herokuapp.com/records/Review"
    console.log("Do review upload..")

    postData(url, data)
        .then(resp => {
            console.log(resp); // JSON data parsed by `data.json()` call
        });
}

function commenthandler(data){
    // using the excellent Dark Sky API - getting the forecast, centered on LA
    let url = "https://guarded-sands-73970.herokuapp.com/records/Comment"
    console.log("Do comment upload..")

    postData(url, data)
        .then(resp => {
            console.log(resp); // JSON data parsed by `data.json()` call
        });
}

function reviewupdater(restname, receipt, credit){
    console.log("Do review update..")
    // console.log('https://guarded-sands-73970.herokuapp.com/credit/' + restname + '/' + receipt + '/' + credit)
	console.log('https://guarded-sands-73970.herokuapp.com/records/credit/'+restname+'/'+receipt+'/'+credit)
    fetch('https://guarded-sands-73970.herokuapp.com/records/credit/'+restname+'/'+receipt+'/'+credit)
        .then(response => response.json())
        .then(data => console.log(data));
}

async function postData(url = '', data = '') {
    // Default options are marked with *
    const response = await fetch(url, {
        method: 'POST', // *GET, POST, PUT, DELETE, etc.
        headers: {
            'Content-Type': 'application/json'
            // 'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: data // body data type must match "Content-Type" header
    });
    return response.json(); // parses JSON response into native JavaScript objects
}