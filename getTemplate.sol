pragma solidity ^0.4.22;
import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract ExampleContract is usingProvable {
   using strings for *;
   string public Receipt_Status;
   string public link;
   string public s3;
   event LogConstructorInitiated(string nextStep);
   event LogPriceUpdated(string price);
   event LogNewProvableQuery(string description);

   function ExampleContract() payable {
       LogConstructorInitiated("Constructor was initiated. Call 'getStatus()' to send the Provable Query.");
   }

   function __callback(bytes32 myid, string result) {
       if (msg.sender != provable_cbAddress()) revert();
       Receipt_Status = result;
       LogPriceUpdated(result);
   }
   
   function append(string a, string b, string c, string d, string e) internal pure returns (string) {

        return string(abi.encodePacked(a, b, c, d, e));

   }

   function getStatus(string restaurant, string receipt_N) payable {
       if (provable_getPrice("URL") > this.balance) {
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
       } else {
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           link = "json(https://guarded-sands-73970.herokuapp.com/records/" ;
           s3 = append(link,restaurant,"/",receipt_N,  ").results.status");
           //provable_query("URL", "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).time");
           provable_query("URL", s3);
       }
   }
}
