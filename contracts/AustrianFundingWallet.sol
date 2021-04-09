// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;


import "./HiddingSomething.sol";
import "./aSimpleDoubleSigWallet.sol";

//
// AustrianFunding is a wallet that allows you to hide your funds 
//
contract AustrianFundingWallet is HiddingSomething, aSimpleDoubleSigWallet {
    
    // Initialize DoubleSigWallet and directly hide funds if ether is sent into
    constructor
    (
        address _approver, 
        address _rescuerOne, 
        address _rescuerTwo, 
        bytes32 _passphrase
    ) 
        payable 
        aSimpleDoubleSigWallet(_approver,_rescuerOne,_rescuerTwo,_passphrase) 
    {
        // Deploy secret Vault and set this contract as the owner
        deploySecretVault();
        
        if (msg.value >  0) 
        {
            // forwards fund to the SecretVault
            forwardETH();
        }
    }
    
    
    //
    // Main functions
    //
    
    // Spend ETH from SecretVault
    function sendInternal(address _to, uint256 _value, string memory passphrase) 
        public 
        payable 
        onlyOwner
        ifCorrectPassphrase(passphrase)
        resetPassphraseAndApproval
    {

        bool success = spend(_to,_value);
        require(success);
    }

    // Spend ETH in UXTO style from SecretVault
    function sendUTXO(address _to, uint256 _value, string memory passphrase) 
        public 
        payable 
        onlyOwner
        ifCorrectPassphrase(passphrase)
        resetPassphraseAndApproval
    {

        bool success = spendUTXO(_to,_value);
        require(success);
    }
    
    // Spend ETH from by deploying a contract that stores the funds and
    // let only address(_to) claim them
    function sendAndLetOtherPartyClaim(address _to, string memory passphrase) 
        public 
        payable 
        onlyOwner
        ifCorrectPassphrase(passphrase)
        resetPassphraseAndApproval
    {

        bool success = spendToClaim(_to,msg.value);
        require(success);
        
    }
    
    fallback() external payable{
        forwardETH();
    }
}
