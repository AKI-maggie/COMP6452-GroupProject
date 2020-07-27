pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./StringTools.sol";

// This file contains the interface class which contains management functions for normal users
contract UserITF is usingProvable{
    /**
    * Structures
    **/
    struct User {
        string name;
        int unusedCredits;   // unused credits that could be used to exchange prizes
        int usedCredits;  // used credits that could be only counted for a part of the total credit
        mapping(string=>Review) storedReviews;
        mapping(string=>string) storedComments;
        string[] holdCoupons;
    }
    
    
    struct Review {
        string hash;
        address author;
        string restaurant;
        string receipt;
        int credits;
    }
    
    struct Usage {
        string use;
        string arg1;
        address arg2;
        string arg3;
        int arg4;
    }
    
    /**
    * Variables
    **/
    
    // userITF components
    mapping (address => User) public users;
    mapping (string => Review) reviews;
    
    // auto reward constant
    int public thres = 50;

    // API address
    string receiptLink = "json(https://guarded-sands-73970.herokuapp.com/records/";
    // saves the processing order id from the backend
    mapping(bytes32=>Usage) validIds;
    mapping(string=>address) usedReceipts;
    // backend request variables
    uint256 public requestPrice;
    uint256 public AvaBalance;
    event LogPriceUpdated(string price);
    event LogNewProvableQuery(string description);
    event LogDebug(bytes32 description);
    
    StringTools st;
    
    /**
    * Modifiers
    **/
    modifier accountNotExists(){
        require(bytes(users[msg.sender].name).length == 0);
        _;
    }

    modifier accountExists(){
        require(bytes(users[msg.sender].name).length != 0);
        _;
    }

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

    modifier enoughCredit(){
        require(thres >= users[msg.sender].unusedCredits);
        _;
    }

    /**
    * Functions
    **/
    // constructor
    function UserITF(address _t) payable public {
        st = StringTools(_t);
    }

    function () payable {}
 
    // Account Management funcions
    function register(string memory username) public notEmpty(username) view returns (bool) {
        User memory u;
        u.name = username;
        u.unusedCredits = 30; // initial credits
        users[msg.sender] = u;
        return true;
    }

    // Review Management functions
    
    // Receipt Authentication
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
    
    function newReview(string memory receiptNo, string memory restName, string memory review) payable
        public notEmpty(review) enoughPrice verifiedReceipt(receiptNo, restName) {
        // calculate credit
        int reviewCredit = (users[msg.sender].unusedCredits + users[msg.sender].usedCredits) / 10;
        // add review validity checking order to the backend
        string memory data = string(abi.encodePacked('{\n "author": "', st.toString(msg.sender), 
                                                    '",\n"restaurant": "', restName,
                                                    '",\n"content": "', review, 
                                                    '",\n"credits": "', st.int2str(reviewCredit),
                                                    '",\n"receipt": "', receiptNo,
                                                    '"\n} '));
        
        uploadipfs('review', data, msg.sender, restName, receiptNo, reviewCredit);
        usedReceipts[st.append2(restName, receiptNo)] = address(-1);  // the receipt no longer usable
    }
    
    function newComment(string memory receiptNo, string memory receiptNo2, string memory restName, string memory comment, bool positive) payable public 
        enoughPrice notEmpty(comment) verifiedReceipt(receiptNo, restName) verifiedReceipt(receiptNo2, restName){
        
        this.commentDataUpload1.value(msg.value/2)(receiptNo, msg.sender, restName, comment, positive);
        this.commentDataUpload2.value(msg.value/2)(receiptNo2, restName, msg.sender, positive);
        
        usedReceipts[st.append2(restName, receiptNo)] = address(-1);  // the receipt no longer usable
    }
    
    function commentDataUpload1(string memory receiptNo, address sender, string memory restName, string memory comment, bool positive) payable public{
        string memory data = string(abi.encodePacked('{\n "review": "', receiptNo, 
                                                    '",\n"author": "', st.toString(sender),
                                                    '",\n"positive": "', st.trueOrFalse(positive), 
                                                    '",\n"comment": "',comment,
                                                    '",\n"restaurant": "', restName,
                                                    '"\n} '));
        this.uploadipfs('comment', data, sender, restName, receiptNo, (users[sender].unusedCredits + users[sender].usedCredits) / 30);
    }
    
    function commentDataUpload2(string memory receiptNo, string memory restName, address sender, bool positive) payable public { 
        address author = reviews[st.append2(restName, receiptNo)].author;
        int origCredit = reviews[st.append2(restName, receiptNo)].credits;
        if (positive==true){
            origCredit += (users[sender].unusedCredits + users[sender].usedCredits) / 15;
        }
        else{
            origCredit -= (users[sender].unusedCredits + users[sender].usedCredits) / 15;
        }
        string memory data = string(abi.encodePacked('{\n "receipt":"', receiptNo,
                                                       '",\n"rest": "', restName,
                                                      '",\n"credit": "', origCredit
                                                       ));
        this.uploadipfs('reviewUpdate', data, author, restName, receiptNo, origCredit);
    }
    
    function exchangePrizes() payable public enoughCredit() {
        bytes32 queryId = provable_query(60,"URL", st.append2("https://guarded-sands-73970.herokuapp.com/coupons/", st.toString(msg.sender)),500000);
        validIds[queryId] = Usage('prize', '', msg.sender, '', thres);
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
            }
        }
        else if (st.compareStrings(validIds[myid].use, 'review')){
            users[validIds[myid].arg2].storedReviews[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = Review(result, validIds[myid].arg2, validIds[myid].arg1, validIds[myid].arg3, validIds[myid].arg4);
            reviews[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = Review(result, validIds[myid].arg2, validIds[myid].arg1, validIds[myid].arg3, validIds[myid].arg4);
            users[validIds[myid].arg2].unusedCredits += validIds[myid].arg4;  // include into user's credit
        }
        else if (st.compareStrings(validIds[myid].use, 'comment')){
            users[validIds[myid].arg2].storedComments[st.append2(validIds[myid].arg1, validIds[myid].arg3)] = result;
            users[validIds[myid].arg2].unusedCredits += validIds[myid].arg4;  // include into user's credit
        }
        else if (st.compareStrings(validIds[myid].use, 'prize')){
            users[validIds[myid].arg2].unusedCredits -= validIds[myid].arg4;
            users[validIds[myid].arg2].usedCredits += validIds[myid].arg4;
            users[validIds[myid].arg2].holdCoupons.push(result);
        }
        else if (st.compareStrings(validIds[myid].use, 'update')){
            
        }
        else{}
        LogPriceUpdated(result);
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
