pragma solidity 0.6.0;

contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract LotteryArray is SafeMath {
    address internal owner;
    uint256 internal aux;
    
    uint256 public ticketValue;
    
    bool public gamePlaying;
    address public winner;

    address[] public tickets;
    uint256 public totalPlayers;
    
    constructor(uint256 _ticketValue) public payable {
        owner = msg.sender;
        aux = 0;
        ticketValue = _ticketValue;
        gamePlaying = true;
        totalPlayers = 5;
    }
    
    
    function ramdomNum() internal view returns(uint256) {
        return uint256( keccak256( abi.encode(now, msg.sender, aux)) ) % totalPlayers;
    }
    
    function play() external payable returns(uint256 userNumber) {
        require(msg.value == ticketValue);
        
        if (gamePlaying == false) {
            delete tickets;
            gamePlaying = true;
        }
        
        tickets.push(msg.sender);
        

        if (tickets.length == totalPlayers) { 
            
            userNumber = ramdomNum();
        
            gamePlaying = false;

            winner = tickets[userNumber];
            
            address payable wallet = payable(winner);
            transferToWallet(wallet, 2);
            
            address payable walletOwner = payable(owner);
            transferToWallet(walletOwner, 1);
        }
        
        aux++;
    }
    
    function showPrize() public view returns(uint256 balance, uint256 totalBalance) {
        balance = safeDiv(address(this).balance, 2);
        totalBalance = address(this).balance;
    }
    
    function transferToWallet(address payable _to, uint256 div) public {
        _to.transfer(safeDiv(address(this).balance, div));
    }
    
    function setTicketValue(uint256 _ticketValue) external {
        require(msg.sender == owner);
        require(gamePlaying == false);

        ticketValue = _ticketValue;
    }
    
    function setNumberOfPlayers(uint256 _totalPlayers) external { 
        require(msg.sender == owner);
        require(gamePlaying == false);
        
        totalPlayers = _totalPlayers;
    }
}
