// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

import {IAddressRegistry} from "@devprotocol/protocol-v2/contracts/interface/IAddressRegistry.sol";

contract UsingAddressRegistry {
	address public addressRegistry;

	constructor(address _addressRegistry) {
		addressRegistry = _addressRegistry;
	}

	function withdrawAddress() internal view returns (address) {
		return IAddressRegistry(addressRegistry).registries("Withdraw");
	}

	function devAddress() internal view returns (address) {
		return IAddressRegistry(addressRegistry).registries("Dev");
	}
}
