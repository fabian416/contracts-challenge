// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import {Script} from "../lib/forge-std/src/Script.sol";
import {DaiMock} from "../src/DaiMock.sol";

contract DaiMockScript is Script {
    DaiMock public daiMock;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        daiMock = new DaiMock();

        vm.stopBroadcast();
    }
}
