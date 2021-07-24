pragma solidity ^0.8.0;

import "./Token.sol";
import "./Yuvan.sol";

contract EthSwap {
    string public name = "EthSwap Exchange";
    Token public token;
    Yuvan public yuvan;
    uint public rate = 100;

    event Tpurchased(
        address account,
        address token,
        uint amount,
        uint rate
    );
    event Tsold(
        address account,
        address token,
        uint amount,
        uint rate
    );

    constructor(Token _token,Yuvan _yuvan) {
        token = _token;
        yuvan = _yuvan;
    }

    function buyTokens() public payable{
        uint val = msg.value * rate;
        require(token.balanceOf(address(this)) >= val);
        token.transfer(msg.sender, val);
        emit Tpurchased(msg.sender, address(token), val, rate);
    }
    
    
    function sellTokens(uint _amount) public {
        require(token.balanceOf(msg.sender) >= _amount);
        uint ethamount = _amount/rate;
        require(address(this).balance >= ethamount);
        token.approve(msg.sender, _amount);
        token.transferFrom(msg.sender, address(this), _amount);
        payable (msg.sender).transfer(ethamount);
        emit Tsold(msg.sender, address(token), _amount, rate);
    }

    function exchange(uint _val) public {
        require(token.balanceOf(msg.sender) >= _val);
        require(yuvan.balanceOf(address(this)) >= _val);
        yuvan.transfer(msg.sender,_val);
        // token.transfer(yuvan.led, _val);
        token.approve(msg.sender, _val);
        token.transferFrom(msg.sender, yuvan.ad(), _val);
    }
}