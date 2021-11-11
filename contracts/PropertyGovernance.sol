// SPDX-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IProperty} from "@devprotocol/protocol-v2/contracts/interface/IProperty.sol";

contract PropertyGovernance {
	address public property;
	address public factory;
	bool public isFinished = false;
	//TokenShare[] public tokenShare;

	struct TokenShare {
		address member;
		uint256 percentage;
	}

	constructor(address _property) {
		property = _property;
		factory = msg.sender;
	}

	modifier onlyPropertyAuthor() {
		require(IProperty(property).author() == msg.sender, "illegal access");
		_;
	}

	modifier notFinished() {
		require(isFinished == false, "already finished");
		_;
	}

	function setShareInfo(TokenShare[] memory _share)
		external
		onlyPropertyAuthor
		notFinished
		returns (bool)
	{
		uint256 sum = 0;
		for (uint256 i = 0; i < _share.length; i++) {
			sum += _share[i].percentage;
		}
		require(sum == 100, "total percentage is not 100");
		// アドレス重複チェック
		// シェア計算

		// tokenShare.length = 0;
		// for (uint256 i = 0; i < _share.length; i++) {
		// 	tokenShare.push(TokenShare(_share[i].member, _share[i].percentage));
		// }
		//tokenShare = _share;
		return true;
	}

	function share() public onlyPropertyAuthor notFinished returns (bool) {
		// Withdraw.withdraw
		// シェア計算の割合で分配
		return true;
	}

	function finish() external onlyPropertyAuthor notFinished returns (bool) {
		share();
		sendToken(property);
		isFinished = true;
		return true;
	}

	function rescue(address _token) external onlyPropertyAuthor returns (bool) {
		require(isFinished == true, "illegal access");
		return sendToken(_token);
	}

	function sendToken(address _token) private returns (bool) {
		IERC20 token = IERC20(_token);
		uint256 balance = token.balanceOf(address(this));
		return token.transfer(IProperty(property).author(), balance);
	}
}
