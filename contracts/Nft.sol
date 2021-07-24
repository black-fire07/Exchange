pragma solidity ^0.8.0;

contract Nft {
    event Mint(address indexed _to, uint256 indexed _tokenId, string _ipfsHash);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    uint256 public tokenCounter = 1;
    mapping(uint256 => address) public idToOwner;

    function mint(string memory _ipfsHash,uint256 _id) public {
        uint256 _tokenId = tokenCounter;
        idToOwner[_id] = msg.sender;
        tokenCounter++;
        emit Mint(msg.sender, _tokenId, _ipfsHash);
    }

    function transfer(address _to, uint _tokenId) public returns(bool){
        require(msg.sender == idToOwner[_tokenId]);
        idToOwner[_tokenId] = _to;
        emit Transfer(msg.sender, _to, _tokenId);
        return true;
    }
}