
# Multi-Party Lottery on Ethereum Blockchain

Multi-Party Lottery smart contract developed with Solidity, deployed on Ethereum’s Sepolia Testnet.


## Contract Constructor

In this contract, you can configure the pool size and time for each stage using the variables in the `constructor()` function.

| Variable   | Type   | Description.          |
| :--------- | :----- | :-------------------- |
| `poolSize` | `uint` | Maximum number of players allowed in the pool |
| `T1` | `uint` | Duration in seconds for stage 1 before transitioning to stage 2 |
| `T2` | `uint` | Duration in seconds before transitioning to stage 3 |
| `T3` | `uint` | Duration in seconds before transitioning to stage 4 |

<br/>

## Function Reference

#### Join Lottery Pool

This function is used by anyone who wants to join the lottery pool. The first player to join the pool becomes the contract owner, initiating the timer.

```solidity
function joinPool(uint choice, string memory salt) public payable 
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `choice`  | `uint`   | Desired lottery number (0-999) |
| `salt`    | `string` | Hashing salt for the lottery number |

#### Reveal My Lottery Choice
After **T1 senconds** have passed, every player must reveal their chosen number.

```solidity
function revealMyChoice(uint choice, string memory salt) public
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `choice`  | `uint`   | Previously given Lottery number |
| `salt`    | `string` | Hashing salt for the previously submitted lottery number |

#### Get the lottery winner

After **T2 senconds** have passed, First Player of this lottery pool can trigger this function to calculate the winner with XOR operaion and pay the prize to the winner.

```solidity
function payPrizeToWinner() public
```

#### Withdraw money from abandoned contract
After **T3 seconds** have passed without the execution of `payPrizeToWinner()`, any player can trigger this function to withdraw their Ethereum from the pool.

```solidity
function payPrizeToWinner() public
```
<br/>

## Winner and Prize Calculation

#### Valid Lottery Ticket  

For players in the pool, certain requirements must be followed for consideration as a potential winner. Ethereum from players who fail to meet these requirements will be awarded to the winner.

- **Lottery Number Requirement:** The chosen lottery number must fall within the range of 0 to 999.
- **Reveal Time Window:** Players must reveal their numbers within the period between T1 and T2.

#### Winner Calculation
To determine the winner among the valid lottery tickets, perform the XOR operation and modulo operation on all the lottery numbers within the potential winner pool.
```
winner = (player[0].choice ^ player[1].choice ^ player[2].choice) % pool_size;
```

#### Prize Calculation
The Ethereum prize in the pool will be split among the winner and the contract owner (first player) as a fee, according to the following formula:

```
prize = 0.001 ETH * num_player_in_pool * 0.98
fee = 0.001 ETH * num_player_in_pool * 0.02
```
<br/>

## Appendix

To see this contract and transaction on Ethereum’s Sepolia Testnet visit this link 
[etherscan.io](https://sepolia.etherscan.io/address/0x02C6C1c7Db5aA4157B3c0975e2B74736B939CDCc) or search on Ethereum’s explorer with contract address below
```
0x02C6C1c7Db5aA4157B3c0975e2B74736B939CDCc
```

