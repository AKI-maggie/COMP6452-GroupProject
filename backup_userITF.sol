pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

import "OracleAuthenticator.sol"

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
        uint id;
        address author;
        string restaurant;
        string content;
        int credits;
        string receipt;
    }
    
    struct Comment {
        uint review;
        address author;
        bool positive;
        string comment;
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

    Review[] public reviews;
    Comment[] public comments;
    CouponType[] public couponTypes;
    Coupon[] public coupons;
    
    uint review_count = 0;

    // authenticator components
    GetStatus receiptAuthenticator;
    // mapping(bytes32=>bool) validIds;
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewProvableQuery(string description);

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
    // Constructor
    function GetStatus() payable public {
        LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Provable Query.");
        receiptAuthenticator = GetStatus(_m);
    }

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
    function newReview(string memory receiptNo, string memory restName, string memory review) 
        public accountExists notEmpty(receiptNo) notEmpty(review) notEmpty(restName) returns (int credit) {
        address author = msg.sender;

        // check receipt validity
        if (authenticate(receiptNo, restName)) {
            Review memory r;
            r.id = review_count;
            review_count ++;
            r.author = author;
            r.restaurant = restName;
            r.content = review;
            r.credits = calculateForNewReview(author); // initial credit based on the author's credits
            r.receipt = receiptNo;

            reviews.push(r);
            
            users[author].unusedCredits += r.credits; // change user credit
            
            return r.credits;
        }
        else{
            return -1;
        }
    }
    
    // return reviews with credit sorting
    function searchReview(string memory restName) public returns (Review[] memory reviews){
        Review[] memory reviews = backendSearchReview(restName);
        return reviews;
    }

    function newComment(uint reviewNo, string memory comment, string memory receiptNo, bool positive) 
        public accountExists notEmpty(receiptNo) notEmpty(comment) returns (int){
        string memory restName = reviews[reviewNo].restaurant;
        if (authenticate(receiptNo, restName)) {
            Comment memory c;
            c.review = reviewNo;
            c.author = msg.sender;
            c.comment = comment;    
            c.positive = positive;
            c.receipt = receiptNo;
            
            comments.push(c);
            
            // get new writer and commentor credits
            (int authorCredit, int commentorCredit) = calculateForNewComment(positive, msg.sender, reviews[reviewNo].author);
            
            // update to the database
            users[reviews[reviewNo].author].unusedCredits += authorCredit;
            users[msg.sender].unusedCredits += commentorCredit;
            
            return commentorCredit;
        }
        else{
            return 0;
        }
    }

    // Credit Management functions
    function checkCredit() public accountExists returns (int unusedCredits, CouponType[] memory available_coupons) {
        return (users[msg.sender].unusedCredits, check_available_coupons(msg.sender));
    }

    function exchangeCoupon(string memory restName, uint value, int num) public accountExists returns (string memory){
        // check account and database availabilitys
        int result = backendExchangeCoupon(restName, value, num, users[msg.sender].unusedCredits);
        if (result >= 0){
            // mark credits to be used
            users[msg.sender].unusedCredits -= result;
            users[msg.sender].usedCredits += result;
            return 'XXXXXXXX';
        }
        else{
            return '';
        }
    }

    // Authenticator functions (connected with Oracle)
    function authenticate(string memory receiptNo, string memory restName) private returns (bool){
        OracleAuthenticator.getStatus(restName, receiptNo);
    }
    
    /**
    * Functions (off-chain simulator)
    **/
    
    function calculateForNewReview(address author) private returns (int credit){
        int author_credit = users[author].unusedCredits + users[author].usedCredits;
        return author_credit / 10;
    }
    
    function calculateForNewComment(bool positive, address author, address commentor) private returns (int creditForAuthor, int creditForCommentor){
        return (5, 5);
    }
    
    // if succeed, return the number of credit exchanged 
    function backendExchangeCoupon(string memory restName, uint value, int num, int credits) private returns (int){
        return 0;
    }
    
    function backendSearchReview(string memory restName) private returns (Review[] memory reviews){
        return reviews;
    }
    
    function check_available_coupons(address user) private returns (CouponType[] memory available_coupons){
        return couponTypes;
    }

}   