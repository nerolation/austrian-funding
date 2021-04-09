// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./WrappedEtherLike.sol";
import "./SecretVault.sol";
import "./SecretVaultToClaim.sol";

// 
// Methods to interact with the SecretVault 
//
contract HiddingSomething {
    address private vaultAddr;
    address private wrappedEtherAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet
    WrappedEtherLike WETHLike = WrappedEtherLike(wrappedEtherAddr);

    // Forward ETH to secret Vault
    function forwardETH() 
        internal 
        returns(bool)
    {
        (bool success, ) = vaultAddr.call{value:address(this).balance}("");
        require(success);
        return true;
    }
    
    // Secret Vault that acts as wallet where WETH is stored
    function deploySecretVault() 
        internal 
        returns (address)
    {
        SecretVault vault = new SecretVault(address(this));
        vaultAddr = address(vault);
        return vaultAddr;
    }
    
    // Deploy Secret Vault in which recipient can claim
    function deploySecretVaultToClaim(address _to) 
        internal 
        returns (address)
    {
        SecretVaultToClaim vault = new SecretVaultToClaim(_to);
        return address(vault);
    }

    // Spend using a simple internal transaction
    function spend(address _to, uint256 _value) 
        internal 
        returns(bool)
    {
        (bool success, ) = vaultAddr.call(
            abi.encodeWithSignature(
                "spend(address,uint256)", _to,  _value)
            );
        require(success);
        return true;
    }
    
    // Spend in UTXO style
    function spendUTXO(address _to, uint256 _value) 
        internal 
        returns(bool)
    {
        address oldVault = vaultAddr;
        vaultAddr = deploySecretVault();
        (bool success, ) = oldVault.call(
            abi.encodeWithSignature(
                "spendUTXO(address,uint256,address)", _to,  _value, vaultAddr)
            );
        require(success);
        return true;
    }
    
    // Spend by enabling the other party to claim
    function spendToClaim(address _to, uint256 _value) 
        internal 
        returns(bool)
    {
        address secAddr = deploySecretVaultToClaim(_to);
        (bool success, ) = secAddr.call{value:_value}("");
        require(success);
        return true;
    }
   
    // Get balance of SecretVault
    function VaultBalance() 
        public 
        view 
        returns(uint) 
    {
        return WETHLike.balanceOf(vaultAddr);
    }
}
