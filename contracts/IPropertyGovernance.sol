// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

interface IPropertyGovernance {
	struct TokenAllocate {
		address member;
		uint256 percentage;
	}
	event SetTokenAllocate(TokenAllocate[] tokenAllocateInfo);

	function setAllocateInfo(TokenAllocate[] memory _share) external;

	function finish() external returns (bool);

	function rescue(address _token) external returns (bool);
}
