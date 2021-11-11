// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IProperty} from "@devprotocol/protocol-v2/contracts/interface/IProperty.sol";
import {IPropertyFactory} from "@devprotocol/protocol-v2/contracts/interface/IPropertyFactory.sol";
import {PropertyGovernance} from "./PropertyGovernance.sol";
import {UsingAddressRegistry} from "./UsingAddressRegistry.sol";

contract PropertyGovernanceFactory is UsingAddressRegistry {
	mapping(address => address) public governanceMap;

	function initialize(address _addressRegistry) external initializer {
		__UsingAddressRegistry_init(_addressRegistry);
	}

	function create(address _property) external returns (address) {
		require(
			propertyFactory().isProperty(_property),
			"not property address"
		);
		IProperty property = IProperty(_property);
		require(property.author() == msg.sender, "illegal access");
		PropertyGovernance governance = new PropertyGovernance(_property);
		IERC20 erc20Token = IERC20(_property);
		// 一旦authorが保持する全てのトークンを預ける
		erc20Token.transferFrom(
			msg.sender,
			address(governance),
			erc20Token.balanceOf(msg.sender)
		);
		governanceMap[_property] = address(governance);
		return address(governance);
	}
}
