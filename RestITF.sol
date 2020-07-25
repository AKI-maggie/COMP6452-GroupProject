// pragma solidity ^0.6.0;

// contract RestITF {
    
//     /**
//      * Structures for the restaurant and coupon
//      **/
    
//     struct Restaurant {
//         uint restId;                // restaurant Id
//         string restName;            // restaurant name
//     }

//     struct Coupon { 
//         string restName;          // restaurant providing that coupon
//         uint c_value;                 // coupon value
//     }
    
//     mapping (address => Restaurant ) private restUser;         // List of restaurant users
//     mapping (uint => uint ) private coupons;                // List of coupons (based of coupon id)
    
//     /**
//      * Modifiers 
//      **/
     
//     modifier accountExists(){
//         require(bytes(restUser[msg.sender].restName).length != 0);
//         _;
//     }

//     modifier accountNotExists(){
//         require(bytes(restUser[msg.sender].restName).length == 0);
//         _;
//     }

//     modifier notEmptyString(string memory content) {
//         require(bytes(content).length != 0);
//         _;
//     }
    
//     /**
//     * Functions
//     **/
//     // constructor
    
//     // Register restaurant user
//     function register(string memory name) public accountNotExists notEmptyString(name) returns (bool) {

//         Restaurant memory r;
//         r.restName = name;

//         restUser[msg.sender] = r;
//         return true;
//     }
    

//     // Coupon Registry
//     // return true if user successfully recorded
//     // else return false
//     function couponRegister(string memory name) public accountExists notEmptyString(name) returns (bool) {
//         // if (bytes(c_value).length == 0){
//         //     return false;
//         // }
//         return true;
//     }
// }

pragma solidity ^0.6.0;

contract RestITF{
    
    /**
     * Structures
    **/
    
    struct Restaurant {
        string restName;                    // Restaurant name
        uint rest_id;                        // Restaurant Id
    }
    
    struct Coupon {
        uint coupon_id;                      // Coupon Id
        string restName;                    // Restaurant name
        uint value;                         // Coupon Value
    }
    
    mapping ( address => Restaurant ) public restaurant;
    mapping ( uint => Coupon) public coupons;
    
    /** 
     * Modifiers
    **/
    
    modifier accountNotExists() {
        require(bytes(restaurant[msg.sender].restName).length == 0);
        _;
    }
    
    modifier accountExists() {
        require(bytes(restaurant[msg.sender].restName).length != 0);
        _;
    }
    
    modifier notEmptyString(string memory content) {
        require(bytes(content).length != 0);
        _;
    }
    
    /**
     * Functions
    **/
    
    uint public rest_id = 0;
    uint public coupon_id = 0;
    uint public numCoupons = 0; // for coupons array
    
    function restaurantRegister(string memory restName) public accountNotExists notEmptyString(restName) returns (bool) {
        
        Restaurant memory r;
        r.restName = restName;
        r.rest_id = rest_id++;
        
        restaurant[msg.sender] = r;
        return true;
    }
    
    
    function couponRegister( string memory restName, uint value) public accountExists notEmptyString(restName) returns (uint) {
    
        Coupon memory c;
        
        c.restName = restName;
        c.value = value;
        c.coupon_id= coupon_id++;
        
        coupons[numCoupons] = c;
        numCoupons++;
        
        return numCoupons;
        
    }
    
}