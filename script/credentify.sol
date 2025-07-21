// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {credentify} from "../src/credentify.sol";

contract CredentifyScript is Script {
    credentify public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new credentify();

        vm.stopBroadcast();
    }
}
