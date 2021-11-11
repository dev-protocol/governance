// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@devprotocol/protocol-v2/contracts/interface/IProperty.sol";
import "@devprotocol/protocol-v2/contracts/interface/IWithdraw.sol";
import "./UsingAddressRegistry.sol";
import "./IPropertyGovernance.sol";

contract PropertyGovernance is UsingAddressRegistry, IPropertyGovernance {
	address public property;
	address public factory;
	bool public isFinished = false;
	uint256 public alreadyAllocateReward;
	mapping(address => uint256) public percentage;
	mapping(address => uint256) public rewardMap;
	EnumerableSet.AddressSet private members;

	using EnumerableSet for EnumerableSet.AddressSet;

	constructor(address _addressRegistry, address _property)
		UsingAddressRegistry(_addressRegistry)
	{
		property = _property;
		factory = msg.sender;
		address author = IProperty(property).author();
		members.add(author);
		percentage[author] = 100;
	}

	modifier onlyPropertyAuthor() {
		require(IProperty(property).author() == msg.sender, "illegal access");
		_;
	}

	modifier notFinished() {
		require(isFinished == false, "already finished");
		_;
	}

	function setAllocateInfo(TokenAllocate[] memory _allocate)
		external
		onlyPropertyAuthor
		notFinished
	{
		validateTokenAllocate(_allocate);
		addReward();
		for (uint256 i = 0; i < _allocate.length; i++) {
			address member = _allocate[i].member;
			if (!members.contains(member)) {
				members.add(member);
			}
			percentage[member] = _allocate[i].percentage;
		}
		for (uint256 i = 0; i < members.length(); i++) {
			address member = members.at(i);
			if (!isAllocateMember(_allocate, member)) {
				percentage[member] = 0;
			}
		}
		emit SetTokenAllocate(_allocate);
	}

	function allocate() public onlyPropertyAuthor notFinished returns (bool) {
		addReward();
		IWithdraw(withdrawAddress()).withdraw(property);
		IERC20 dev = IERC20(devAddress());
		uint256 transferedReward = 0;
		for (uint256 i = 0; i < members.length(); i++) {
			address member = members.at(i);
			uint256 reward = rewardMap[member];
			if (reward == 0) {
				continue;
			}
			rewardMap[member] = 0;
			require(dev.transfer(member, reward), "failed to transfer");
			transferedReward += reward;
		}
		return true;
	}

	function finish() external onlyPropertyAuthor notFinished returns (bool) {
		require(allocate(), "failed to allocate");
		require(sendToken(property), "failed to send property token");
		// just in case
		require(sendToken(devAddress()), "failed to send dev token");
		isFinished = true;
		return true;
	}

	function rescue(address _token) external onlyPropertyAuthor returns (bool) {
		require(isFinished == true, "illegal access");
		return sendToken(_token);
	}

	function addReward() private {
		(uint256 currentReward, , , ) = IWithdraw(withdrawAddress())
			.calculateRewardAmount(property, address(this));
		uint256 reward = currentReward - alreadyAllocateReward;
		for (uint256 i = 0; i < members.length(); i++) {
			address member = members.at(i);
			uint256 individualReward = (reward * percentage[member]) / 100;
			rewardMap[member] += individualReward;
		}
		alreadyAllocateReward = currentReward;
	}

	function isAllocateMember(TokenAllocate[] memory _allocate, address _member)
		private
		pure
		returns (bool)
	{
		for (uint256 i = 0; i < _allocate.length; i++) {
			address member = _allocate[i].member;
			if (member == _member) {
				return true;
			}
		}
		return false;
	}

	function validateTokenAllocate(TokenAllocate[] memory _allocate)
		private
		pure
	{
		uint256 sum = 0;
		address[] memory alocateMembers = new address[](_allocate.length);
		for (uint256 i = 0; i < _allocate.length; i++) {
			alocateMembers[i] = _allocate[i].member;
			sum += _allocate[i].percentage;
		}
		require(sum == 100, "total percentage is not 100");
		for (uint256 i = 0; i < _allocate.length; i++) {
			for (uint256 k = i; k < _allocate.length; k++) {
				require(
					alocateMembers[k] == alocateMembers[i],
					"total percentage is not 100"
				);
			}
		}
	}

	function sendToken(address _token) private returns (bool) {
		IERC20 token = IERC20(_token);
		uint256 balance = token.balanceOf(address(this));
		if (balance == 0) {
			return true;
		}
		return token.transfer(IProperty(property).author(), balance);
	}
}
