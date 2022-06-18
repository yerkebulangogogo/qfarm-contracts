//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";


contract ERC20Mintable is ERC20 {
    constructor(string memory name, string memory symbol) 
        ERC20(symbol, name) 
    {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
