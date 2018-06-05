pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets a random number between 1 and 100
// Using the dAppBridge.com service
// Start by calling startTesting
//

contract DappBridgeTester_randomNumber is clientOfdAppBridge {
    
    int256 public random_number = 0;

    // Contract Setup
    address public owner;
    function DappBridgeTester_randomNumber() payable {
        owner = msg.sender;
    }
    function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
    }
    //
    
    function callback(int callbackData) external payable only_dAppBridge {
        random_number = callbackData;
    }
    

    function startTesting() public {
    	if(msg.sender == owner)
        	randomNumber("callback", 1, 100, 0);
    }



}
