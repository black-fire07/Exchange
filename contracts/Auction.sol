pragma solidity ^0.8.0;

import "./Yuvan.sol";
import "./Nft.sol";

contract Auction{
    Yuvan public yuvan;
    Nft public nft;
    address public random = 0x59C9cDc74b43e3A4b7F91b56B092c80A1a78dc5A;
    
    address public beneficiary;
    
    constructor(Yuvan _yuvan, Nft _nft) {
        yuvan = _yuvan;
        nft = _nft;
    }
    
    event HighestBidInc(address bidder,uint amount);
    event AuctinEnded(address high,uint amount);
    
    bool st = false;

    mapping(address=>uint) public pendingReturns;
    address public highBidder;
    uint public highestBid;
    
    function start() public {
        if(st){
            revert("The fun auction has already been called");
        }
        beneficiary = msg.sender;
        st = true;
    }

    function bid( uint _val) public {
        require(msg.sender != beneficiary,"wa");
        if(!st){
            revert("The bid fun has already been called");
        }
        if(_val <= highestBid){
            revert("lower bid");
        }
        yuvan.approve(address(this), _val);
        yuvan.transferFrom( msg.sender,address(this), _val);
        highBidder = msg.sender;
        highestBid = _val;
        
        if(highestBid > 0){
            pendingReturns[highBidder] += highestBid;
        }
        
        emit HighestBidInc(msg.sender,_val);
    }
    
    function withdraw() public {
        require(msg.sender!=highBidder);
        require(pendingReturns[msg.sender] > 0);
        uint amount = pendingReturns[msg.sender];
        pendingReturns[msg.sender] = 0;
        yuvan.transfer(msg.sender, amount);
    }
    
    function auctionEnd(uint _tokenId) public {
        require(msg.sender == beneficiary,"wa");
        nft.transfer(highBidder, _tokenId);
        // yuvan.transfer(msg.sender, highestBid);
        st = false;
        emit AuctinEnded(highBidder,highestBid);
    }
}