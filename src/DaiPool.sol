// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DaiPool is Ownable {
    using SafeERC20 for IERC20;

    error InvalidAmount(uint256 amount);
    error NoFundsToWithdraw();

    struct User {
        uint256 depositAmount;
        uint256 rewardDebt;
        uint256 lastRewardsSnapshot;
    }

    using SafeERC20 for IERC20;
    IERC20 public rewardToken;
    uint256 public totalDeposited;
    uint256 public totalRewards;
    uint256 public lastRewardBlock;

    mapping(address => User) public userDeposits;

    event RewardClaimed(address user, uint256 amountWithdrawed);
    event Deposit(address user, uint256 amountDeposited);
    event DepositRewards(uint256 amount);

    constructor(
        address _initialAdmin,
        address _rewardToken
    ) Ownable(_initialAdmin) {
        rewardToken = IERC20(_rewardToken);
    }

    modifier updateRewards(address _user) {
        User storage user = userDeposits[_user];
        if (user.depositAmount > 0 && totalDeposited > 0) {
            uint256 userRewards = (user.depositAmount *
                (totalRewards - user.lastRewardsSnapshot)) / totalDeposited;
            user.rewardDebt += userRewards;
            user.lastRewardsSnapshot = totalRewards;
        }
        _;
    }

    function depositDai(uint256 _amount) public updateRewards(msg.sender) {
        if (_amount < 1) revert InvalidAmount(_amount);
        User storage user = userDeposits[msg.sender];
        user.depositAmount += _amount;
        user.lastRewardsSnapshot = totalRewards;

        totalDeposited += _amount;

        rewardToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _amount);
    }

    function claimRewardsAndDeposit() public updateRewards(msg.sender) {
        User storage user = userDeposits[msg.sender];
        if (user.depositAmount < 1) revert NoFundsToWithdraw();

        uint256 totalAmount = user.depositAmount + user.rewardDebt;

        totalDeposited -= user.depositAmount;

        // Reset the data
        user.depositAmount = 0;
        user.rewardDebt = 0;
        user.lastRewardsSnapshot = 0;

        // Interaction sending the funds and rewards to the user
        rewardToken.safeTransfer(msg.sender, totalAmount);
        emit RewardClaimed(msg.sender, totalAmount);
    }

    function depositRewards(uint256 _amount) public onlyOwner {
        if (_amount < 1) revert InvalidAmount(_amount);
        totalRewards += _amount;
        rewardToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit DepositRewards(_amount);
    }

    function viewPendingRewards(address _user) public view returns (uint256) {
        User storage user = userDeposits[_user];
        if (user.depositAmount > 0 && totalDeposited > 0) {
            // Calcular las recompensas que le corresponden al usuario desde la última actualización
            uint256 userRewards = (user.depositAmount *
                (totalRewards - user.lastRewardsSnapshot)) / totalDeposited;
            return user.rewardDebt + userRewards;
        }
        return 0;
    }

    function getTotalDeposited() public view returns (uint256) {
        return totalDeposited;
    }

    function getTotalRewards() public view returns (uint256) {
        return totalRewards;
    }
}
