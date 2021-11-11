// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@devprotocol/protocol-v2/contracts/interface/IProperty.sol";
import "@devprotocol/protocol-v2/contracts/interface/IPropertyFactory.sol";
import "./IPropertyGovernanceFactory.sol";
import "./PropertyGovernance.sol";
import "./UsingAddressRegistryUpgradable.sol";

contract PropertyGovernanceFactory is
	UsingAddressRegistryUpgradable,
	IPropertyGovernanceFactory
{
	mapping(address => address) public governanceMap;

	function initialize(address _addressRegistry) external initializer {
		__UsingAddressRegistryUpgradable_init(_addressRegistry);
	}

	function create(address _property) external returns (address) {
		require(
			IPropertyFactory(propertyFactoryAddress()).isProperty(_property),
			"not property address"
		);
		IProperty property = IProperty(_property);
		require(property.author() == msg.sender, "illegal access");
		PropertyGovernance governance = new PropertyGovernance(
			addressRegistry,
			_property
		);
		IERC20 erc20Token = IERC20(_property);
		uint256 balance = erc20Token.balanceOf(msg.sender);
		erc20Token.transferFrom(msg.sender, address(governance), balance);
		emit Created(
			_property,
			property.author(),
			address(governance),
			balance
		);
		governanceMap[_property] = address(governance);
		return address(governance);
	}
}
