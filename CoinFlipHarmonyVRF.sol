// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/* @PROJECT NAME- GAMEFLIP GAME IN Web3
     @BUILT - A “Coin Flip” betting game in the Solidity language using the Harmony testnet and Harmony VRF (Verifiable Random Function).
     @author- Apoorv Anand @email-1032171293@mitwpu.edu.in @PhoneNo- 7028164447.
     @Used Harmony testnet and Harmony VRF for Random calculations.
*/

contract CoinFlip{

//Alwayays set deployer as owner and in Private
 address private owner;  
 
 
 // Modifier to check if caller is owner
 modifier isOwner {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor(){
        owner = msg.sender;
    }
 //Event for Placing a Bet.
    event betPlaced(uint8 bet, address userAdd, uint amount);

 //Event for Winning a Bet.
    event betWon(uint8 bet, address userAdd, uint amount);


    struct User{
        // Total Money - 1000(by Default)
        uint userBalance;
        // Amount To Bet On CoinFlip By the User
        uint betAmount;
        // 0: Heads, 1: Tails
        uint8 expectedOutcome;
        // 0: new user and not betted 1: old user and no currnet bets, 2: betted and result pending
        uint8 status;
    }


    uint public userCount=0; // total users


    // Mapping Structure to store dta of diffrent users
    mapping(address => User) public users;

    address[] usersBetted; // stores all users who have placed a bet
    
 /**
     * A user can place its bet (New user get 1000 bucks)
     *  _bet   0: Heads, 1: Tails
     * _amount the amount user wants to bet
    */
    
    
    
    function placeBet(uint8 _bet, uint _amount) public {
        
        if(users[msg.sender].status==0){//checks if it is a new user
            users[msg.sender].userBalance = 1000;
            users[msg.sender].status=1;
        }
        require(users[msg.sender].userBalance >= _amount, "Bet amount should be greater than 0 and less than user balance");
        require(users[msg.sender].status==1, "User has already betted");

        users[msg.sender].betAmount = _amount;
        users[msg.sender].userBalance = users[msg.sender].userBalance - _amount;
        users[msg.sender].expectedOutcome = _bet;
        users[msg.sender].status=2;
        usersBetted.push(msg.sender);

        emit betPlaced(_bet, msg.sender, _amount);
    }

    // Concludes all the current bets (invoked only by the owner)
   
    function rewardBets() public {

        uint8 outcome =uint8(uint(vrf())%2);// random number generated using harmony vrf

        for(uint i=0;i<=usersBetted.length;i++){
           address userAdd = usersBetted[i];
           if(users[userAdd].expectedOutcome == outcome){
                users[userAdd].userBalance = users[userAdd].userBalance + 2*users[userAdd].betAmount;
                users[userAdd].betAmount = 0;
                emit betWon(outcome, userAdd, 2*users[userAdd].betAmount);
           }
            users[userAdd].status=1;
        }

        delete usersBetted;
    }

    // Harmony VRF IMPLEMENTATION 
    
    
    
    function vrf() public view returns (bytes32 result) {
        uint[1] memory bn;
        bn[0] = block.number;
        assembly {
            let memPtr := mload(0x40)
            if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
                invalid()
            }
            result := mload(memPtr)
        }
  }

}
