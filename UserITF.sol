pragma solidity ^0.6.0;

// This file contains the interface class which contains management functions for normal users
contract UserITF {
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
        uint review;
        address author;
        bool positive;
        string receipt;
    }
    
    struct Coupon {
        string restaurant;
        uint value;
    }
    
    mapping (address => User) public users;

    Review[] public reviews;
    Comment[] public comments;
    Coupon[] public coupons;

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
    function newReview(string memory receiptNo, string memory rest_name, string memory review) 
             public accountExists notEmpty(receiptNo) notEmpty(review) notEmpty(rest_name) returns (int credit) {
        address author = msg.sender;

        // check receipt validity
        if (authenticate(receiptNo)) {
            Review memory r;
            r.author = author;
            r.restaurant = rest_name;
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

    // Credit Management functions
    function checkCredit() public accountExists returns (int unusedCredits, int usedCredits) {
        return (users[msg.sender].unusedCredits, users[msg.sender].usedCredits);
    }


    // Authenticator functions (connected with Oracle)
    function authenticate(string memory receiptNo) private returns (bool){
        return true;
    }
    
    /**
    * Functions (off-chain simulator)
    **/
    
    function calculateForNewReview(address author) private returns (int credit){
        int author_credit = users[author].unusedCredits + users[author].usedCredits;
        return author_credit / 10;
    }

}   