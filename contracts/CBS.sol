//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BackEnd_CBS.sol";

contract CBS is ERC20,Ownable,Backend{
    constructor() ERC20("CBS_Stable_Coin","CBS"){}
    uint public currentSupply;
    address public signer;
    mapping (address => mapping (uint => bool)) public nonceChecker;

    function mintToken (BackendSigner memory backend) external {
            require (getSigner(backend) == signer,'!Signer');
            require (backend.receiverAddress == msg.sender,'!User');
            require (backend.action,'!Mint');
            require (!nonceChecker[msg.sender][backend.timestamp], 'Nonce Used');
            require (backend.bankBalance == currentSupply+backend.amount,'Cannot Mint');
            nonceChecker[msg.sender][backend.timestamp] = true;
            currentSupply += backend.amount;
            _mint(msg.sender, backend.amount);
    }

    function burnCBSFromPartnerControllers (uint _amount) external {
            currentSupply -= _amount;
            _burn(msg.sender, _amount);
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}
