pragma solidity ^0.4.16;

interface dAppBridge_I {
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
    address internal _dAppBridgeLocator_Rinkeby_addr = 0x470460C5A05EBE1cF7106Fc55Cda378eb9D58691;
    address internal _dAppBridgeLocator_Ropsten_addr = 0x00;
    address internal _dAppBridgeLocator_Kovan_addr = 0x00;
    address internal _dAppBridgeLocator_Prod_addr = 0x00;
    
    DappBridgeLocator_I internal dAppBridgeLocator;
    dAppBridge_I internal dAppBridge; 
    uint256 internal current_gas = 0;
    uint256 internal user_callback_gas = 0;
    
    function initBridge() internal {
        //} != _dAppBridgeLocator_addr){
        if(address(dAppBridgeLocator) != _dAppBridgeLocator_Rinkeby_addr){ 
            dAppBridgeLocator = DappBridgeLocator_I(_dAppBridgeLocator_Rinkeby_addr);
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
    

    event event_senderAddress(
        address senderAddress
    );
    
    event evnt_dAdppBridge_location(
        address theLocation
    );
    
    event only_dAppBridgeCheck(
        address senderAddress,
        address checkAddress
    );
    
    modifier only_dAppBridge {
        initBridge();
        
        //emit event_senderAddress(msg.sender);
        //emit evnt_dAdppBridge_location(address(dAppBridge));
        emit only_dAppBridgeCheck(msg.sender, address(dAppBridge));
        require(msg.sender == address(dAppBridge));
        _;
    }
    
    event verifyProofEvent(
        string requestKey,
        string inData,
        string verificationString,
        string inDataProofPreConcat,
        string inDataProof,
        bool compareResult
    );

    modifier verifyProof(string requestKey, string inData) {
        string memory inDataProof =  concatStrings("0x", bytes32string(bytes32(keccak256(inData))));
        
        emit verifyProofEvent(requestKey, inData, 
        callback_content_verifications[requestKey],
        bytes32string(bytes32(keccak256(inData))),
        inDataProof,
        compareStrings(callback_content_verifications[requestKey], inDataProof));
        
        require(
            compareStrings(callback_content_verifications[requestKey], inDataProof) == true
            );

        _;
    }
    event verifyProofEventInt(
        string requestKey,
        int inData,
        bytes32 verifyProof,
        bytes32 inDataProof
    );
    modifier verifyIntProof(string requestKey, int inData) {
        emit verifyProofEventInt(requestKey, inData, callback_content_verifications_int[requestKey],
        bytes32(keccak256(inData)));
        
        require(
            callback_content_verifications_int[requestKey] == bytes32(keccak256(inData))
            );
        
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

    // requestKey secure as only DappBridge can post to it
    /*
    event newEventResponse(
        bytes32 requestKey
    );
    */
    
    // requestKey=>content md5 hash (Only DappBridge able to post into this collection)
    mapping(string => string) internal callback_content_verifications;
    mapping(string => bytes32) internal callback_content_verifications_int;

    function setTimeout(string callback_method, uint32 timeout) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('setTimeout')+user_callback_gas;
        dAppBridge.setTimeout.value(_reward).gas(current_gas)(callback_method, timeout);
        //emit newEventResponse(_new_request_key);
        //callback_content_verifications[_new_request_key] = 0x00;
    }
    function setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('setURLTimeout')+user_callback_gas;
        dAppBridge.setURLTimeout.value(_reward).gas(current_gas)(callback_method, timeout, external_url, external_params, "");
        //emit newEventResponse(_new_request_key);
        //callback_content_verifications[_new_request_key] = 0x00;
    }
    function setURLTimeout(string callback_method, uint32 timeout, string external_url, string external_params, string json_extract_element) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('setURLTimeout')+user_callback_gas;
        dAppBridge.setURLTimeout.value(_reward).gas(current_gas)(callback_method, timeout, external_url, external_params, json_extract_element);
        //emit newEventResponse(_new_request_key);
        //callback_content_verifications[_new_request_key] = 0x00;
    }
    function callURL(string callback_method, string external_url, string external_params) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('callURL')+user_callback_gas;
        dAppBridge.callURL.value(_reward).gas(current_gas)(callback_method, external_url, external_params, "");
        //emit newEventResponse(_new_request_key);
        //callback_content_verifications[_new_request_key] = 0x00;
    }
    function callURL(string callback_method, string external_url, string external_params, string json_extract_elemen) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('callURL')+user_callback_gas;
        dAppBridge.callURL.value(_reward).gas(current_gas)(callback_method, external_url, external_params, json_extract_elemen);
        //emit newEventResponse(_new_request_key);
        //callback_content_verifications[_new_request_key] = 0x00;
    }
    function randomNumber(string callback_method, int32 min_val, int32 max_val, uint32 timeout) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('randomNumber')+user_callback_gas;
        dAppBridge.randomNumber.value(_reward).gas(current_gas)(callback_method, min_val, max_val, timeout);
        //emit newEventResponse(_new_request_key);
    }
    function randomString(string callback_method, uint8 number_of_bytes, uint32 timeout) internal dAppBridgeClient {
        uint256 _reward = dAppBridge.getMinReward('randomString')+user_callback_gas;
        dAppBridge.randomString.value(_reward).gas(current_gas)(callback_method, number_of_bytes, timeout);
        //emit newEventResponse(_new_request_key);
        //callback_content_verifications[_new_request_key] = 0x00;
    }
    

    event newProofEvent(
        string requestKey,
        string proof
    );

    function receiveProof(string requestkey, string proof) external only_dAppBridge {
        emit newProofEvent(requestkey, proof);
        callback_content_verifications[requestkey] = proof;
    }
    function receiveProofInt(string requestkey, int proof) external only_dAppBridge {
        callback_content_verifications_int[requestkey] = bytes32(keccak256(proof));
    }

    // Helper internal functions
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function char(byte b) internal pure returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    
    function bytes32string(bytes32 b32) internal pure returns (string out) {
        bytes memory s = new bytes(64);
        for (uint8 i = 0; i < 32; i++) {
            byte b = byte(b32[i]);
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[i*2] = char(hi);
            s[i*2+1] = char(lo);            
        }
        out = string(s);
    }

    function compareStrings (string a, string b) internal pure returns (bool){
        return keccak256(a) == keccak256(b);
    }
    
    function concatStrings(string _a, string _b) internal pure returns (string){
        bytes memory bytes_a = bytes(_a);
        bytes memory bytes_b = bytes(_b);
        string memory length_ab = new string(bytes_a.length + bytes_b.length);
        bytes memory bytes_c = bytes(length_ab);
        uint k = 0;
        for (uint i = 0; i < bytes_a.length; i++) bytes_c[k++] = bytes_a[i];
        for (i = 0; i < bytes_b.length; i++) bytes_c[k++] = bytes_b[i];
        return string(bytes_c);
    }
}
