// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BonusPoints is Ownable {

    function calculatePoints(uint256 _old, int256 _value) external view onlyOwner returns (uint256) {

        if (_value < 0) {
            return subPoints(_old, uint256(-_value));
        } else {
            return addPoints(_old, uint256(_value));
        }
    }

    function addPoints(uint256 _old, uint256 _value) private pure returns (uint) {
        return _old + _value;
    }

    function subPoints(uint256 _old, uint256 _value) private pure returns (uint) {
        require(_old >= _value, "not enough points");
        return _old - _value;
    }
}
