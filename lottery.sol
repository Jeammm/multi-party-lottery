// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./CommitReveal.sol";

contract Lottery is CommitReveal{
    struct Player {
        uint choice;
        address addr;
        uint joinTime;
        bool withdrawn;
    }

    uint public poolSize;
    uint public T1;
    uint public T2;
    uint public T3;

    constructor() {
        poolSize = 3;
        T1 = 60;
        T2 = 120;
        T3 = 180;
    }

    mapping (uint => Player) public player;
    mapping (address => uint) public playerId;
    mapping (uint => address) public confirmedPool;
    mapping (address => bool) public isJoined;

    uint public numPlayer = 0;
    uint public reward = 0;
    uint public numRevealed = 0;
    uint public poolStartTime = 0;
    bool public isPayed = false;

    function joinPool(uint choice, string memory salt) public payable {
        require(numPlayer < poolSize);
        require(isJoined[msg.sender] == false);
        require(msg.value == 0.001 ether);
        reward += msg.value;

        player[numPlayer].addr = msg.sender;
        player[numPlayer].choice = 0;
        player[numPlayer].joinTime = block.timestamp;
        player[numPlayer].withdrawn = false;
        playerId[msg.sender] = numPlayer;
        if (numPlayer == 0) {
            poolStartTime = block.timestamp;
        }

        bytes32 saltHash = keccak256(abi.encodePacked(salt));
        commit(getSaltedHash(bytes32(choice), saltHash));

        isJoined[msg.sender] = true;
        numPlayer++;
    }

    function revealMyChoice(uint choice, string memory salt) public {
        //reveal the answer with the given salt
        require(msg.sender == player[playerId[msg.sender]].addr);
        require(block.timestamp - poolStartTime > T1 && block.timestamp - poolStartTime <= T2);

        bytes32 saltHash = keccak256(abi.encodePacked(salt));
        revealAnswer(bytes32(choice), saltHash);
        player[playerId[msg.sender]].choice = choice;
        numRevealed++;
    }

    function payPrizeToWinner() public {
        //only pool initiator can run this
        require(msg.sender == player[0].addr);
        require(block.timestamp - poolStartTime > T2 && block.timestamp - poolStartTime <= T3);

        uint confirmedCount = 0;
        uint w = 0;
        for (uint i = 0; i < numPlayer; i++) {
            address currentId = player[i].addr;
            if (commits[currentId].revealed == true && player[i].choice <= 999 && player[i].choice >= 0) {
                w = w ^ player[i].choice;
                confirmedPool[confirmedCount] = currentId;
                confirmedCount++;
            }
        }
        address payable initiator = payable(player[0].addr);
        if (confirmedCount == 0) {
            initiator.transfer(reward);
            return;
        }

        w = w % numRevealed;
        address payable winner = payable(player[w].addr);
        uint prize = reward * 98 / 100;

        winner.transfer(prize);
        initiator.transfer(reward - prize);
        isPayed = true;
    }

    function withdraw() public {
        require(block.timestamp - poolStartTime > T3);
        require(player[playerId[msg.sender]].withdrawn == false);
        require(isPayed = false);
        player[playerId[msg.sender]].withdrawn == true;
        address payable account = payable(player[playerId[msg.sender]].addr);
        account.transfer(0.001 ether);
    }
}