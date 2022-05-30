// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BetterBonusPoints is Ownable {

    event EarnPoints(address user, uint value);
    event MovePoints(address from, address _to, uint value);
    event BurnPoints(address user, uint value);

    mapping (address => bool) private _isUser;
    address[] private _users;
    mapping (address => uint) public userBonusPoints;

    function addPoints(uint256 _old, uint256 _value) private pure returns (uint) {
        return _old + _value;
    }

    function subPoints(uint256 _old, uint256 _value) private pure returns (uint) {
        return _old - _value;
    }

    function updatePoints(address _user, int256 _value) external onlyOwner {
        if (_value < 0) {
            require(_isUser[_user] == true, "there is no user with this address");
            require(userBonusPoints[_user] >= uint256(-_value), "user doesn't have enough points to deduct");
            unchecked {
                userBonusPoints[_user] = subPoints(userBonusPoints[_user], uint256(-_value));
            }
            emit BurnPoints(_user, uint(-_value));
        } else {
            if (_isUser[_user] == false) {
                _isUser[_user] = true;
                _users.push(_user);
            }
            userBonusPoints[_user] = addPoints(userBonusPoints[_user], uint256(_value));
            emit EarnPoints(_user, uint256(_value));
        }
    }

    function movePoints(address _to, uint256 _value) external {
        require(userBonusPoints[msg.sender] >= _value, "you don't have enough points to move");
        unchecked {
            userBonusPoints[msg.sender] = subPoints(userBonusPoints[msg.sender], _value);
        }
        userBonusPoints[_to] = addPoints(userBonusPoints[_to], _value);
        emit MovePoints(msg.sender, _to, _value);
    }

    function clearPoints() external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            userBonusPoints[_users[i]] = 0;
        }
    }
}
