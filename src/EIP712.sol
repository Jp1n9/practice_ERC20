//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib/forge-std/src/console.sol";

contract EIP712 {

    bytes32 private DOMAIN_SEPARATOR;
    bytes32 private hashedName;
    bytes32 private hashedVer; 
    bytes32 private typeHash; 
    constructor(string memory name_, string memory version_) {
        hashedName = keccak256(bytes(name_));
        hashedVer = keccak256(bytes(version_));     
        typeHash = keccak256( "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        DOMAIN_SEPARATOR = keccak256(abi.encode(typeHash,hashedName,hashedVer,block.chainid,address(this)));
          
    }

    function _domainSeparator() public view returns (bytes32) {
        
        return DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash_) public returns (bytes32) {
        return keccak256(abi.encode("\x19\x01",DOMAIN_SEPARATOR,structHash_));
    }

}