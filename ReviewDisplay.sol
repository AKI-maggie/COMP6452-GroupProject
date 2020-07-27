pragma solidity ^0.4.24;
import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";


contract DisplayReviews is usingProvable{
    
    string public reviewResult;
    event LogConstructorInitiated(string nextStep);
    event LogNewProvableQuery(string description);
    
    constructor() payable public {
        provable_setProof(proofType_Android | proofStorage_IPFS);
        LogConstructorInitiated("Constructor was initiated. Call 'ReviewIPFSHash()' to send the Provable Query.");
    }
    
    function __callback(bytes32 queryId, string result) public {
        if (msg.sender != provable_cbAddress()) revert();
        
        reviewResult = result;
    }
    
    // Result expected is - ["KFC", "good", "Subway", "good", "OliverBrown", "good", "CoffeeOnCampus", "good", "McDonalds", "Cold burger"];
    function displayReview() payable public {
        
        if (provable_getPrice("nested") > this.balance) {
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
       } 
       
       else {
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           bytes32 query_id = provable_query("nested", "[IPFS] json(${[URL] json(https://guarded-sands-73970.herokuapp.com/records/ipfs).Reviews}).result..[restaurant, content]");
       }
    }

    
    
    
}
   
   



