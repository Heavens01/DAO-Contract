// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    // minDelay is the minimum delay before a proposal can be executed
    // proposers are the addresses eligible to make a proposal => anybody
    // executors are the addresses that can execute proposals => anybody

    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}
