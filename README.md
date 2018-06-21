# dAppBridge - bringing smart contracts alive

An easy, yet powerful Ethereum Oracle service that makes it easy to bring your smart contract online - providing one line access to Internet API data!

* Connect Smart Contracts to Internet APIs with Secure Proof that returned data is as requested
* Request data from any public URL, with Proof that the data has not been tampered with
* setTimeout now available for solidity smart contracts! Have your methods called automatically as set periods
* Generate Random Numbers for your solidity contracts
* Generate True Cryptographic strings within your solidity smart contracts

http://dappbridge.com

**dAppBridge** is a data oracle service bridging the gap between smart contracts and the public Internet.  With a simple call to dAppBridge you can can interface with any public API or URL - with secure proof that the data returned has not been tampered with.  

dAppBridge also provided additional services such as Random Number generation and Cryptographic Random String generation - again with secure proof that the return values have not been tempered with and are as you requested.

## Secure Data Validation & Proof

All data responses are secured with a  proof that the data returned from any API or URL has not been tampered with – to ensure this we use our 3rd party hosted NotaryProxy which is a full audit-able service that allows you to easily confirm each result is correct and valid (See: https://github.com/dAppBridge/NotaryProxy).

For every single response you receive – you can personally inspect the result and validate its proof… to ensure the data you receive into your smart contract is the same data that was returned from the URL or API (See: https://github.com/dAppBridge/NotaryProxy#how-it-works for a full guide).

This keeps the service honest and audit-able – by using the NotaryProxy there is no way the dAppbridge service could alter the result without you being aware!


## How it works

Simply add the correct client import to your contract (Depending on whether you are testing on the Kovan or Ropsten testnet, or when you are ready to go for full production):

**Testnet (Kovan)**
```
import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";
```
**Testnet (Ropsten)**
```
import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Ropsten.sol";
```
**Production**
```
import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client.sol";
```

Your contract method should be **is clientOfdAppBridge**, e.g.

```
contract DappBridgeTester is clientOfdAppBridge {

```

Add a callback method - this will be where the returned data will be received (E.g. Any API response):

```
	string api_response; 
   	function callback(string requestKey, string callbackData) external payable only_dAppBridge {
    	api_response = callbackData;
	}
```


And then finally, simply make the request:

```
	callURL("callback", "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.usd.rate");
```

Or if you wanted this to run on a timer, then a full example contract would look like:

```
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
    
    // The key returned here can be matched up to the original response below
    function callback(bytes32 key, string callbackData) external payable only_dAppBridge {
        usd_btc_rate = callbackData;
        bytes32 newkey = setURLTimeout("callback", 240, "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }
    

    function startTesting() public {
        if(msg.sender == owner)
            bytes32 newkey = setURLTimeout("callback", 0, "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }



}
```

We've used a full version of the dAppBridge->setURLTimeout method in the above example - which allows us to select a JSON element from the data returned (Here we are selecting "bpi.usd.rate").  This is an optional paramater, but can be really useful as it can be difficult to extract data once it is within your contract and helps save you gas and computation time - we do the heavy lifting for you.

### Breaking this contract down...

The entry point for the above contract is the method **startTesting**  This makes a call to the **dAppBridge** method **setURLTimeout**  See below for the full guide to this method, but it basically calls an external URL and returns the data (At the set timeout interval) to the callback method specified - function "callback" in this case.

The callback function (**callback**) must confirm to the correct signature (**bytes32,string**) and should be set to **payable**  This is to allow any remaining gas to be refunded to you.  They **key** item returned here allows you to match up all the responses with the requests you've made... each time you make a request to any dAppBridge function you will be given a unique key back for that request.  When you receive the callback the same key will be presented back to you.

You will notice the modifier **only_dAppBridge** here too... this is a key element and is what ensures that no malicious actor can send through false data to your callback functions.  Only data that you have requested will be permitted back through... if you have requested data from https://api.coindesk.com/v1/bpi/currentprice.json then you can be sure that the data returned will be from that address and only for your request.  See below for further details on security.






## dAppBridge Request Methods Available

### setTimeout

```setTimeout(string callback_method, uint32 timeout)```

* callback_method: The name of your function you want to call on the timeout interval, just the name - no params (E.g. "callback")
* timeout: Timeout interval in seconds

A simple method similar to the JavaScript method setTimeout allowing you to time requests to your Solidity Smart Contracts methods.


The signature for a timeout method is a simple method with one param (bytes32 key), with our unique protection modifier **only_dAppBridge**

Example:

```
pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which does something every 240 seconds
// Using the dAppBridge.com service
// Start by calling startTesting
// Contract will then run itself every 240 seconds
//

contract DappBridgeTester is clientOfdAppBridge {
    
    string usd_btc_rate = "";
    
    function callback(bytes32 key) external payable only_dAppBridge {
        // Do somethiing here - your code...

        // Setup your constructors here
        // CONSTRUCTOR CODE
        //

        // If we want to continue running, call setTimeout again 
        // (Safe in the knowledge that nobody else can call this function as it is protected with only_dAppBridge!)
        bytes32 newkey = setTimeout("callback", 240);
    }
    

    function startTesting() public {
        bytes32 newkey = setTimeout("callback", 0);
    }



}
```
See the full example of this: https://github.com/dAppBridge/dAppBridge-Client/blob/master/examples/setTimeout.sol


### callURL

```callURL(string callback_method, string external_url, string external_params, [string json_extract_elemen])```

* callback_method: The name of your function you want to call on timeout, just the name - no params (E.g. "callback")
* external_url: The full name of the URL to be requested (E.g. https://www.google.com/)
* external_params: Any params to be send via POST to the URL - otherwise a GET request will be used
* json_extract_element OPTIONAL If provided then any response from the API will be JSON parsed and the element provided here will be extracted and returned instead of the full response (Up to 10 levels deep permitted)

Request an Internet URL or API via GET or POST (POST if external_params provided) and return the response (Or selected JSON element if json_extract_element is provided).

The callback function should have the signature:

```
yourmethodname(bytes32, string) external payable only_dAppBridge
```

The callback is set payable to allow dAppBridge to return any unused gas back to you after all processing.  The **only_dAppBridge** modifier is the critical security element which protects your callback function from any malicious actor from calling it with malicious data - and trying to poison your contract.  See below for further details on security.

Example:

```
pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets the BTC/USD rate from Coindesk
// Using the dAppBridge.com service
// Start by calling startTesting
//

contract DappBridgeTester is clientOfdAppBridge {
    
    string public usd_btc_rate = "";

    // Setup your constructors here
    
    function callback(bytes32 key, string callbackData) external payable only_dAppBridge {
        usd_btc_rate = callbackData;
    }
    

    function startTesting() public {
        bytes32 newkey = callURL("callback", "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }



}
```
See the full example of this: https://github.com/dAppBridge/dAppBridge-Client/blob/master/examples/callurl.sol

### setURLTimeout

```setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params, [string json_extract_elemen])```

* callback_method: The name of your function you want to call on the timeout interval, just the name - no params (E.g. "callback")
* timeout: Timeout in seconds
* external_url: The full name of the URL to be requested (E.g. https://www.google.com/)
* external_params: Any params to be send via POST to the URL - otherwise a GET request will be used
* json_extract_element OPTIONAL If provided then any response from the API will be JSON parsed and the element provided here will be extracted and returned instead of the full response

Request an Internet URL or API after a set number of seconds (Setting timeout to 0 results in calling the URL immediately) via GET or POST (POST if external_params provided) and return the response (Or selected JSON element if json_extract_element is provided).

The callback function should have the signature:

```
yourmethodname(bytes32, string) external payable only_dAppBridge
```

The callback is set payable to allow dAppBridge to return any unused gas back to you after all processing.  The **only_dAppBridge** modifier is the critical security element which protects your callback method from any malicious actor from calling it with malicious data - and trying to poison your contract.  See below for further details on security.

Example:

```
pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets the BTC/USD rate from Coindesk every 240 seconds
// Using the dAppBridge.com service
// Start by calling startTesting
// Contract will then run itself every 240 seconds
//

contract DappBridgeTester is clientOfdAppBridge {
    
    string public usd_btc_rate = "";

    // Setup your constructors here
    
    function callback(bytes32 key, string callbackData) external payable only_dAppBridge {
        usd_btc_rate = callbackData;
        bytes32 newkey = setURLTimeout("callback", 240, "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }
    

    function startTesting() public {
        bytes32 newkey = setURLTimeout("callback", 0, "https://api.coindesk.com/v1/bpi/currentprice.json", "", "bpi.USD.rate");
    }



}
```
See the full example of this: https://github.com/dAppBridge/dAppBridge-Client/blob/master/examples/setURLTimeout.sol

### randomNumber

```randomNumber(string callback_method, int32 min_val, int32 max_val, uint32 timeout)```

* callback_method: The name of your function you want the random number returned to, just the name - no params (E.g. "callback")
* min_val: The minimum value you would like the random number to start from
* max_val: The maximum value you would like the random number to be
* timeout: Timeout in seconds, when to call the randomNumber. Set to 0 to call immediately

Requests a random number from dAppBridge.

The callback function signature should be:

```
functionname(bytes32 key, int callbackData) external payable only_dAppBridge
```

The callback is set payable to allow dAppBridge to return any unused gas back to you after all processing.  The **only_dAppBridge** modifier is the critical security element which protects your callback method from any malicious actor from calling it with malicious data - and trying to poison your contract.  See below for further details on security.

Example:

```
pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets a random number between 1 and 100
// Using the dAppBridge.com service
// Start by calling startTesting
//

contract DappBridgeTester is clientOfdAppBridge {
    
    uint32 public random_number = 0;

    // Setup your constructors here
    
    function callback(bytes32 key, int callbackData) external payable only_dAppBridge {
        random_number = callbackData;
    }
    

    function startTesting() public {
        bytes32 newkey = randomNumber("callback", 1, 100, 0);
    }



}
```
See the full example of this: https://github.com/dAppBridge/dAppBridge-Client/blob/master/examples/randomNumber.sol

### randomString

```randomString(bytes32 key, string callback_method, uint8 number_of_bytes, uint32 timeout)```

* callback_method: The name of your function you want the random string returned to, just the name - no params (E.g. "callback")
* number_of_bytes: The size in bytes you would like the randomString to be (E.g. 100)
* timeout: Timeout in seconds, when to call the randomString. Set to 0 to call immediately

Requests a random byte string which is cryptographically secure.  Size is set in number of bytes.

The callback function signature should be:

```
functionname(bytes32, string) external payable only_dAppBridge
```

The callback is set payable to allow dAppBridge to return any unused gas back to you after all processing.  The **only_dAppBridge** modifier is the critical security element which protects your callback method from any malicious actor from calling it with malicious data - and trying to poison your contract.  See below for further details on security.

Example:

```
pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

//
// Simple contract which gets a random number between 1 and 100
// Using the dAppBridge.com service
// Start by calling startTesting
//

contract DappBridgeTester is clientOfdAppBridge {
    
    string public random_string = "";

    // Setup your constructors here
    
    function receiveRandomString(bytes32 key, string callbackData) external payable only_dAppBridge {
        random_string = callbackData;
    }
    

    function startTesting() public {
        bytes32 newkey = randomString("receiveRandomString", 100, 0);
    }



}
```
See the full example of this: https://github.com/dAppBridge/dAppBridge-Client/blob/master/examples/randomString.sol


## Pricing

Using **dAppBridge** is made up of 3 parts...

1. The Gas used to make a request to dAppBridge as you normally would pay to any other external contract
2. The Gas used by dAppBridge processing your request - such as passing data back to your callback
3. Our fee for providing the dAppBridge service

When you make a request to any of the above methods all of the above is sent from your contract automatically for you.

### Part 1

Currently set at 200,000 wei.  Remember any Gas unused on a request is refunded.  

If you wish to change the amount of gas used on your part of the request use the method:

```
	setGas(new_gas)
```

In most cases you will not need to change this value.

### Part 2

The gas required to process your request.  This is set by ourselves and depends on the type of request you are making:

* Random Number or Callback requests: 100,000
* URL Request: 200,000

If your callback function requires a lot of gas, you will likely need to extend this to ensure it completes and does not run out of gas.  To manually set the gas use the method:

```
    setCallbackGas(new_callback_gas)
```

***Note*** Using this method will add gas **onto** the existing gas already set by dAppBridge (100,000 or 200,000 - see above).  It should be used if your callback function does any processing other than storing the result.

### Part 3

Priced depending on the type of request:

Request Type | Cost
-------------|------
setTimeout| 51,000 Gwei
callURL| 70,000 Gwei
setURLTimeout| 70,000 Gwei
randomNumber| 51,000 Gwei
randomString| 51,000 Gwei

### Refunds

Any gas remaining from Parts 1 and 2 after all processing and callback estimated gas requirements are refunded back to your contract automatically.  This makes it safer to overload Part 2 with more gas to ensure your method is called if you are unsure of your requirements or you are doing any complex processing.  If you do not supply enough gas there is a risk your callback will fail and refunds for Part 3 (Our fee) are not possible due to the transactional nature of Ethereum.

## Security By Design

**dAppBridge** works by ensuring that any data returned to your smart contract is always confirmed and verified to only return through our secure channel.  By using the secure **only_dAppBridge** modifier on your callback functions, you can be sure that any data (Or timeout callbacks) are only made by the dAppBridge service and not being made by any malicious actors.  This ensure that the data returned has not been tampered with.

All requests made to public URLs or APIs are now passed through the new NotaryProxy service -> This fully audit-able service allows anyone to confirm returned data has not been altered in transit - by the dAppBridge service or any other malicious actor.  You can be sure the data you receive into your dApp is correct and as originally returns from the API endpoint!

See https://github.com/dAppBridge/NotaryProxy for full detail on how the Notary Proxy validates your data.

This secure by design approach ensures that no malicious actor can send through false data to any of your callback functions.  Only true and verified data can be received.

The callback infrastructure that makes the requests for your contracts runs on a secure distributed architecture hosted on Amazon Web Services (AWS)... using de-coupled modules it is fully fault tolerant and able to scale up as demand requires.

## Contact

Get in touch!  We're here to help, answer questions, hear your suggetions and feedback!

dapps@dappbridge.com

https://twitter.com/dAppBridge



