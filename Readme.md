# austrian-funding ![aut](./static/aut.png)



### . . . when normal transactions are way too boring


![gone](./static/gone.png)

##### *```austrian-funding``` represents a wallet for those who want to store and transfer Ether without leaving traces such as transactions or positive ETH balances associated closely with their account. This is achieved by using another account as proxy, instantly converting to WETH, letting others claim their funds and introducing an UTXO model*




## **Features AustrianFundingWallet**:
1. **Deploys it's own ```SecretVault``` and then allows to ...**
    * **Spend through an internal transaction**
    * **Spend though using some kind of UTXO model (see below)**
    
3. **Deploys an ```SecretVaultToClaim```**
    * **Spend and let other party claim their funds**



### **In addition the wallet...**
* ... is password protected
* ... instantly forwards ETH to the SecretVault and swaps it with WETH
* ... is multisignature protected (2-out-of-2 => Owner & Approver)
* ... resets passphrase and approval after every successful transfer
* ... has two backup accounts that can rescue the wallet
* ... can act as a flexible proxy (assembly execute function)

<br/>

### **UTXO Spends**:
The wallet mimics Bitcoin's UTXO model by setting up a new ```SecretVault``` every time the owner executes the spendUTXO function. In such cases, the remaining balance of the old vault are automatically transfered to the address of a newly deployed vault. The wallet therefore uses a new address after each transaction while the old vault is automatically destroyed.



### **'ToClaim' Spends**:
By executing the *sendAndLetOtherPartyClaim* function, the wallet automatically forwards the transaction's value to a freshly deployed ```SecretVaultToClaim```. 
This Vault allows stores a hash value ***H* where *H = keccak256(vault, recipient)***. When the recipient wants to claim the funds, all he has to do is call the vault's fallback function, which checks if ***H(vault, sender)*** equals ***H*** and then, if successful, transfers the funds.


## Usage
**1. Deploy AustrianFundingWallet with the following parameters:**
* *approver*   - Another account (which can also be the owner)
* *rescuerOne* - First rescuer who can rescue the wallet by setting a new owner
* *rescuerTwo* - Second rescuer
* *passphrase* - Hashed (keccak-256) 32 byte passphrase in hexadecimal, later required for transfers from the SecretVault

Fund the wallet through an internal transaction to avoid public transactions shown on blockexplorers like [etherscan.io](https://etherscan.io)

<br/>

**Roadmap**:
* Add requirement checks
* Use appropriate types for variables
* Tornado Cash integration
* Shared ownership concepts
* Spend to not-yet deployed contracts of recipient


<br/><br/>

Visit [toniwahrstaetter.com](https://toniwahrstaetter.com/) for further details!
<br/><br/>

Anton Wahrstätter, 11.04.2021 
