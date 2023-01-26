// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IAuction.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

contract AuctionFactory {
    
    function produce(IAuction.AuctionParams memory) public returns (address instance) {}

}