// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

interface IPropertyGovernanceFactory {
	event Created(
		address indexed property,
		address author,
		address governance,
		uint256 tokenAmount
	);

	function create(address _property) external returns (address);
}
