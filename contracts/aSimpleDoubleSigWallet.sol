// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

//
// Double Signature Wallet with an Owner, an Approver and two Rescurers 
//
contract aSimpleDoubleSigWallet {
    address private owner;
    address private approver;
    bytes32 private passphrase;
    bool private approved;
    bool private rescueAttempt = false;
    
    mapping (address => bool) rescuers;
    
    modifier onlyOwner {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    modifier onlyApprover {
        require(msg.sender == approver, "Not the approver");
        _;
    }
    
    modifier onlyRescuers {
        require(rescuers[msg.sender] == true, "Not an rescuer");
        _;
    }
    
    modifier ifApproved {
        require((approved == true) || (owner==approver), "Not approved");
        _;
    }
    
    // Verify passphrase is correct 
    modifier ifCorrectPassphrase(string memory _passphrase) {
        require(passphrase != bytes32(0) , "No passphrase set");
        require(keccak256(abi.encodePacked(_passphrase)) == passphrase, "Passphrase incorrect");
        _;
    }
    
    // Reset passphrase to zero and remove the approval 
    modifier resetPassphraseAndApproval {
        _;
        passphrase = bytes32(0);
        approved = false;
    }
    
    constructor
    (
        address _approver, 
        address _RescuerOne, 
        address _RescuerTwo, 
        bytes32 _passphrase
    ) 
    {
        owner = msg.sender;
        approver = _approver;
        rescuers[_RescuerOne] = true;
        rescuers[_RescuerTwo] = true;
        passphrase = _passphrase;
    }
    
    
    //
    // owner
    //
    function setNewApprover(address newApprover) 
        public 
        onlyOwner 
    {
         approver = newApprover;
    }
    
    function setNewPassphrase(bytes32 _passphrase) 
        public 
        onlyOwner 
    {
        passphrase = _passphrase;
    }
    
    //
    // approver
    //
    function approve() 
        public 
        onlyApprover 
    {
        approved = true;
    }
     
    function removeApproval() 
        public 
        onlyApprover 
    {
        approved = false;
    }
    
    //
    // rescuer
    //
    // Two rescuers can first set the rescueAttempt to true and then set a new Owner 
    function rescueWallet(address newOwner) 
        public 
        onlyRescuers 
    {
        if (rescueAttempt == false) { rescueAttempt = true; }
        else { owner = newOwner; }
        rescuers[msg.sender] = false;
    }

    // Execute every function of any contract - provides flexibility
    function execute(address _target, bytes memory _data)
        public
        payable
        onlyOwner
        returns (bytes memory response)
    {
        require(_target != address(0), "No target");

        // call contract in current context
        assembly {
            let succeeded := delegatecall(sub(gas(), 5000), _target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize()

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                revert(add(response, 0x20), size)
            }
        }
    }
}
