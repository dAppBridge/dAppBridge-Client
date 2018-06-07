pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets the BTC/USD rate from Coindesk every 240 seconds
// Using the dAppBridge.com service
// Start by calling startTesting
// Contract will then run itself every 240 seconds
//

contract dAppBridgeTester_callurl is clientOfdAppBridge {
    
    string public usd_btc_rate = "";

    // Contract Setup
    address public owner;
    function dAppBridgeTester_callurl() payable {
        owner = msg.sender;
    }
    function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
    }
    //
    
    // The key returned here can be matched up to the original response below
    function callback(bytes32 key, string callbackData) external payable only_dAppBridge {
        usd_btc_rate = callbackData;
    }
    

    function startTesting() public {
        if(msg.sender == owner)
            bytes32 newkey = callURL("callback", "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }



}
