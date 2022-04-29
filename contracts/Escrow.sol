//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./Interfaces/ICBR.sol";
import "./Interfaces/ICBS.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./BackEnd.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";


contract escrow is Backend, OwnableUpgradeable {

    event Deposited(address indexed sender, address indexed receiver, uint256 weiAmount);
    event Withdrawn(address indexed sender, address indexed receiver, uint256 weiAmount);
    event ForcedWithdrawn(address indexed withdrawe, uint256 weiAmount);
    ICBS CBS;
    ICBR CBR;
    IERC20Upgradeable CBE;
    address public signer;
    mapping(address => mapping (uint => uint)) public _deposits;
    mapping(address => mapping (uint => uint)) public _spents;
    mapping(address => mapping (uint => address)) public senderSlotToReceiver;
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
        senderSlotToReceiver[msg.sender][_timesDeposited] = whitelist.receiverAddress;
        CBE.transferFrom(msg.sender, owner(), 100 * 1 ether);
        CBS.transferFrom(msg.sender, address(this), whitelist.amount);
        CBR.mintExactToken(msg.sender, whitelist.amount);
        emit Deposited(whitelist.senderAddress,whitelist.receiverAddress,whitelist.amount);
    }

    function withdraw(BackendSigner memory whitelist) external {
        require (getSigner(whitelist) == signer,'!Signer');
        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
        require (_spents[whitelist.senderAddress][whitelist.slotId] + whitelist.amount<=_deposits[msg.sender][whitelist.slotId],'Not Allowed');
        if (_spents[whitelist.senderAddress][whitelist.slotId] + whitelist.amount == _deposits[msg.sender][whitelist.slotId])
            delete _deposits[whitelist.senderAddress][whitelist.slotId];
        _spents[whitelist.senderAddress][whitelist.slotId] += whitelist.amount;
        CBS.transfer(senderSlotToReceiver[whitelist.senderAddress][whitelist.slotId],whitelist.amount);
        CBR.burnCBRFromPartnerControllers(whitelist.senderAddress,whitelist.amount);
        emit Withdrawn(whitelist.senderAddress, whitelist.receiverAddress, whitelist.amount);
    }

    function mutualCancellation(BackendSigner memory whitelist) external {
        require (getSigner(whitelist) == signer, '!Signer');
        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
        require (_spents[whitelist.senderAddress][whitelist.slotId]+ whitelist.amount<=_deposits[whitelist.senderAddress][whitelist.slotId],'Not Allowed');
        if (_spents[whitelist.senderAddress][whitelist.slotId] + whitelist.amount == _deposits[whitelist.senderAddress][whitelist.slotId])
            delete _deposits[whitelist.senderAddress][whitelist.slotId];
        _spents[whitelist.senderAddress][whitelist.slotId] += whitelist.amount;
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

    function addCBEAddress (address _CBE) external onlyOwner {
        CBE = IERC20Upgradeable(_CBE);
    }
}
