// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract MockNFT is ERC721Upgradeable {
    // constructor(address _implementation) ReleaseManagerFactory(_implementation) {
        
    // }
    function init(string memory name_, string memory symbol_) public initializer {
        __ERC721_init(name_, symbol_);
    }
    
    function currentBlockTimestamp() public view returns (uint64) {
        return uint64(block.timestamp);
    }
}
 
