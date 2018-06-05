pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets the BTC/USD rate from Coindesk every 240 seconds
// Using the dAppBridge.com service
// Start by calling startTesting
// Contract will then run itself every 240 seconds
//

contract dAppBridgeTester_setURLTimeout is clientOfdAppBridge {
    
    string public usd_btc_rate = "";

    // Contract Setup
    address public owner;
    function dAppBridgeTester_setURLTimeout() payable {
        owner = msg.sender;
    }
    function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
    }
    //
    
    function callback(string callbackData) external payable only_dAppBridge {
        usd_btc_rate = callbackData;
        setURLTimeout("callback", 240, "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }
    

    function startTesting() public {
    	if(msg.sender == owner)
        	setURLTimeout("callback", 0, "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }



}
