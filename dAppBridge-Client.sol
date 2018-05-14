pragma solidity ^0.4.16;

interface dAppBridge_I {
    function getMinReward(string requestType) external returns(uint256);
    function getMinGas() external returns(uint256);    
    function setTimeout(string callback_method, uint32 timeout) external payable;
    function setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params) external payable;
    function callURL(string callback_method, string external_url, string external_params) external payable;
    function randomNumber(string callback_method, int32 min_val, int32 max_val, uint32 timeout) external payable;
    function randomString(string callback_method, uint8 number_of_bytes, uint32 timeout) external payable;
}
contract DappBridgeLocator_I {
    function currentLocation() public returns(address _addr);
}

contract clientOfdAppBridge {
    address internal _dAppBridgeLocator_addr = 0x4032bFffc5b3C4e6957c695bf6D3557D468d84b4;
    address internal dAppBridge_location;
    DappBridgeLocator_I internal dAppBridgeLocator;
    dAppBridge_I internal dAppBridge; 
    uint256 internal current_gas = 0;
    uint256 internal user_callback_gas = 0;

    modifier dAppBridgeClient {
        if(address(dAppBridgeLocator) == 0){
            // init...
            dAppBridgeLocator = DappBridgeLocator_I(_dAppBridgeLocator_addr);
        }

        if(dAppBridge_location != dAppBridgeLocator.currentLocation()) {
            dAppBridge = dAppBridge_I(dAppBridgeLocator.currentLocation());
            dAppBridge_location = dAppBridgeLocator.currentLocation();
        }
            
        if(current_gas < 1) {
            // init
            current_gas = dAppBridge.getMinGas();
        }


        _;
    }
    
    modifier only_dAppBridge {
        if(address(dAppBridgeLocator) == 0){
            // init...
            dAppBridgeLocator = DappBridgeLocator_I(_dAppBridgeLocator_addr);
        }

        if(dAppBridge_location != dAppBridgeLocator.currentLocation()) {
            dAppBridge = dAppBridge_I(dAppBridgeLocator.currentLocation());
            dAppBridge_location = dAppBridgeLocator.currentLocation();
        }
            
        require(msg.sender == dAppBridge_location);
        
        _;
    }
    
    function setGas(uint256 new_gas) internal {
        require(new_gas > 0);
        current_gas = new_gas;
    }

    function setCallbackGas(uint256 new_callback_gas) internal {
        require(new_callback_gas > 0);
        user_callback_gas = new_callback_gas;
    }

    
    function getMinReward(string requestType) internal dAppBridgeClient returns(uint256)  {
        return dAppBridge.getMinReward(requestType)+user_callback_gas;
    }

    function setTimeout(string callback_method, uint32 timeout) internal dAppBridgeClient {
        return dAppBridge.setTimeout.value(getMinReward('setTimeout')).gas(current_gas)(callback_method, timeout);
    }
    function setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params) internal dAppBridgeClient {
        return dAppBridge.setURLTimeout.value(getMinReward('setURLTimeout')).gas(current_gas)(callback_method, timeout, external_url, external_params);
    }
    function callURL(string callback_method, string external_url, string external_params) internal dAppBridgeClient {
        return dAppBridge.callURL.value(getMinReward('callURL')).gas(current_gas)(callback_method, external_url, external_params);
    }
    function randomNumber(string callback_method, int32 min_val, int32 max_val, uint32 timeout) internal dAppBridgeClient {
        return dAppBridge.randomNumber.value(getMinReward('randomNumber')).gas(current_gas)(callback_method, min_val, max_val, timeout);
    }
    function randomString(string callback_method, uint8 number_of_bytes, uint32 timeout) internal dAppBridgeClient {
        return dAppBridge.randomString.value(getMinReward('randomString')).gas(current_gas)(callback_method, number_of_bytes, timeout);
    }
}
