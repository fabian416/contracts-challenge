// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import { Ownable } from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";


Error NoZeroValue(uint256 amount);
    
contract DaiPool {

    constructor(address initialAdmin) {
        transferOwnership(initialAdmin);

    }   

    function depositDai(uint256 _amount) public {
        if (amount == 0) revert NoZeroValue(_amount);

    }
}
