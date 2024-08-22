RareSkills Riddles ERC1155: https://github.com/RareSkills/solidity-riddles/blob/main/contracts/Overmint1-ERC1155.sol
- mint 3 from one account and then use another account to mint another 2 then transfer. also there is also reentrancy bug where it mints then updates state


Damn Vulnerable Defi #4 Side Entrance https://github.com/OpenZeppelin/damn-vulnerable-defi/blob/master/contracts/side-entrance/SideEntranceLenderPool.sol

- Borrow X amount then use deposit. The X would be added to address Balance and my balance which then I can withdraw without needing to pay it back

Damn Vulnerable Defi #1 Unstoppable (this is challenging) https://github.com/OpenZeppelin/damn-vulnerable-defi/blob/master/contracts/unstoppable/UnstoppableLender.sol

- issue is here assert(poolBalance == balanceBefore); I can transfer tokens to the pool then this would be invalid

RareSkills Riddles: Overmint3 (Double voting or msg.sender spoofing) : https://github.com/RareSkills/solidity-riddles/blob/main/contracts/Overmint3.sol

- Reentrancy issue

RareSkills Riddles: Forwarder (abi encoding) : https://github.com/RareSkills/solidity-riddles/blob/main/contracts/Forwarder.sol

- in the data parameter, you can call sendEther and put yourself as the destination to recieve the ether

RareSkills Riddles: Democracy (Double voting or msg.sender spoofing) : https://github.com/RareSkills/solidity-riddles/blob/main/contracts/Democracy.sol

- can transfer nft to different wallets to get extra votes

Damn Vulnerable Defi #3 Truster (this is challenging) : https://github.com/OpenZeppelin/damn-vulnerable-defi/blob/master/contracts/truster/TrusterLenderPool.sol

- using (bool success, ) = target.call(data); we can call approve for the token allowing the user to take the token

RareSkills Riddles: Delete user (understanding storage pointers) : https://github.com/RareSkills/solidity-riddles/blob/main/contracts/DeleteUser.sol

- Pop wrong users data from index as it uses users.pop();

RareSkills Riddles: RewardToken (cross function reentrancy) : https://github.com/RareSkills/solidity-riddles/blob/main/contracts/RewardToken.sol

- Update Reward Token

Use reentrancy on withdrawAndClaimEarnings where on recieving the nft token. I keep calling claimEarnings until the contract is drained