// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IAddressRegistry} from "@devprotocol/protocol-v2/contracts/interface/IAddressRegistry.sol";
import {IPropertyFactory} from "@devprotocol/protocol-v2/contracts/interface/IPropertyFactory.sol";

contract UsingAddressRegistry is Initializable {
	address public addressRegistry;

	// solhint-disable-next-line func-name-mixedcase
	function __UsingAddressRegistry_init(address _addressRegistry)
		public
		initializer
	{
		addressRegistry = _addressRegistry;
	}

	function propertyFactory() internal view returns (IPropertyFactory) {
		return
			IPropertyFactory(
				IAddressRegistry(addressRegistry).registries("PropertyFactory")
			);
	}
}
