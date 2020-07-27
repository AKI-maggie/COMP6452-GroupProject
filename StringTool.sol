pragma solidity ^0.4.24;


contract StringTools {
    function trueOrFalse(bool x) public pure returns(string s){
        if(x){
            return "true";
        }
        return "false";
    }
    function toString(address _addr) public pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
    
   function byteToAdd(bytes32 data) public pure returns (address) {
        return address(data);
    }
    
    function int2str(int i) public pure returns (string){
        if (i == 0) return "0";
        int j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
    
    function compareStrings (string memory a, string memory b) pure public returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    function append(string a, string b, string c, string d, string e) public  pure returns (string) {
        return string(abi.encodePacked(a, b, c, d, e));
    }
    
    function append2(string a, string b) public pure returns (string) {
        return string(abi.encodePacked(a, b));
    }
    
    function append22(string a, string b) public pure returns(bytes){
        return abi.encodePacked(a, b);
    }
}