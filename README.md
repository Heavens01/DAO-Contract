## DAO Contract

### Overview
This repository contains Solidity smart contracts implementing a decentralized autonomous organization (DAO), built with Foundry. It includes a Box contract for storage, a GovToken (ERC20) for voting, a MyGovernor contract for governance, and a Timelock contract for delayed execution. The DAO enables GovToken holders to vote on proposals, which are queued in the Timelock and executed on the Box contract after a minimum delay.

### Features
* **Governance**: MyGovernor enables GovToken holders to propose and vote on actions.
* **Timelock**: Timelock contract enforces a delay before proposal execution, owned by the DAO.
* **GovToken**: ERC20 token used for voting rights within the DAO.
* **Box**: Simple storage contract owned by the Timelock, modified via DAO proposals.
* **Event Emission**: Emits events for proposals, votes, and executions.

### Installation
1. **Prerequisites**:
   * Foundry installed (forge and cast)

2. **Clone Repository**:
    ```bash
    git clone https://github.com/Heavens01/DAO-Contract
    cd DAO-Contract
    ```

3. **Install Dependencies**:
    ```bash
    forge install
    ```


Flow
* GovToken holders vote on proposals in MyGovernor.
* Approved proposals are queued in Timelock.
* After the minimum delay, Timelock executes the proposal on the Box contract.

### Usage

1. **Contract Deployment**:
    * Manually deploy contracts in the following order: GovToken, Timelock, Box, MyGovernor.
    * Configure Timelock as the owner of Box and the DAO as the proposer for Timelock.
    * Set MyGovernor to use GovToken and Timelock addresses.

2. **Interacting with the Contract**:
    * Use cast or ethers.js/web3.js to interact with the deployed contract.
    * Example (cast for checking proposal status):
    ```bash
    cast call <mygovernor-address> "state(uint256)(uint8)" <proposal-id>
    ```

3. **Testing**
    * Run unit and fuzz tests using Foundry:
    ```bash
    forge test
    ```


### Security

1. **Audits**: Ensure the contract is audited before deployment to mainnet.
2. **Best Practices**: Follows OpenZeppelin's governance and ERC20 implementation guidelines.

### License

MIT License.