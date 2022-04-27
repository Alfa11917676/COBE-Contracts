//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract CBR is ERC20, Ownable {

    mapping (address => bool) public accessControllers;

    constructor () ERC20 ("COBE_Redeem_Coin","CBR"){}

    function setAccessControllers (address _controllers) external onlyOwner {
        accessControllers[_controllers] = true;
    }

    function mintExactToken(address user, uint _amount) external {
            _mint(user, _amount);
    }

    function burnCBRFromPartnerControllers(address user, uint _amount) external {
        require(accessControllers[msg.sender],'!Controller');
        _burn(user, _amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override{
        require (accessControllers[msg.sender],'Not Allowed To Transfer Funds');
        super._beforeTokenTransfer(from,to,amount);
    }
}
