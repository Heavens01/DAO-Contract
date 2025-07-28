// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {GovToken} from "../src/GovToken.sol";

contract MyGovernorTest is Test {
    MyGovernor myGovernor;
    Box box;
    TimeLock timeLock;
    GovToken govToken;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600; // 1 HOUR - this time will pass before the proposal that its vote passes gets executed
    uint256 public constant VOTING_DELAY = 1; // How many blocks till a vote is active, remember we set it before copying from openzeppelin wizard
    uint256 public constant VOTING_PERIOD = 50400; // How long voting for or against a proposal is open
    address[] proposals; // Empty array, means any one can propose
    address[] executors; // Empty array, means anyone can execute

    // for test purposes
    uint256[] values;
    bytes[] calldatas;
    address[] targets;

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);
        // Note: Just because you minted tokens doesn't mean you can vote, you have to delegate to yourself first
        // Note: You can also delegate to another address incase you want someone else to vote on your behalf
        vm.startPrank(USER);
        govToken.delegate(USER);

        // Deploying the TimeLock contract
        timeLock = new TimeLock(MIN_DELAY, proposals, executors);

        // Deploying the Governor contract
        myGovernor = new MyGovernor(govToken, timeLock);
        // Granting Roles
        bytes32 proposerRole = timeLock.PROPOSER_ROLE(); // To be assigned to Governor because it is the only one to send a valid passed proposal to the ttimelock for its delay and execution
        bytes32 executorRole = timeLock.EXECUTOR_ROLE(); // To be grabted to Anybody who wishes to pay the gasfees to execute a proposal that has passed the voting period and the delay period
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE(); // To be relinquished after deployment and role granting by the deployer

        timeLock.grantRole(proposerRole, address(myGovernor));
        timeLock.grantRole(executorRole, address(0)); // Granting to anyone
        timeLock.revokeRole(adminRole, USER); // User will no longer be admin of the timeLock contract and never anyone anymore
        vm.stopPrank();

        // Deploying the Box  contract and timelock as it's owner
        // Note: The Box contract is the one that gets updated when the Governor makes changes through proposals it sends to the Timelock contract.
        // Note: The Timelock contract owns the Box contract, so it can carry out the approved proposals from the Governor and apply them to the Box contract.
        box = new Box(address(timeLock));
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(42); // This should revert because the caller is not the owner (Timelock)
    }

    function testGovernanceUpdateBox() public {
        // Creating a proposal for others to vote on
        uint256 newNumber = 42;
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", newNumber);

        targets.push(address(box));
        values.push(0); // values: ether to send
        calldatas.push(encodedFunctionCall);
        string memory description = "store 42 in Box";
        // Propose to DAO
        uint256 proposalId = myGovernor.propose(targets, values, calldatas, description);

        // View the state of proposed proposal
        console2.log("Proposal state when made: ", uint256(myGovernor.state(proposalId)));

        vm.warp(block.timestamp + VOTING_DELAY + 100);
        vm.roll(block.number + VOTING_DELAY + 100); // Blocks updated
        console2.log("Proposal state after delay: ", uint256(myGovernor.state(proposalId)));

        // Vote
        string memory reason = "Because I want the number stored to be 42";
        uint8 voteChoice = 1; // Voting: (YES) FOR not AGAINST. Check voteType enum in GovernorCountingSimple
        vm.prank(USER);
        myGovernor.castVoteWithReason(proposalId, voteChoice, reason);

        // Speeding voting process
        vm.warp(block.timestamp + VOTING_PERIOD + 100);
        vm.roll(block.number + VOTING_PERIOD + 100); // Blocks updated

        // MyGovernor Queues the proposal in TimeLock
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        myGovernor.queue(targets, values, calldatas, descriptionHash);

        // Speeding delay set by TimeLock
        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1); // Blocks updated

        // Executing proposal after delay met
        myGovernor.execute(targets, values, calldatas, descriptionHash);

        // assert
        assertEq(box.getNumber(), newNumber);
        console2.log("Box Current Number: ", box.getNumber());
    }
}
