// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => Stats) public tokenIdToStats;

    struct Stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    constructor() ERC721 ("Chain Battles", "CBTLS"){
    }

    function generateCharacter(uint256 tokenId) public returns(string memory){
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 1000 1000">',
            '<style>.base { fill: white; font-family: Microsoft YaHei; font-size: 50px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",getTokenLevel(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getTokenSpeed(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getTokenStrength(tokenId),'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",getTokenLife(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
        }

    function getTokenLevel(uint256 tokenId) public view returns (string memory) {
        Stats storage stats = tokenIdToStats[tokenId];
        return stats.level.toString();
        }

    function getTokenSpeed(uint256 tokenId) public view returns (string memory) {
        Stats storage stats = tokenIdToStats[tokenId];
        return stats.speed.toString();
        }

    function getTokenStrength(uint256 tokenId) public view returns (string memory) {
        Stats storage stats = tokenIdToStats[tokenId];
        return stats.strength.toString();
        }

    function getTokenLife(uint256 tokenId) public view returns (string memory) {
        Stats storage stats = tokenIdToStats[tokenId];
        return stats.life.toString();
        }

    function getTokenURI(uint256 tokenId) public returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Chain Battles #', tokenId.toString(), '",',
            '"description": "Battles on chain",',
            '"image": "', generateCharacter(tokenId), '"',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
    }

    function mint() public {
        _tokenIds.increment(); uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        Stats storage initialStats = tokenIdToStats[newItemId];
        initialStats.level = 0;
        initialStats.speed = 50;
        initialStats.strength = 100;
        initialStats.life = 100;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Character Not Found.");
        require(ownerOf(tokenId) == msg.sender, "You must own this Character to train it!");
        Stats storage stats = tokenIdToStats[tokenId];
        stats.level = stats.level + 1;
        stats.speed = stats.speed + 10;
        stats.strength = stats.strength + 5;
        stats.life = stats.life + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
