// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

//
// SecretVaultToClaim stores the balance of the recepient until he claims it
//
contract SecretVaultToClaim {
    bytes32 public hashedVerifier;

    constructor
    (
        address _to
    ) 
    {
        hashedVerifier = keccak256(abi.encode(address(this), _to));
    }

    // Make sure that only one address can claim the funds
    // Additionally include address(this) to the hash to prevent Replay attacks
    function checkVerifier() 
        internal 
        returns(bool)
    {
        if(keccak256(abi.encode(address(this), msg.sender)) == hashedVerifier){
            return true;
        } 
        else {
            return false;
        }
    }

    fallback() 
        external 
        payable 
    {
        if(checkVerifier()){
            selfdestruct(payable(msg.sender));
        }
    }
}
