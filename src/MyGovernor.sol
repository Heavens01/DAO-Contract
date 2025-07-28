// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from
    "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/// @title MyGovernor
/// @notice A governance contract for managing proposals, voting, and execution with timelock control.
/// @dev Inherits from OpenZeppelin's Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes,
///      GovernorVotesQuorumFraction, and GovernorTimelockControl for robust governance functionality.
contract MyGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    /// @notice Initializes the governance contract with a voting token and timelock controller.
    /// @dev Sets initial parameters: 1 block voting delay, 1 week voting period, 0 proposal threshold,
    ///      4% quorum fraction, and integrates with the provided token and timelock.
    /// @param _token The IVotes-compatible token used for voting power.
    /// @param _timelock The TimelockController contract for delayed execution of proposals.
    constructor(IVotes _token, TimelockController _timelock)
        Governor("MyGovernor")
        GovernorSettings(1, /* 1 block */ 50400, /* 1 week */ 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {}

    // The following functions are overrides required by Solidity.

    /// @notice Retrieves the current state of a proposal.
    /// @dev Overrides the state function from Governor and GovernorTimelockControl to resolve inheritance ambiguity.
    /// @param proposalId The unique identifier of the proposal.
    /// @return The current state of the proposal (e.g., Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed).
    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    /// @notice Determines if a proposal needs to be queued before execution.
    /// @dev Overrides the proposalNeedsQueuing function from Governor and GovernorTimelockControl.
    /// @param proposalId The unique identifier of the proposal.
    /// @return A boolean indicating whether the proposal requires queuing.
    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    /// @notice Returns the minimum number of votes required to create a proposal.
    /// @dev Overrides the proposalThreshold function from Governor and GovernorSettings.
    /// @return The number of votes required to submit a proposal.
    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    /// @notice Queues a proposal's operations for delayed execution via the timelock.
    /// @dev Internal function overriding Governor and GovernorTimelockControl behavior.
    /// @param proposalId The unique identifier of the proposal.
    /// @param targets The array of target addresses for the proposal's calls.
    /// @param values The array of ETH values to send with each call.
    /// @param calldatas The array of encoded function calls to execute.
    /// @param descriptionHash The keccak256 hash of the proposal description.
    /// @return The timestamp when the proposal can be executed.
    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /// @notice Executes a proposal's operations after the timelock delay.
    /// @dev Internal function overriding Governor and GovernorTimelockControl behavior.
    /// @param proposalId The unique identifier of the proposal.
    /// @param targets The array of target addresses for the proposal's calls.
    /// @param values The array of ETH values to send with each call.
    /// @param calldatas The array of encoded function calls to execute.
    /// @param descriptionHash The keccak256 hash of the proposal description.
    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /// @notice Cancels a proposal and its associated operations.
    /// @dev Internal function overriding Governor and GovernorTimelockControl behavior.
    /// @param targets The array of target addresses for the proposal's calls.
    /// @param values The array of ETH values to send with each call.
    /// @param calldatas The array of encoded function calls to execute.
    /// @param descriptionHash The keccak256 hash of the proposal description.
    /// @return The ID of the canceled proposal.
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    /// @notice Retrieves the address of the executor for proposal operations.
    /// @dev Internal view function overriding Governor and GovernorTimelockControl behavior.
    /// @return The address of the TimelockController contract acting as the executor.
    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }
}
