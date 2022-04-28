//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract CBE is ERC20, Ownable {

    mapping (address => bool) public accessControllers;

    constructor () ERC20 ("COBE_Utility_Coin","CBE"){
        _mint(msg.sender, 10_000_000_000* 1 ether);
    }

    function burnCBRFromPartnerControllers(uint _amount) external {
        _burn(msg.sender, _amount);
    }
}
