// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


/*

*/

contract GameItems is ERC1155 {

    uint256 public constant GOLD = 0; //fungible 
    uint256 public constant SILVER = 1; //fungible 
    uint256 public constant THORS_HAMMER = 2; //non-fungible 
    uint256 public constant SWORD = 3; //fungible 
    uint256 public constant SHIELD = 4; //fungible 
    uint256 public constant GODS_SWORD = 5; //non-fungible 
    uint256 public constant GODS_SHIELD = 6; // fungible

    uint256 public constant SILVER_PER_GOLD = 100;

    mapping(uint256 => uint256) public costOf; // prices is in silver!
    mapping(uint256 => uint256) public breedRates; // id => amount needed to breed 1 ugrapde

    struct BreedMapEntry {
        uint256 newID; //resulting token id
        uint256 maxSupply; 
        uint256 totalSupply; // amount of minted upgrades for this ingredient
    }
    mapping(uint256 => BreedMapEntry) public breedMap; // id => resulting id
    
    address public owner;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        owner = msg.sender;
        _mint(owner, GOLD, 10**18, "");
        _mint(owner, SILVER, 10**27, "");
        _mint(owner, THORS_HAMMER, 1, "");
        _mint(owner, SWORD, 10**9, "");
        _mint(owner, SHIELD, 10**9, "");

        costOf[THORS_HAMMER] = 10**6 * SILVER_PER_GOLD;
        costOf[SWORD] = 1500;
        costOf[SHIELD] = 1450;

        breedRates[SWORD] = 10*6;
        breedRates[SHIELD] = 10*5;

        breedMap[SWORD] = BreedMapEntry(GODS_SWORD, 1, 0);
        breedMap[SHIELD] = BreedMapEntry(GODS_SHIELD, 1000, 0);
    }
    
    function forgeThorsHammer() public {
        transferGold(msg.sender, owner, getGoldCost(THORS_HAMMER));
        // this will revert if already forged
        safeTransferFrom(owner, msg.sender, THORS_HAMMER, 1, "");
    }

    function forgeFungible(uint256 id, uint256 amount) public {
        require(balanceOf(owner, id) > 0, "Can't forge this anymore.");
        require(balanceOf(owner, id) >= amount, "Can't forge that much!");
        transferSilver(msg.sender, owner, getSilverCost(id));
        safeTransferFrom(owner, msg.sender, id, amount, "");
    }

    function breed(uint256 id) public {
        require(balanceOf(msg.sender, id) >= breedRates[id], "Not enough ingredients!");
        require(breedMap[id].maxSupply > breedMap[id].totalSupply, "Can't breed more of this."); // this is basically 
        _burn(msg.sender, id, breedRates[id]);
        _mint(msg.sender, breedMap[id].newID, 1, "");
        breedMap[id].totalSupply += 1;
    }

    function getGoldCost(uint256 id) public view returns (uint256) {
        return costOf[id] / SILVER_PER_GOLD;
    }

    function getSilverCost(uint256 id) public view returns (uint256) {
        return costOf[id];
    }

    function transferSilver(address from, address to, uint256 amount) public {
        safeTransferFrom(from, to, SILVER, amount, "0x0");
    }

    function transferGold(address from, address to, uint256 amount) public {
        safeTransferFrom(from, to, GOLD, amount, "0x0");
    }

}