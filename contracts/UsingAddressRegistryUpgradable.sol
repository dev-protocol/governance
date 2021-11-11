// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IAddressRegistry} from "@devprotocol/protocol-v2/contracts/interface/IAddressRegistry.sol";
import {IWithdraw} from "@devprotocol/protocol-v2/contracts/interface/IWithdraw.sol";

contract UsingAddressRegistryUpgradable is Initializable {
	address public addressRegistry;

	// solhint-disable-next-line func-name-mixedcase
	function __UsingAddressRegistryUpgradable_init(address _addressRegistry)
		public
		initializer
	{
		addressRegistry = _addressRegistry;
	}

	function propertyFactoryAddress() internal view returns (address) {
		return IAddressRegistry(addressRegistry).registries("PropertyFactory");
	}
}
