// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpNetStaking is Ownable {
    IERC20 public opNetToken;
    uint256 public rewardRate = 100; 
    
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakingTimestamp;

    constructor(address _tokenAddress) Ownable(msg.sender) {
        opNetToken = IERC20(_tokenAddress);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0");
        opNetToken.transferFrom(msg.sender, address(this), _amount);
        stakedAmount[msg.sender] += _amount;
        stakingTimestamp[msg.sender] = block.timestamp;
    }

    function calculateReward(address _user) public view returns (uint256) {
        uint256 duration = block.timestamp - stakingTimestamp[_user];
        return (stakedAmount[_user] * rewardRate * duration) / 1e12; 
    }

    function withdraw() external {
        uint256 amount = stakedAmount[msg.sender];
        uint256 reward = calculateReward(msg.sender);
        require(amount > 0, "No staked amount");
        stakedAmount[msg.sender] = 0;
        opNetToken.transfer(msg.sender, amount + reward);
    }
}
