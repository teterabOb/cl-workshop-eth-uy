// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

// Una vez el contrato se despliega tenemos que
// ejecutar la funcion safeMint con tu address
contract DNFT is AutomationCompatibleInterface, ERC721, ERC721URIStorage  {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint interval;
    uint lastTimeStamp;

    enum Status{
        First,
        Second,
        Theird
    }

    mapping (uint256 => Status) nftStatus;

    //Estos valores sonn estaticos pero el NFT ira apuntando
    // a cualquier de estos valores a medida que va evolucionando
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmamvGzjzXG5mu3etU5RUSWKWRVthMCJDGCydfJUwPLjne/1_charmander.json",
        "https://ipfs.io/ipfs/QmamvGzjzXG5mu3etU5RUSWKWRVthMCJDGCydfJUwPLjne/2_charmeleon.json",
        "https://ipfs.io/ipfs/QmamvGzjzXG5mu3etU5RUSWKWRVthMCJDGCydfJUwPLjne/3_charizard.json"        
    ];

    constructor(uint _interval) ERC721("dNFT", "PdNFT") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;        
    }

    function performUpkeep(bytes calldata /* performData */) external override  {        
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            updateAllNFTs();            
        }        
    }

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);      
        nftStatus[tokenId] = Status.First;  
    }

    function updateAllNFTs() public {
        uint counter = _tokenIdCounter.current();
        for(uint i = 0; i < counter; i++){
            updateStatus(i);
        }
    }

    function updateStatus(uint256 _tokenId) public {
        uint256 currentStatus = getNFTStatus(_tokenId);

        if(currentStatus == 0){
             nftStatus[_tokenId] = Status.Second; 
        }
        else if(currentStatus == 1){
             nftStatus[_tokenId] = Status.Theird; 
        }
        else if(currentStatus == 2){
            nftStatus[_tokenId] = Status.First;
        }
    }

    // helper functions
    function getNFTStatus(uint256 _tokenId) public view returns(uint256){
        Status statusIndex = nftStatus[_tokenId];
        return uint(statusIndex);
    }

    function getUriByStatus(uint256 _tokenId) public view returns(string memory){
        Status statusIndex = nftStatus[_tokenId];
        return IpfsUri[uint(statusIndex)];
    }

    // The following functions are overrides required by Solidity.
    //
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return getUriByStatus(tokenId);
    }
}
