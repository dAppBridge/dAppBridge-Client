pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets a cryptographicaly secure random string
// Using the dAppBridge.com service
// Start by calling startTesting
//

contract DappBridgeTester_randomString is clientOfdAppBridge {
    
    string public random_string = "";

    // Contract Setup
    address public owner;
    function DappBridgeTester_randomString() payable {
        owner = msg.sender;
    }
    function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
    }
    //
    
    // The key returned here can be matched up to the original response below
    function receiveRandomString(bytes32 key, string callbackData) external payable only_dAppBridge {
        random_string = callbackData;
    }
    

    function startTesting() public {
    	if(msg.sender == owner)
        	bytes32 newkey = randomString("receiveRandomString", 100, 0);
    }



}
