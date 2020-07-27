pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./StringTools.sol";
import "./Backend.sol";

// This file contains the interface class which contains management functions for normal users
contract UserITF{
    /**
    * Structures
    **/
    struct User {
        string name;
        int unusedCredits;   // unused credits that could be used to exchange prizes
        int usedCredits;  // used credits that could be only counted for a part of the total credit
        string[] holdCoupons;
    }
    
    /**
    * Variables
    **/
    
    // userITF components
    mapping (address => User) public users;
    
    // auto reward constant
    int public thres = 50;

    // backend request variables
    
    event LogNewProvableQuery(string description);
    event LogDebug(bytes32 description);
    event LogDebug2(string description);

    StringTools st;
    
    /**
    * Modifiers
    **/

    modifier notEmpty(string content){
        require(bytes(content).length != 0);
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
    function register(string memory username, address sender) public view returns (bool) {
        User memory u;
        u.name = username;
        u.unusedCredits = 30; // initial credits
        users[sender] = u;
        return true;
    }

    // Review Management functions
    
    
    
    function newReview(string memory receiptNo, string memory restName, string memory review) payable
        public notEmpty(review){
        // calculate credit
        int reviewCredit = (users[msg.sender].unusedCredits + users[msg.sender].usedCredits) / 10;
        // add review validity checking order to the backend
        string memory data = string(abi.encodePacked('{\n "author": "', st.toString(msg.sender), 
                                                    '",\n"restaurant": "', restName,
                                                    '",\n"content": "', review, 
                                                    '",\n"credits": "', st.int2str(reviewCredit),
                                                    '",\n"receipt": "', receiptNo,
                                                    '"\n} '));
        users[msg.sender].unusedCredits += reviewCredit;  // include into user's credit
        
    }
    
    
    
    function exchangePrizes() payable public enoughCredit() {
        //bytes32 queryId = provable_query(60,"URL", st.append2("https://guarded-sands-73970.herokuapp.com/coupons/", st.toString(msg.sender)),500000);
        //validIds[queryId] = Usage('prize', '', msg.sender, '', thres);
    }
    
    function newComment(string memory receiptNo, address author, string memory receiptNo2, string memory restName, string memory comment, bool positive) payable public 
     notEmpty(comment){
        
        this.commentDataUpload1.value(msg.value/2)(receiptNo, msg.sender, restName, comment, positive);
        this.commentDataUpload2.value(msg.value/2)(receiptNo2, author, restName, msg.sender, positive);

    }
    
    function commentDataUpload1(string memory receiptNo, address sender, string memory restName, string memory comment, bool positive) payable public{
        string memory data = string(abi.encodePacked('{\n "review": "', receiptNo, 
                                                    '",\n"author": "', st.toString(sender),
                                                    '",\n"positive": "', st.trueOrFalse(positive), 
                                                    '",\n"comment": "',comment,
                                                    '",\n"restaurant": "', restName,
                                                    '"\n} '));
        users[sender].unusedCredits += (users[sender].unusedCredits + users[sender].usedCredits) / 30;  
        //this.uploadipfs('comment', data, sender, restName, receiptNo, (users[sender].unusedCredits + users[sender].usedCredits) / 30);
    }
    
    function commentDataUpload2(string memory receiptNo, address author, string memory restName, address sender, bool positive) payable public { 
        if (positive==true){
            users[author].unusedCredits += (users[sender].unusedCredits + users[sender].usedCredits) / 15;
        }
        else{
            users[author].unusedCredits -= (users[sender].unusedCredits + users[sender].usedCredits) / 15;
        }
        //string memory data = string(abi.encodePacked('{\n "receipt":"', receiptNo,
          //                                             '",\n"rest": "', restName,
            //                                          '",\n"credit": "', origCredit
          //                                             ));
        //this.uploadipfs('reviewUpdate', data, author, restName, receiptNo, origCredit);
    }
    
}