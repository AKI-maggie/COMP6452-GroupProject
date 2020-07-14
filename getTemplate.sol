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
   bool public Used;
   string public RequestResult;
   string public receipt;
   string public test;
   string public link;
   string public s3;
   
   event LogConstructorInitiated(string nextStep);
   event LogPriceUpdated(string price);
   event LogNewProvableQuery(string description);
   

 function handlePayment(address senderAddress) payable public {
      // senderAddress in this example could be removed since msg.sender can be used directly
  }
  
   function GetStatus() payable public{
       provable_setCustomGasPrice(4000000000);
       LogConstructorInitiated("Constructor was initiated. Call 'getStatus()' to send the Provable Query.");
   }

   function __callback(bytes32 myid, string result) {
       if (!validIds[myid]) revert();
       if (msg.sender != provable_cbAddress()) revert();
    //   require (pendingQueries[myid] == true);
       if (compareStrings(result, "false")){
            Used = false;
       }
       else{
           Used = true;
       }
       // empty result - no such receipt / false - not used / true - used
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

   function status() public view returns (bool){
       return (Used);
   }
   
   function append(string a, string b, string c, string d, string e) internal pure returns (string) {

        return string(abi.encodePacked(a, b, c, d, e));

   }
   
   
   
    function compareStrings (string memory a, string memory b) public view 
       returns (bool) {
            return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );

       }
   // REQUEST TO GET RECIEPT STATUS , NEED TO PAY AT LEAST 0.000175 ETHER TO CALL. REMEMBER TO SET THE TRANSACTION COST ETHER!!!!!
   function getStatus(string restaurant, string receipt_N) payable {
        require(msg.value >= 0.000175 ether);
        link = "json(https://guarded-sands-73970.herokuapp.com/records/" ;
        s3 = append(link,restaurant,"/",receipt_N,  ").results.status");
        receipt = receipt_N;
       if (provable_getPrice("URL") > this.balance) {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
           requestPrice = provable_getPrice("URL");
           AvaBalance = address(this).balance;
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           //provable_query("URL", "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).time");
           bytes32 queryId = provable_query(60,"URL", s3,175000);
           validIds[queryId] = true;
       }
       
   }
   // DEPEND ON THE RETURN RECEIPT STATUS REQUEST TO CHANGE RECIEPT STATUS TO USED, NEED TO PAY AT LEAST 0.0008 ETHER TO CALL. REMEMBER TO SET THE TRANSACTION COST ETHER!!!!!    
    function changeStatus() payable {
       require(msg.value >= 0.0008 ether);
      if(Used == false){
        link = string(abi.encodePacked('{"receipt_num": "', receipt, '"}'));
        
        if (provable_getPrice("URL") > this.balance) {
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           bytes32 queryId = provable_query("URL", "json(https://guarded-sands-73970.herokuapp.com/records).success.deposit",
  link);
           validIds[queryId] = true;
        }
      }
      else{
           test = "used is true";
       }
    }

}
// BELOW IS THE CONTRACT TRY TO USE THE ABOVE CONTRACT NOT USED AT ALL. COULD BE CONSIDERED AS AN EXAMPLE
contract PayMain is usingProvable {
   GetStatus main;
   bool public status;
   string public ETHUSD;
   mapping(bytes32=>bool) validIds;
   event LogConstructorInitiated(string nextStep);
   event LogPriceUpdated(string price);
   event LogNewProvableQuery(string description);
  
  function PayMain(address _m) payable{
     LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Provable Query.");
     main = GetStatus(_m);
  }
  function () payable {
    // Call the handlePayment function in the main contract
    // and forward all funds (msg.value) sent to this contract
    // and passing in the following data: msg.sender
    main.handlePayment.value(msg.value)(msg.sender);
    
  }
  
  
    function __callback(bytes32 myid, string result) {
        if (!validIds[myid]) revert();
        if (msg.sender != provable_cbAddress()) revert();
        ETHUSD = result;
        LogPriceUpdated(result);
        delete validIds[myid];
    }

  
  function changeStatus(string restaurant, string receipt_N) payable{
      main.getStatus(restaurant, receipt_N);
      status = main.status();
      if (status == false){
        if (provable_getPrice("URL") > this.balance) {
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           bytes32 queryId = provable_query("URL", "json(https://guarded-sands-73970.herokuapp.com/records)",
  '{"receipt_num":receipt_N}');
           validIds[queryId] = true;
       }
      }
  }
}
