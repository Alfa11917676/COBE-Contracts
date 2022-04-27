//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./Interfaces/ICBR.sol";
import "./Interfaces/ICBS.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BackEnd.sol";


contract escrow is Backend, Ownable {

    event Deposited(address indexed sender, address indexed receiver, uint256 weiAmount);
    event Withdrawn(address indexed sender, address indexed receiver, uint256 weiAmount);
    ICBS CBS;
    ICBR CBR;
    address public signer;
    mapping(address => mapping (uint => uint)) public _deposits;
    mapping (address => mapping (address => uint)) public _timesDeposited;

    function deposit(BackendSigner memory whitelist) external {
        require (getSigner(whitelist)==signer,'!Signer');
        require (msg.sender == whitelist.senderAddress,'!Expected');
        _timesDeposited[msg.sender][whitelist.receiverAddress]+=1;
        _deposits[msg.sender][_timesDeposited[msg.sender][whitelist.receiverAddress]] = whitelist.amountToMint;
        CBS.transferFrom(msg.sender, address(this), whitelist.amountToMint);
        CBR.mintExactToken(msg.sender, whitelist.amountToMint);
        emit Deposited(whitelist.senderAddress,whitelist.receiverAddress,whitelist.amountToMint);
    }

    function withdraw(BackendSigner memory whitelist, uint slotId ) external {
        require (getSigner(whitelist) == signer,'!Signer');
        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
        uint amount = _deposits[whitelist.senderAddress][slotId];
        require (amount > 0,'Insufficient Amount');
        delete _deposits[whitelist.senderAddress][slotId];
        CBS.transfer(whitelist.receiverAddress,amount);
        CBR.burnCBRFromPartnerControllers(whitelist.senderAddress,amount);
        emit Withdrawn(msg.sender, whitelist.receiverAddress, amount);
    }

    function addCBSAddress (address _token) external onlyOwner {
        CBS = ICBS(_token);
    }
    function addCBRAddress (address _token) external onlyOwner {
        CBR = ICBR(_token);
    }
    function addSigner (address _signature) external onlyOwner {
        signer = _signature;
    }
}
