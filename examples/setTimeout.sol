pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which does something every 240 seconds
// Using the dAppBridge.com service
// Start by calling startTesting
// Contract will then run itself every 240 seconds
//

contract dAppBridgeTester_setTimeout is clientOfdAppBridge {
    
    int public callback_times = 0;

    // Contract Setup
    address public owner;
    function dAppBridgeTester_setTimeout() payable {
        owner = msg.sender;
    }
    function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
    }
    //
    
    // The key returned here can be matched up to the original response below
    function callback(bytes32 key) external payable only_dAppBridge{
        // Do somethiing here - your code...
        callback_times++;

        // If we want to continue running, call setTimeout again...
        bytes32 newkey = setTimeout("callback", 240);
    }
    

    function startTesting() public {
        if(msg.sender == owner)
            bytes32 newkey = setTimeout("callback", 0);
    }
}
