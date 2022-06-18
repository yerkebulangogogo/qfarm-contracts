//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract QFarmKZT is ERC20 {
    constructor(
        string memory name, 
        string memory symbol,
        uint256 _amount
    ) ERC20(symbol, name) {
        _mint(msg.sender, _amount);
    }
}
