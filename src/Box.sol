// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private s_number;

    event NumberChanged(uint256 newNumber);

    // _dao is the address of the DAO that will own this contract
    // TimeLock will be the owner of this contract  and timelock is owned by the DAO as its Only Proposer
    //@dev Flow: GovToken holders vote → Governor passes proposal → queues in Timelock → Timelock waits for minDelay → Timelock executes on Box.

    constructor(address _dao) Ownable(_dao) {}

    function store(uint256 _newNumber) public onlyOwner {
        s_number = _newNumber;
        emit NumberChanged(_newNumber);
    }

    function getNumber() external view returns (uint256) {
        return s_number;
    }
}
