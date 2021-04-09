// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


interface WrappedEtherLike {
    function balanceOf(address account) 
        external 
        view 
        returns (uint256);
   
    function withdraw(uint wad) 
        external;
        
    function transfer(address dst, uint wad) 
        external
        returns (bool);
        
    function transferFrom(address src, address dst, uint wad)
        external
        returns (bool);
}
