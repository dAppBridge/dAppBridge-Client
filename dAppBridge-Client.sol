pragma solidity ^0.4.16;

interface dAppBridge_I {
    function getOwner() external returns(address);
    function getMinReward(string requestType) external returns(uint256);
    function getMinGas() external returns(uint256);    
    function setTimeout(string callback_method, uint32 timeout) external payable;
    function setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params, string json_extract_element) external payable;
    function callURL(string callback_method, string external_url, string external_params, string json_extract_element) external payable;
    function randomNumber(string callback_method, int32 min_val, int32 max_val, uint32 timeout) external payable;
    function randomString(string callback_method, uint8 number_of_bytes, uint32 timeout) external payable;
}
contract DappBridgeLocator_I {
    function currentLocation() public returns(address);
}

contract clientOfdAppBridge {
    address internal _dAppBridgeLocator_Prod_addr = 0x5b63e582645227F1773bcFaE790Ea603dB948c6A;
    
    DappBridgeLocator_I internal dAppBridgeLocator;
    dAppBridge_I internal dAppBridge; 
    uint256 internal current_gas = 0;
    uint256 internal user_callback_gas = 0;
    
    function initBridge() internal {
        //} != _dAppBridgeLocator_addr){
        if(address(dAppBridgeLocator) != _dAppBridgeLocator_Prod_addr){ 
            dAppBridgeLocator = DappBridgeLocator_I(_dAppBridgeLocator_Prod_addr);
        }
        
        if(address(dAppBridge) != dAppBridgeLocator.currentLocation()){
            dAppBridge = dAppBridge_I(dAppBridgeLocator.currentLocation());
        }
        if(current_gas == 0) {
            current_gas = dAppBridge.getMinGas();
        }
    }

    modifier dAppBridgeClient {
        initBridge();

        _;
    }

    // Ensures that only the dAppBridge system can call the function
    modifier only_dAppBridge {
        initBridge();
        address _dAppBridgeOwner = dAppBridge.getOwner();
        require(msg.sender == _dAppBridgeOwner);

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

    

    function setTimeout(string callback_method, uint32 timeout) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('setTimeout')+user_callback_gas;
        dAppBridge.setTimeout.value(_reward).gas(current_gas)(callback_method, timeout);

    }
    function setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('setURLTimeout')+user_callback_gas;
        dAppBridge.setURLTimeout.value(_reward).gas(current_gas)(callback_method, timeout, external_url, external_params, "");

    }
    function setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params, string json_extract_element) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('setURLTimeout')+user_callback_gas;
        dAppBridge.setURLTimeout.value(_reward).gas(current_gas)(callback_method, timeout, external_url, external_params, json_extract_element);
    }
    function callURL(string callback_method, string external_url, string external_params) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('callURL')+user_callback_gas;
        dAppBridge.callURL.value(_reward).gas(current_gas)(callback_method, external_url, external_params, "");
    }
    function callURL(string callback_method, string external_url, string external_params, string json_extract_elemen) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('callURL')+user_callback_gas;
        dAppBridge.callURL.value(_reward).gas(current_gas)(callback_method, external_url, external_params, json_extract_elemen);
    }
    function randomNumber(string callback_method, int32 min_val, int32 max_val, uint32 timeout) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('randomNumber')+user_callback_gas;
        dAppBridge.randomNumber.value(_reward).gas(current_gas)(callback_method, min_val, max_val, timeout);
    }
    function randomString(string callback_method, uint8 number_of_bytes, uint32 timeout) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('randomString')+user_callback_gas;
        dAppBridge.randomString.value(_reward).gas(current_gas)(callback_method, number_of_bytes, timeout);
    }

}
