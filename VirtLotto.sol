pragma solidity ^0.4.18;

contract VirtLotto {
    address public owner;
    
    uint public minimumBet = 100 finney;
    uint public totalBet = 0;
    uint public numberOfBets = 0;
    uint public maxNumberOfBets = 0;
    uint public constant MIN_NUMBER = 1;
    uint public constant MAX_NUMBER = 10;
    uint public constant NUMBER_OF_BETS_PER_PLAYER = 4;
    
    address[] public players;
    address[] public winners;
    struct Bet {
        uint[] amountsBet;
        uint[] numbersSelected;
        uint countOfBets;
    }
    mapping(address => Bet) public playerInfo;
    
    function VirtLotto(uint _minimumBet, uint _maxNumberOfBets) public {
        if (_minimumBet > 0) {
            minimumBet = _minimumBet;
        }
        if (_maxNumberOfBets > 0) {
            maxNumberOfBets = _maxNumberOfBets;
        }
        owner = msg.sender;
    }
    
    function pickNumber(uint numberSelected) public payable {
        require(numberSelected >= MIN_NUMBER && numberSelected <= MAX_NUMBER);
        require(msg.value >= minimumBet);
    
        if (!checkPlayerExists(msg.sender)) {
            playerInfo[msg.sender].amountsBet.push(msg.value);
            playerInfo[msg.sender].numbersSelected.push(numberSelected);
            playerInfo[msg.sender].countOfBets = 1;
            
            players.push(msg.sender);
        } else {
            uint countOfBets = playerInfo[msg.sender].countOfBets;
            require(countOfBets < NUMBER_OF_BETS_PER_PLAYER);
            playerInfo[msg.sender].amountsBet.push(msg.value);
            playerInfo[msg.sender].numbersSelected.push(numberSelected);
            playerInfo[msg.sender].countOfBets++;  
        }
        
        totalBet += msg.value;
        numberOfBets++;
        
        if (numberOfBets >= maxNumberOfBets) {
            generateWinner();
        }
    }
    
    function checkPlayerExists(address player) public view returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return true;
            }
        }
        return false;
    }
    
    // TODO: change back to private
    function random() view public returns (uint) {
        return uint(uint256(keccak256(block.timestamp, block.difficulty)) % 10)+1; 
    }
    
    function generateWinner() private {
        //require(owner == msg.sender);
        uint winningNumber = random();
        distributePrizes(winningNumber);
    }
    
    function distributePrizes(uint winningNumber) public {
        uint count = 0;
        address playerAddress;
        for (uint i = 0; i < players.length; i++) {
            playerAddress = players[i];
            for (uint j = 0; j < playerInfo[playerAddress].countOfBets; j++) {
                if (playerInfo[playerAddress].numbersSelected[j] == winningNumber) {
                    winners.push(playerAddress);
                    count++;
                }    
            }
        }
        
        if (count > 0) {
            uint winnerEtherAmount = totalBet / count;
            for (uint k = 0; k < count; k++) {
                if (winners[k] != address(0)) {
                    winners[k].transfer(winnerEtherAmount);
                }
            }
        } else {
            for (uint m = 0; m < players.length; m++) {
                playerAddress = players[m];
                for (uint o = 0; o < playerInfo[playerAddress].countOfBets; o++) {
                    playerAddress.transfer(playerInfo[playerAddress].amountsBet[o]);
                }
            }
        }
        
        players.length = 0;
        
        totalBet = 0;
        numberOfBets = 0;
        for (uint p = 0; p < players.length; p++) {
            playerAddress = players[p];
            delete(playerInfo[playerAddress]);
        }
    }
}