//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BackEnd_CBS.sol";

contract CBS is ERC20,Ownable,Backend{
    constructor() ERC20("CBS_Stable_Coin","CBS"){

    }
    uint public currentSupply;
    address public signer;
    mapping (address => bool) public onlyControllers;
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

    function burnCBSFromPartnerControllers (address _user, uint _amount) external {
            require(onlyControllers[msg.sender],'!Controller');
            currentSupply -= _amount;
            _burn(_user, _amount);
    }

    function addControllers(address _controllers) external onlyOwner {
        onlyControllers[_controllers] = true;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}
