pragma solidity ^0.4.24;

import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./StringTools.sol";

// This file contains the interface class which contains management functions for normal users
contract Backend {
    uint count;
    
    StringTools st;
    mapping(string=>address) usedReceipts;
    
    modifier notEmpty(string content){
        require(bytes(content).length != 0);
        _;
    }
    // modifier enoughPrice(){
    //     requestPrice = provable_getPrice("URL");
    //     AvaBalance = address(this).balance;
    //     require(msg.value >= requestPrice);
    //     _;
    // }
    
    modifier verifiedReceipt(string option, string receiptNo, string restName, address sender){
        if (st.compareStrings(option, 'reviewUpdate')){
        }
        else{
            require(usedReceipts[st.append2(restName, receiptNo)] == sender);
        }
        _;
    }

    struct Usage {
        string use;
        string arg1;
        address arg2;
        string arg3;
        int arg4;
        string arg5;
    }
    
    struct Review {
        string hash;
        address author;
        string restaurant;
        string receipt;
        int credits;
        string[] comments;
    }
    
    struct restReviews {
        Review[] reviews;
    }
    
    // API address
    string receiptLink = "json(https://guarded-sands-73970.herokuapp.com/records/";
    // uint256 public requestPrice;
    // uint256 public AvaBalance;
    // saves the processing order id from the backend
    mapping(bytes32=>Usage) validIds;
    event LogNewProvableQuery(string description);
    event LogDebug(bytes32 description);
    event LogDebug2(string description);
    mapping (bytes => Review)  reviews;
    mapping (string => restReviews) rest;
    
    string public debug;
    Review public debug2;
    Usage public debug3;
    bytes public debug4;

    // Receipt Authentication
    function Backend(address _m){
        st = StringTools(_m);
        count = 0;
    }
    
    function receiptAuthenticate(string memory receiptNo, string memory restName, address sender) public
        notEmpty(receiptNo) notEmpty(restName)  {
        require(usedReceipts[st.append2(restName, receiptNo)] == address(0));
        string memory s3 = st.append(receiptLink,restName,"/",receiptNo,  ").result");
        // if (requestPrice > this.balance) {
        //   LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        // } 
        // else {
        //   LogNewProvableQuery("Provable query was sent, standing by for the answer..");
          bytes32 queryId = fake_provable_query(60,"URL", s3,500000);
          validIds[queryId] = Usage('receipt', restName, sender, '', 0, '');
          fake_callback(queryId, receiptNo);
    }
    
    // IPFS upload function
    // hash file link : https://guarded-sands-73970.herokuapp.com/records/ipfs 
    // when you want to access the ipfs database link is : https://ipfs.infura.io/ipfs/ + {hash from above address}
    function uploadipfs(string option, string data, address user, string restName, string receiptNo, int credit, string backup)
    public verifiedReceipt(option, receiptNo, restName, user) {
        bytes32 queryId;
        // if (provable_getPrice("URL") > this.balance) {
        //   LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        // } 
        // else {
        //   LogNewProvableQuery("Provable query was sent, standing by for the answer..");
      if(st.compareStrings(option,"comment")){
          queryId = fake_provable_query(60, "URL",data, 5000);
          validIds[queryId] = Usage('comment', restName, user, receiptNo, credit, '');
          fake_callback(queryId, data);
      }
      else if (st.compareStrings(option,"reviewUpdate")){
          queryId = fake_provable_query(60, "URL",data, 5000);
          validIds[queryId] = Usage('reviewUpdate', restName, user, receiptNo, credit, backup);
          fake_callback(queryId, data);
      }
      else{  // review
          queryId = fake_provable_query(60, "URL",data, 5000);
          debug = data;
          validIds[queryId] = Usage('review', restName, user, receiptNo, credit, '');
          fake_callback(queryId, data);
      }
    }
    
    // Callback function
    // Handles with all callback actions from the off-chain results
    function fake_provable_query(uint time, string t, string addr, int amount) public returns (bytes32) {
        count += 1;
        return bytes32(count);
    }
    function fake_callback(bytes32 myid, string result){
        if (st.compareStrings(validIds[myid].use, 'receipt')){
            // receipt Authentication
            if (st.compareStrings(result, 'false') != true){
                string memory receipt_addr = st.append2(validIds[myid].arg1, result);
                usedReceipts[receipt_addr] = validIds[myid].arg2;
            }
        }
        else if (st.compareStrings(validIds[myid].use, 'review')){
            Review memory r;
            r.hash = result;
            r.author = validIds[myid].arg2;
            r.restaurant = validIds[myid].arg1;
            r.receipt = validIds[myid].arg3;
            r.credits = validIds[myid].arg4;
            // Review memory r = Review(result, validIds[myid].arg2, validIds[myid].arg1, validIds[myid].arg3, validIds[myid].arg4, new string[](0));
            reviews[st.append22(validIds[myid].arg1, validIds[myid].arg3)] = r;
            
            rest[validIds[myid].arg1].reviews.push(r);
            
            usedReceipts[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = address(-1);  // the receipt no longer usable
            
            debug2 = reviews[st.append22(validIds[myid].arg1, validIds[myid].arg3)];
        }
        else if (st.compareStrings(validIds[myid].use, 'comment')){
            usedReceipts[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = address(-1);  // the receipt no longer usable
            debug = result;
            reviews[st.append22(validIds[myid].arg1, validIds[myid].arg5)].comments.push(result);
            debug = reviews[st.append22(validIds[myid].arg1, validIds[myid].arg5)].comments[0];
        }
        
        else if (st.compareStrings(validIds[myid].use, 'reviewUpdate')){
            reviews[st.append22(validIds[myid].arg1, validIds[myid].arg5)].credits += validIds[myid].arg4;
            debug2 = reviews[st.append22(validIds[myid].arg1, validIds[myid].arg5)];
        }
        else{
        }
        debug = result;
        // delete validIds[myid];
    }
}