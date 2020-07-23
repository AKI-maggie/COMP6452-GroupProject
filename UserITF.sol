pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

// This file contains the interface class which contains management functions for normal users
contract UserITF is usingProvable{
    /**
    * Structures
    **/
    struct User {
        string name;
        int unusedCredits;   // unused credits that could be used to exchange prizes
        int usedCredits;  // used credits that could be only counted for a part of the total credit
    }
    
    struct Review {
        address author;
        string restaurant;
        string content;
        int credits;
        string receipt;
    }
    
    struct Comment {
        bytes32 review;
        address author;
        bool positive;
        string comment;
        string restaurant;
        string receipt;
    }
    
    struct CouponType {
        string restaurant;
        uint value; // the value for the coupon
        int rest;  // the number of the rest available
    }
    
    struct Coupon {
        address owner;
        uint couponType;
    }

    /**
    * Variables
    **/
    
    // userITF components
    mapping (address => User) public users;
    mapping(bytes32=>Review) public reviews;
    mapping(bytes32=>Comment) public comments;
    // CouponType[] public couponTypes;
    // Coupon[] public coupons;

    // API address
    string link = "json(https://guarded-sands-73970.herokuapp.com/records/";
    // saves the processing order id from the backend
    mapping(bytes32=>string) validIds;
    mapping(string=>bool) usedReceipts;
    // backend request variables
    uint256 public requestPrice;
    uint256 public AvaBalance;
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewProvableQuery(string description);
    
    // debug-use
    string public currentReview;
    string public currentComment;
    bytes32 public currentReviewId;
    string public str1;
    string public str2;
    string public authorStr = '';
    string public converted = '';
    string public hash = '';
    
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

    modifier notEmpty(string memory content){
        require(bytes(content).length != 0);
        _;
    }

    /**
    * Functions
    **/
    // constructor
    function UserITF() payable public {
        LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Provable Query.");
    }

    function () payable {}

    // Account Management funcions
    function register(string memory username) public accountNotExists notEmpty(username) returns (bool) {
    
        User memory u;
        u.name = username;
        u.unusedCredits = 0;
        u.usedCredits = 0;

        users[msg.sender] = u;
        return true;
    }

    // Review Management functions
    // return true if review successfully recorded
    // else return false
    // Review Management functions
    // return true if review successfully recorded
    // else return false
    function newReview(string memory receiptNo, string memory restName, string memory review) payable
        public accountExists notEmpty(receiptNo) notEmpty(review) notEmpty(restName) {
        require(msg.value >= 0.02 ether);
        address author = msg.sender;

        Review memory r;
        r.author = author;
        r.restaurant = restName;
        r.content = review;
        r.receipt = receiptNo;
        r.credits = 0;
        
        // add review validity checking order to the backend
        bytes32 id = this.receiptAuthenticate.value(msg.value)(receiptNo, restName, 'newReview');
        
        if (id != bytes32('none')) {
            reviews[id] = r;
            authorStr = toString(r.author);
            str1 = uint2str(r.credits);
            currentReview = string(abi.encodePacked('{\n "author": "', authorStr, '",\n"restaurant": "', r.restaurant,'",\n"content": "', r.content, '",\n"credits": "',str1, '",\n"receipt": "',r.receipt,'"\n} '));
            //uploadReview();
        }
    }

    function newComment(bytes32 reviewId, string memory comment, string memory receiptNo, bool positive) payable
        public accountExists notEmpty(receiptNo) notEmpty(comment) returns (int){
        require(msg.value >= 0.02 ether);
        string memory restName = reviews[reviewId].restaurant;
        
        Comment memory c;
        c.review = reviewId;
        c.author = msg.sender;
        c.comment = comment;    
        c.positive = positive;
        c.receipt = receiptNo;
        c.restaurant = restName;
        
        bytes32 id = this.receiptAuthenticate.value(msg.value)(receiptNo, restName, 'newComment');
        
        if (id != bytes32('none')) {
            comments[id] = c;
            address hw =  byteToAdd(c.review);

            converted = toString(hw);
            authorStr = toString(c.author);
            str1 = trueOrFalse(c.positive);
            currentComment = string(abi.encodePacked('{\n"review": "', converted, '",\n"author": "', authorStr, '",\n"positive": "', str1, '",\n"comment": "',c.comment,'",\n"restaurant": "',c.restaurant, '",\n"receipt": "',c.receipt,'"\n} '));
           // uploadComment("comment");
        }
        
        // get new writer and commentor credits
        // (int authorCredit, int commentorCredit) = calculateForNewComment(positive, msg.sender, reviews[reviewNo].author);
        
        // // update to the database
        // users[reviews[reviewNo].author].unusedCredits += authorCredit;
        // users[msg.sender].unusedCredits += commentorCredit;
    }

    // Authentication Function
    function receiptAuthenticate(string memory receiptNo, string memory restName, string usage) payable returns (bytes32 order_id){
        require(msg.value >= 0.0008 ether);
        string memory s3 = append(link,restName,"/",receiptNo,  ").result");
        if (provable_getPrice("URL") > this.balance) {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
           return bytes32("none");
        } 
        else {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           bytes32 queryId = provable_query(60,"URL", s3,500000);
           validIds[queryId] = usage;
           return queryId;
       }
    }
    // hash file link : https://guarded-sands-73970.herokuapp.com/records/ipfs 
    // when you want to access the ipfs database link is : https://ipfs.infura.io/ipfs/ + {hash from above address}
    function uploadipfs(string option) payable{
        require(msg.value >= 0.0008 ether);
     //   string memory s3 = string(abi.encodePacked(link,'Comment', ').success.deposit'));
    //   string memory s3 = string(abi.encodePacked(link,'Comment', ').message'));
        if (provable_getPrice("URL") > this.balance) {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } 
        else {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           if(compareStrings(option,"comment")){
       //        string memory s3 = string(abi.encodePacked(link,'Comment', ').success.deposit'));
               str1 = "send Comment";
               provable_query("URL","json(https://guarded-sands-73970.herokuapp.com/records/Comment).success.deposit",currentComment);
           }
           else{
             //  string memory s4 = string(abi.encodePacked(link,'Review', ').success.deposit'));
                str1 = "send Review";
                provable_query("URL", "json(https://guarded-sands-73970.herokuapp.com/records/Review).success.deposit",currentReview);
            //   provable_query("URL", "json(https://guarded-sands-73970.herokuapp.com/records/Review).success.deposit", ' { "author": "0x95563c6727cd91ef22330f93f307259fd71de2ef", "restaurant": "KFC", "content": "good", "credits": "0", "receipt": "12345667"}')
           }
          
       }
    }
    
    // Callback function
    // Handles with all callback actions from the off-chain results
    function __callback(bytes32 myid, string result) {
        if (msg.sender != provable_cbAddress()) revert();
        string memory receipt_addr;
        // interactions
        if (compareStrings(validIds[myid], 'newReview')){
            // write the review buffer into the database
            if (!compareStrings(result, 'false')){
                // record receipt usage
                receipt_addr = append2(reviews[myid].restaurant, reviews[myid].receipt);
                if (!usedReceipts[receipt_addr]){
                    usedReceipts[receipt_addr] = true;
                 //   str2 = string(abi.encodePacked('{ "author" : "', authorStr, '","restaurant" : "', reviews[myid].restaurant,'","content" : "', reviews[myid].content));
             //    currentReview = string(authorStr);
              //      currentReview = reviews[myid].content;
                    currentReviewId = myid;
                }
                else{
                    currentReview = '';
                    currentReviewId = bytes32(0);
                    delete reviews[myid];
                }
            }
            else{
                currentReview = '';
                delete reviews[myid];
            }
        }
        else if (compareStrings(validIds[myid], 'newComment')){
            if (!compareStrings(result, 'false')){
                // record receipt usage
                receipt_addr = append2(comments[myid].restaurant, comments[myid].receipt);
                if (!usedReceipts[receipt_addr]){
                    usedReceipts[receipt_addr] = true;
                   // currentComment = comments[myid].comment;
                
                }
                else{
                    currentComment = '';
                    delete comments[myid];
                }
            }
            else{
                currentComment = '';
                delete comments[myid];
            }
        }
        else{
            
        }
        hash = result;
        LogPriceUpdated(result);
        delete validIds[myid];
    }
    
    function trueOrFalse(bool x) public pure returns(string s){
        if(x){
            return "true";
        }
        return "false";
    }
    function toString(address _addr) public pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
    
   function byteToAdd(bytes32 data) internal pure returns (address) {
        return address(data);
    }
    
    function uint2str(int i) internal pure returns (string){
        if (i == 0) return "0";
        int j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
    
    function compareStrings (string memory a, string memory b) public returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    function append(string a, string b, string c, string d, string e) internal pure returns (string) {
        return string(abi.encodePacked(a, b, c, d, e));
    }
    
    function append2(string a, string b) internal pure returns (string) {
        return string(abi.encodePacked(a, b));
    }
}