pragma solidity ^0.4.16;

import "github.com/dAppBridge/dAppBridge-Client/dAppBridge-Client_Kovan.sol";

contract DappBridgeTester_randomNumberDiceRoll is clientOfdAppBridge {
    

    // Contract Setup
    address public owner;
    function DappBridgeTester_randomNumberDiceRoll() payable {
        owner = msg.sender;
    }
    function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
    }
    //
    
    mapping(bytes32 => address) internal playerAddress;
    mapping(bytes32 => bytes32) internal playerKey;
    mapping(bytes32 => int) internal playerResultRandomNumber;
    
    event dicerollResult(
            address playerAddress,
            bytes32 playerKey,
            int playerResultRandomNumber
        );
    function callback(bytes32 key, int callbackData) external payable only_dAppBridge {

        playerResultRandomNumber[key] = callbackData;
        // You can now process the result of the dice roll...
        // E.g. log out as an event so you can pick it up through web3
        emit dicerollResult(
                playerAddress[key],
                playerKey[key],
                playerResultRandomNumber[key]
            );
    }
    

    function rollDice() public {
        bytes32 newkey = randomNumber("callback", 1, 100, 0);
        playerAddress[newkey] = msg.sender;
        playerKey[newkey] = newkey;
        // You would have other variable here in a real game (Amount bet etc)
        
    }



}
