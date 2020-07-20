pragma solidity ^0.4.22;
import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract GetStatus is usingProvable {
   using strings for *;
   uint availableFunds;
   uint256 public AvaBalance;
   mapping(bytes32=>bool) validIds;
   event Received(uint);
   uint256 public requestPrice;
   string public RequestResult;
   string public receipt;
   string public test;
   string public link;
   string public s3;
   
   event LogConstructorInitiated(string nextStep);
   event LogPriceUpdated(string price);
   event LogNewProvableQuery(string description);
  
   function GetStatus() payable public{
       provable_setCustomGasPrice(4000000000);
       LogConstructorInitiated("Constructor was initiated. Call 'getStatus()' to send the Provable Query.");
   }

   function __callback(bytes32 myid, string result) {
       if (!validIds[myid]) revert();
       if (msg.sender != provable_cbAddress()) revert();
       // empty result - no such receipt / nonempty result - receipt exists
       RequestResult = result;
       LogPriceUpdated(result);
       delete validIds[myid];
     //  delete pendingQueries[myid];
   }
   
    function() payable{
        // nothing else to do!
    }
    
     function getBalance() public view returns (uint256) {
        AvaBalance = address(this).balance;
        return address(this).balance;
    }
   
   function append(string a, string b, string c, string d, string e) internal pure returns (string) {

        return string(abi.encodePacked(a, b, c, d, e));

   }
   
   // REQUEST TO GET RECIEPT STATUS , NEED TO PAY AT LEAST 0.000175 ETHER TO CALL. 
   // REMEMBER TO SET THE TRANSACTION COST ETHER!!!!!
   function getStatus(string restaurant, string receipt_N) payable {
        require(msg.value >= 0.000175 ether);
        link = "json(https://guarded-sands-73970.herokuapp.com/records/" ;
        s3 = append(link,restaurant,"/",receipt_N,  ").result");
        receipt = receipt_N;
       if (provable_getPrice("URL") > this.balance) {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           bytes32 queryId = provable_query(60,"URL", s3,175000);
           validIds[queryId] = true;
       }
       
   }
}
