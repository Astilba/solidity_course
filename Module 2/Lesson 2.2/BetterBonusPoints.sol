// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BetterBonusPoints is Ownable {

    event EarnPoints(address user, uint256 value);
    event MovePoints(address from, address _to, uint256 value);
    event BurnPoints(address user, uint256 value);

    mapping (address => bool) private _isUser;
    address[] private _users;

    mapping (address => uint256) private _totalEarnedPoints;
    mapping (address => uint256) private _totalSpentPoints;

    function getTotalEarnedPoints(address _user) private view returns(uint256) {
        require(_isUser[_user] == true, "there is no user with this address");
        return _totalEarnedPoints[_user];
    }

    function getTotalSpentPoints(address _user) private view returns(uint256) {
        require(_isUser[_user] == true, "there is no user with this address");
        return _totalSpentPoints[_user];
    }

    function getCurrentBalance(address _user) public view returns(uint256) {
        unchecked {
            return getTotalEarnedPoints(_user) - getTotalSpentPoints(_user);
        }
    }

    function updatePoints(address _user, int256 _value) external virtual onlyOwner {
        if (_value < 0) {
            require(_isUser[_user] == true, "there is no user with this address");
            uint256 currentBalance = getCurrentBalance(_user);
            require(currentBalance >= uint256(-_value), "user doesn't have enough points to spent");
            _totalSpentPoints[_user] += uint256(-_value);
            emit BurnPoints(_user, uint(-_value));
        } else {
            if (_isUser[_user] == false) {
                _isUser[_user] = true;
                _users.push(_user);
            }
            _totalEarnedPoints[_user] += uint256(_value);
            emit EarnPoints(_user, uint256(_value));
        }
    }

    function movePoints(address _to, uint256 _value) external {
        uint256 currentBalance = getCurrentBalance(msg.sender);
        require(currentBalance >= _value, "you don't have enough points to move");
        _totalSpentPoints[msg.sender] += _value;
        _totalEarnedPoints[_to] += _value;
        emit MovePoints(msg.sender, _to, _value);
    }

    function clearPoints() external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            uint256 currentBalance = getCurrentBalance(_users[i]);
            if (currentBalance > 0) {
                _totalSpentPoints[_users[i]] += currentBalance;
            }
        }
    }
}
