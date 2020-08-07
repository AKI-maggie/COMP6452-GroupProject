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
        uint index;
        uint length;
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
    
    mapping(bytes32=>Usage) validIds;
    
    // auto reward constant
    int public thres = 50;

    // backend request variables
    
    event LogNewProvableQuery(string description);
    event LogDebug(bytes32 description);
    event LogDebug2(string description);

    StringTools st;
    Backend bck;
    
    int public debug;
    
    int count;
    
    /**
    * Modifiers
    **/
    modifier notEmpty(string content){
        require(bytes(content).length != 0);
        _;
    }    
    
    modifier accountNotExists(){
        require(bytes(users[msg.sender].name).length == 0);
        _;
    }

    modifier accountExists(){
        require(bytes(users[msg.sender].name).length != 0);
        _;
    }

    modifier enoughCredit(){
        require(thres <= users[msg.sender].unusedCredits);
        _;
    }
    
    modifier notAuthor(address author){
        require(msg.sender!=author);
        _;
    }
    
     /**
    * Functions
    **/
    // constructor
    function UserITF(address _t, address _m) public {
        st = StringTools(_t);
        bck = Backend(_m);
    }
 
    // Account Management funcions
    function receiptAuthenticate(string memory receiptNo, string memory restName) accountExists public
    notEmpty(receiptNo) notEmpty(restName) {
        bck.receiptAuthenticate(receiptNo, restName, msg.sender);
    }

    function register(string memory username) public accountNotExists returns (address) {
        User memory u;
        u.name = username;
        u.unusedCredits = 30; // initial credits
        u.usedCredits = 0;
        u.holdCoupons;
        users[msg.sender] = u;
        
        debug = users[msg.sender].unusedCredits;
        return msg.sender;
    }

    // Review Management functions
    function newReview(string memory receiptNo, string memory restName, string memory review)
        public accountExists notEmpty(receiptNo) notEmpty(restName) notEmpty(review){
        // calculate credit
        int reviewCredit = (users[msg.sender].unusedCredits + users[msg.sender].usedCredits)/10;
        // add review validity checking order to the backend
        string memory data = string(abi.encodePacked('{\n "author": "', st.toString(msg.sender), 
                                                    '",\n"restaurant": "', restName,
                                                    '",\n"content": "', review, 
                                                    '",\n"credits": "', st.int2str(reviewCredit),
                                                    '",\n"receipt": "', receiptNo,
                                                    '"\n} '));
        users[msg.sender].unusedCredits += reviewCredit;  // include into user's credit
        bck.uploadipfs('review', data, msg.sender, restName, receiptNo, reviewCredit, '');
    }
    
    function newComment(string memory receiptNo, address author, string memory receiptNo2, string memory restName, string memory comment, bool positive) public 
     accountExists notAuthor(author) notEmpty(receiptNo) notEmpty(restName) notEmpty(comment){
        this.commentDataUpload1(receiptNo, receiptNo2, msg.sender, restName, comment, positive); //commentor
        this.commentDataUpload2(receiptNo,receiptNo2, author, restName, msg.sender, positive); //author
    }
    
    function commentDataUpload1(string memory receiptNo, string memory receiptNo2, address sender, string memory restName, string memory comment, bool positive) public{
        string memory data = string(abi.encodePacked('{\n "review": "', receiptNo, 
                                                    '",\n"author": "', st.toString(sender),
                                                    '",\n"positive": "', st.trueOrFalse(positive), 
                                                    '",\n"comment": "',comment,
                                                    '",\n"restaurant": "', restName,
                                                     '",\n"receipt": "', receiptNo,
                                                    '"\n} '));
        users[sender].unusedCredits += (users[sender].unusedCredits + users[sender].usedCredits) / 30;  
        bck.uploadipfs('comment', data, sender, restName, receiptNo, (users[sender].unusedCredits + users[sender].usedCredits) / 30, receiptNo2);
    }
    
    function commentDataUpload2(string memory receiptNo, string memory receiptNo2, address author, string memory restName, address sender, bool positive) public { 
        int newCredit;
        if (positive==true){
            newCredit += (users[sender].unusedCredits + users[sender].usedCredits) / 15;
        }
        else{
            newCredit -= (users[sender].unusedCredits + users[sender].usedCredits) / 15;
        }
        
        users[author].unusedCredits += newCredit;
        string memory data = string(abi.encodePacked('{\n "receipt":"', receiptNo,
                                                      '",\n"rest": "', restName,
                                                     '",\n"credit": "', newCredit
                                                      ));
        bck.uploadipfs('reviewUpdate', data, sender, restName, receiptNo, newCredit, receiptNo2);
    }
    
    // Credit/Prize Management Functions
    function exchangePrizes() enoughCredit accountExists public{
        bytes32 queryId = fake_provable_query(60,"URL", st.append2("https://guarded-sands-73970.herokuapp.com/coupons/", st.toString(msg.sender)),500000);
        validIds[queryId] = Usage('prize', '', msg.sender, '', thres);
        fake_callback(queryId, st.int2str(count));
    }
    
    function useCoupon() public accountExists returns (string) {
        require (users[msg.sender].index < users[msg.sender].length);
        uint i = users[msg.sender].index;
        users[msg.sender].index += 1;
        return users[msg.sender].holdCoupons[i];
    }
    
    // Callback function
    // Handles with all callback actions from the off-chain results
    function fake_provable_query(uint time, string t, string addr, int amount) public returns (bytes32) {
        count += 1;
        return bytes32(count);
    }
    
    function fake_callback(bytes32 myid, string result){
        if (st.compareStrings(validIds[myid].use, 'prize')){
            // receipt Authentication
            users[validIds[myid].arg2].unusedCredits -= validIds[myid].arg4;
            users[validIds[myid].arg2].usedCredits += validIds[myid].arg4;
            users[validIds[myid].arg2].holdCoupons.push(result);
            users[validIds[myid].arg2].length += 1;
        }
        else{
        }
    }
    
}