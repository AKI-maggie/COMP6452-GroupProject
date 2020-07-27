pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./StringTools.sol";

import "./UserITF.sol";

// This file contains the interface class which contains management functions for normal users
contract Backend is usingProvable{
    StringTools st;
    mapping(string=>address) usedReceipts;
    
    modifier notEmpty(string content){
        require(bytes(content).length != 0);
        _;
    }
    modifier enoughPrice(){
        requestPrice = provable_getPrice("URL");
        AvaBalance = address(this).balance;
        require(msg.value >= requestPrice);
        _;
    }
    
    modifier verifiedReceipt(string receiptNo, string restName){
        require(usedReceipts[st.append2(restName, receiptNo)] == msg.sender);
        _;
    }

    struct Usage {
        string use;
        string arg1;
        address arg2;
        string arg3;
        int arg4;
    }
    
    struct Review {
        string hash;
        address author;
        string restaurant;
        string receipt;
        int credits;
    }
    
    // API address
    string receiptLink = "json(https://guarded-sands-73970.herokuapp.com/records/";
    uint256 public requestPrice;
    uint256 public AvaBalance;
    // saves the processing order id from the backend
    mapping(bytes32=>Usage) validIds;
    event LogNewProvableQuery(string description);
    event LogDebug(bytes32 description);
    event LogDebug2(string description);
    mapping (string => Review) reviews;
    
    // Receipt Authentication
    function Backend(address _m){
        st = StringTools(_m);
    }
    function receiptAuthenticate(string memory receiptNo, string memory restName) payable public
        notEmpty(receiptNo) notEmpty(restName) enoughPrice {
        require(usedReceipts[st.append2(restName, receiptNo)] == address(0));
        string memory s3 = st.append(receiptLink,restName,"/",receiptNo,  ").result");
        if (requestPrice > this.balance) {
          LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } 
        else {
          LogNewProvableQuery("Provable query was sent, standing by for the answer..");
          bytes32 queryId = provable_query(60,"URL", s3,500000);
          validIds[queryId] = Usage('receipt', restName, msg.sender, '', 0);
        }
    }
    
    // Callback function
    // Handles with all callback actions from the off-chain results
    function __callback(bytes32 myid, string result) {
        if (msg.sender != provable_cbAddress()) revert();
        // interactions
        if (st.compareStrings(validIds[myid].use, 'receipt')){
            // receipt Authentication
            if (st.compareStrings(result, 'false') != true){
                string memory receipt_addr = st.append2(validIds[myid].arg1, result);
                usedReceipts[receipt_addr] = validIds[myid].arg2;
                LogDebug2("new receipt verified");
            }
        }
        else if (st.compareStrings(validIds[myid].use, 'review')){
            
            reviews[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = Review(result, validIds[myid].arg2, validIds[myid].arg1, validIds[myid].arg3, validIds[myid].arg4);
            //uploadipfs('review', data, msg.sender, restName, receiptNo, reviewCredit);
            usedReceipts[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = address(-1);  // the receipt no longer usable

        }
        else if (st.compareStrings(validIds[myid].use, 'comment')){
            
            usedReceipts[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = address(-1);  // the receipt no longer usable
        }
        else if (st.compareStrings(validIds[myid].use, 'prize')){
            // users[validIds[myid].arg2].unusedCredits -= validIds[myid].arg4;
            // users[validIds[myid].arg2].usedCredits += validIds[myid].arg4;
            // users[validIds[myid].arg2].holdCoupons.push(result);
        }
        else if (st.compareStrings(validIds[myid].use, 'update')){
            
        }
        else{}
        delete validIds[myid];
    }
    
    // IPFS upload function
    // hash file link : https://guarded-sands-73970.herokuapp.com/records/ipfs 
    // when you want to access the ipfs database link is : https://ipfs.infura.io/ipfs/ + {hash from above address}
    function uploadipfs(string option, string data, address user, string restName, string receiptNo, int credit) payable enoughPrice{
        bytes32 queryId;
        if (provable_getPrice("URL") > this.balance) {
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } 
        else {
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           if(st.compareStrings(option,"comment")){
               queryId = provable_query("URL","json(https://guarded-sands-73970.herokuapp.com/records/Comment).success.deposit",data);
               validIds[queryId] = Usage('comment', restName, user, receiptNo, credit);
           }
           else if (st.compareStrings(option, "update")){
            //   queryId = provable_query("URL","json(https://guarded-sands-73970.herokuapp.com/records/Comment).success.deposit",data);
            //   validIds[queryId] = Usage('comment', restName, user, receiptNo, credit);
           }
           else{
               queryId = provable_query("URL", "json(https://guarded-sands-73970.herokuapp.com/records/Review).success.deposit",data);
               validIds[queryId] = Usage('review', restName, user, receiptNo, credit);
           }
       }
    }
}