//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BackEnd.sol";

contract CBS is ERC20,Ownable,Backend{
    constructor() ERC20("CBS_Stable_Coin","CBS"){}
    uint public currentSupply;
    address public signer;
    mapping (address => bool) public onlyControllers;
    mapping (address => mapping (uint => bool)) public nonceChecker;

    function mintToken (BackendSigner memory backend) external {
            require (getSigner(backend) == signer,'!Signer');
            require (backend.senderAddress == msg.sender,'!User');
            require (backend.action,'!Mint');
            require (!nonceChecker[msg.sender][backend.timestamp], 'Nonce Used');
            require (backend.bankBalance == currentSupply+backend.amountToMint,'Cannot Mint');
            nonceChecker[msg.sender][backend.timestamp] = true;
            currentSupply += backend.amountToMint;
            _mint(msg.sender, backend.amountToMint);
    }

    function burnCBSFromPartnerControllers (address _user, uint _amount) external {
            require(onlyControllers[msg.sender],'!Controller');
            currentSupply -= amount;
            _burn(_user, _amount);
    }

    function addControllers(address _controllers) external onlyOwner {
        onlyControllers[_controllers] = true;
    }
}
