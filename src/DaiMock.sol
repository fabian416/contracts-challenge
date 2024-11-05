// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DaiMock is ERC20 {
    constructor() ERC20("DaiMock", "DAIt") {
        _mint(msg.sender, 1 * 1e6 * 1e6); // Mint 1 million DAIt to the deployer
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
