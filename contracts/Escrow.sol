//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./Interfaces/ICBR.sol";
import "./Interfaces/ICBS.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./BackEnd.sol";


contract escrow is Backend, OwnableUpgradeable {

    event Deposited(address indexed sender, address indexed receiver, uint256 weiAmount);
    event Withdrawn(address indexed sender, address indexed receiver, uint256 weiAmount);
    event ForcedWithdrawn(address indexed withdrawe, uint256 weiAmount);
    ICBS CBS;
    ICBR CBR;
    address public signer;
    mapping(address => mapping (uint => uint)) public _deposits;
    mapping(address => mapping (uint => uint)) public _spents;
    mapping (address => uint) public _timesDeposited;

    function initialize(address _cbs, address _cbr) public initializer {
        __Backend_init();
        __Ownable_init();
        CBS = ICBS(_cbs);
        CBR = ICBR(_cbr);
    }

    function deposit(BackendSigner memory whitelist) external {
        require (getSigner(whitelist)==signer,'!Signer');
        require (msg.sender == whitelist.senderAddress,'!Expected');
        _timesDeposited[msg.sender]++;
        _deposits[msg.sender][_timesDeposited[msg.sender]] = whitelist.amount;
        CBS.transferFrom(msg.sender, address(this), whitelist.amount);
        CBR.mintExactToken(msg.sender, whitelist.amount);
        emit Deposited(whitelist.senderAddress,whitelist.receiverAddress,whitelist.amount);
    }

    function withdraw(BackendSigner memory whitelist, uint slotId ) external {
        require (getSigner(whitelist) == signer,'!Signer');
        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
        require (_spents[whitelist.senderAddress][slotId] + whitelist.amount<=_deposits[msg.sender][slotId],'Not Allowed');
        if (_spents[whitelist.senderAddress][slotId] + whitelist.amount == _deposits[msg.sender][slotId])
            delete _deposits[whitelist.senderAddress][slotId];
        _spents[whitelist.senderAddress][slotId] += whitelist.amount;
        CBS.transfer(whitelist.receiverAddress,whitelist.amount);
        CBR.burnCBRFromPartnerControllers(whitelist.senderAddress,whitelist.amount);
        emit Withdrawn(whitelist.senderAddress, whitelist.receiverAddress, whitelist.amount);
    }

    function mutualCancellation(BackendSigner memory whitelist, uint slotId) external {
        require (getSigner(whitelist) == signer, '!Signer');
        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
        require (_spents[whitelist.senderAddress][slotId]+ whitelist.amount<=_deposits[whitelist.senderAddress][slotId],'Not Allowed');
        if (_spents[whitelist.senderAddress][slotId] + whitelist.amount == _deposits[whitelist.senderAddress][slotId])
            delete _deposits[whitelist.senderAddress][slotId];
        _spents[whitelist.senderAddress][slotId] += whitelist.amount;
        CBS.transfer(whitelist.senderAddress, whitelist.amount);
        CBR.burnCBRFromPartnerControllers(whitelist.senderAddress, whitelist.amount);
        emit ForcedWithdrawn(whitelist.senderAddress, whitelist.amount);
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
