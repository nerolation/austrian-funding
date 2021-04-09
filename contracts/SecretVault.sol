// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./WrappedEtherLike.sol";

//
// SecretVault stores the funds of the AustrianFundingWallet and swaps it
//
contract SecretVault {
    address public owner;
    address wrappedEtherAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet
    WrappedEtherLike WETHLike = WrappedEtherLike(wrappedEtherAddr);
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    // Set owner
    constructor
    (
        address _owner
    ) 
    {
        owner = _owner;
    }
    
    // Swap ETH to WETH
    function swap() 
        internal
        returns(bool)
    {
        (bool success, ) = address(WETHLike).call
        {
            value: address(this).balance
        }
        (
            abi.encodeWithSignature
            (
                "deposit(uint256)", 
                 address(this).balance
            )
        );
        require(success);
        return true;
    }
    
    // Approve owner to spend funds
    function spendUTXO(address payable to, uint256 _value, address payable _newVault)
        public 
        onlyOwner
        returns(bool)
    {
        uint256 cb = WETHLike.balanceOf(address(this));
        WETHLike.withdraw(cb);
        require(address(this).balance > 0, "Something failed");
        uint256 rest = cb - _value;
        (bool success, ) = _newVault.call{value:rest}("");
        require(success, "Spending failed");
        selfdestruct(to);
        return true;
    }
    
    function spend(address payable to, uint256 _value)
        public 
        onlyOwner
        returns(bool)
    {
        WETHLike.withdraw(_value);
        (bool success, ) = to.call{value:_value}("");
        require(success, "Spending failed");
        return true;
    }
    
    fallback() 
        external 
        payable 
    {
        if (address(WETHLike)==msg.sender)
        {
            // Do nothing
        }
        else 
        {
            swap();
        }
    }
}
