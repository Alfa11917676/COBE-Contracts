////SPDX-License-Identifier: UNLICENSED
//
//pragma solidity ^0.8.0;
//import "./Interfaces/ICBR.sol";
//import "./Interfaces/ICBS.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import "./BackEnd.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
//
//
//contract escrow is Backend, OwnableUpgradeable {
//
//    event Deposited(address indexed sender, address indexed receiver, uint256 weiAmount);
//    event MileStoneDeposited(address indexed sender, address indexed receiver, uint256[] payments);
//    event MileStoneWithdraw(address indexed sender, address indexed receiver, uint256 payments);
//    event Withdrawn(address indexed sender, address indexed receiver, uint256 weiAmount);
//    event ForcedWithdrawn(address indexed withdrawe, uint256 weiAmount);
//    event ForcedMileStoneWithdrawn(address indexed withdrawe, uint256 weiAmount);
//    ICBS CBS;
//    ICBR CBR;
//    IERC20Upgradeable CBE;
//    address public signer;
//    mapping(address => mapping (uint => uint)) public _deposits;
//    mapping(address => mapping (uint => uint)) public _spents;
//    mapping(address => mapping (uint => address)) public senderSlotToReceiver;
//    mapping(address => mapping (uint => uint)) public slotPayment;
//    mapping (address => uint) public _timesDeposited;
//    mapping (address => mapping (uint => uint)) public slotPayed;
//    mapping (address => mapping (uint => mapping (address => mapping (uint => uint)))) public mileStonePaymentAmount;
//    mapping (address => mapping (uint => uint)) public mileStonePaymentSlots;
//    mapping (address => mapping (uint => uint)) public mileStonePaymentReleased;
//    mapping (address => mapping (uint => bool)) public nonce;
//
//    function initialize(address _cbs, address _cbr) public initializer {
//        __Backend_init();
//        __Ownable_init();
//        CBS = ICBS(_cbs);
//        CBR = ICBR(_cbr);
//    }
//
//    function deposit(BackendSigner memory whitelist) external {
//        require (getSigner(whitelist)==signer,'!Signer');
//        require (msg.sender == whitelist.senderAddress,'!Expected');
//        _timesDeposited[msg.sender]++;
//        _deposits[msg.sender][_timesDeposited[msg.sender]] = whitelist.amount;
//        senderSlotToReceiver[msg.sender][_timesDeposited[msg.sender]] = whitelist.receiverAddress;
//        CBE.transferFrom(msg.sender, owner(), 100 * 1 ether);
//        CBS.transferFrom(msg.sender, address(this), whitelist.amount);
//        CBR.mintExactToken(msg.sender, whitelist.amount);
//        emit Deposited(whitelist.senderAddress,whitelist.receiverAddress,whitelist.amount);
//    }
//
//    function withdraw(BackendSigner memory whitelist) external {
//        require (getSigner(whitelist) == signer,'!Signer');
//        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
//        require (_spents[whitelist.senderAddress][whitelist.slotId] + whitelist.amount<=_deposits[msg.sender][whitelist.slotId],'Not Allowed');
//        require (!nonce[whitelist.senderAddress][whitelist.timestamp],'!Already Done');
//        nonce[whitelist.senderAddress][whitelist.timestamp] = true;
//        if (_spents[whitelist.senderAddress][whitelist.slotId] + whitelist.amount == _deposits[msg.sender][whitelist.slotId])
//            delete _deposits[whitelist.senderAddress][whitelist.slotId];
//        _spents[whitelist.senderAddress][whitelist.slotId] += whitelist.amount;
//        CBS.transfer(senderSlotToReceiver[whitelist.senderAddress][whitelist.slotId],whitelist.amount);
//        CBR.burnCBRFromPartnerControllers(whitelist.senderAddress,whitelist.amount);
//        emit Withdrawn(whitelist.senderAddress, whitelist.receiverAddress, whitelist.amount);
//    }
//
//    function mutualCancellation(BackendSigner memory whitelist) external {
//        require (getSigner(whitelist) == signer, '!Signer');
//        require (msg.sender == whitelist.senderAddress || msg.sender == owner(),'!Allowed');
//        require (_spents[whitelist.senderAddress][whitelist.slotId]+ whitelist.amount<=_deposits[whitelist.senderAddress][whitelist.slotId],'Not Allowed');
//        require (!nonce[whitelist.senderAddress][whitelist.timestamp],'!Already Done');
//        nonce[whitelist.senderAddress][whitelist.timestamp] = true;
//        if (_spents[whitelist.senderAddress][whitelist.slotId] + whitelist.amount == _deposits[whitelist.senderAddress][whitelist.slotId])
//            delete _deposits[whitelist.senderAddress][whitelist.slotId];
//        _spents[whitelist.senderAddress][whitelist.slotId] += whitelist.amount;
//        CBS.transfer(whitelist.senderAddress, whitelist.amount);
//        CBR.burnCBRFromPartnerControllers(whitelist.senderAddress, whitelist.amount);
//        emit ForcedWithdrawn(whitelist.senderAddress, whitelist.amount);
//    }
//
//
//    function createMileStonePayment (uint[] memory payments,address payee) external {
//        uint finalAmount;
//        _timesDeposited[msg.sender]++;
//        for (uint i;i<payments.length;i++) {
//            mileStonePaymentAmount[msg.sender][_timesDeposited[msg.sender]][payee][i+1] = payments[i];
//            finalAmount += payments[i];
//        }
//        _deposits[msg.sender][_timesDeposited[msg.sender]] = finalAmount;
//        senderSlotToReceiver[msg.sender][_timesDeposited[msg.sender]] = payee;
//        mileStonePaymentSlots[msg.sender][_timesDeposited[msg.sender]] = payments.length;
//        CBE.transferFrom(msg.sender, owner(), 100 * 1 ether);
//        CBS.transferFrom(msg.sender, address(this), finalAmount);
//        CBR.mintExactToken(msg.sender,finalAmount);
//        emit MileStoneDeposited (msg.sender, payee, payments);
//    }
//
//    function withdrawMileStonePayment (BackendSigner memory whitelist) external {
//        require (getSigner(whitelist) == signer,'!Signer');
//        require (msg.sender == whitelist.senderAddress || owner() == msg.sender,'!Allowed');
//        require (mileStonePaymentReleased[whitelist.senderAddress][whitelist.slotId]+1 <= mileStonePaymentSlots[msg.sender][whitelist.slotId],'Miles Stones Over');
//        require (!nonce[whitelist.senderAddress][whitelist.timestamp],'!Already Done');
//        nonce[whitelist.senderAddress][whitelist.timestamp] = true;
//        mileStonePaymentReleased[whitelist.senderAddress][whitelist.slotId]+=1;
//        uint amountToSend = mileStonePaymentAmount[whitelist.senderAddress][whitelist.slotId]
//        [senderSlotToReceiver[whitelist.senderAddress][whitelist.slotId]]
//        [mileStonePaymentReleased[whitelist.senderAddress][whitelist.slotId]];
//        require (
//            _spents[whitelist.senderAddress][whitelist.slotId]+
//            mileStonePaymentAmount[whitelist.senderAddress]
//            [whitelist.slotId]
//            [senderSlotToReceiver[whitelist.senderAddress][whitelist.slotId]]
//            [mileStonePaymentReleased[whitelist.senderAddress][whitelist.slotId]]
//            <=
//            _deposits[whitelist.senderAddress][whitelist.slotId],
//                'Not Allowed');
//        if (    _spents[whitelist.senderAddress][whitelist.slotId]+
//                amountToSend
//                ==
//                _deposits[whitelist.senderAddress][whitelist.slotId]
//            )
//            delete _deposits[whitelist.senderAddress][whitelist.slotId];
//        _spents[whitelist.senderAddress][whitelist.slotId] += amountToSend;
//        delete mileStonePaymentAmount[whitelist.senderAddress][whitelist.slotId]
//        [senderSlotToReceiver[whitelist.senderAddress][whitelist.slotId]]
//        [mileStonePaymentReleased[whitelist.senderAddress][whitelist.slotId]];
//        CBS.transfer(
//                        senderSlotToReceiver[whitelist.senderAddress][whitelist.slotId],amountToSend
//        );
//        CBR.burnCBRFromPartnerControllers(whitelist.senderAddress, amountToSend);
//
//        emit MileStoneWithdraw(whitelist.senderAddress, senderSlotToReceiver[whitelist.senderAddress][whitelist.slotId], amountToSend);
//    }
//
//    function mutualCancellationOfMileStonePayment(BackendSigner memory backend) external {
//        require (getSigner(backend) == signer, '!Signer');
//        require (msg.sender == backend.senderAddress || msg.sender == owner(),'!Allowed');
//        require (mileStonePaymentSlots[msg.sender][backend.slotId]>=mileStonePaymentReleased[backend.senderAddress][backend.slotId]+1,'None remaining');
//        require (!nonce[backend.senderAddress][backend.timestamp],'!Already Done');
//        nonce[backend.senderAddress][backend.timestamp] = true;
//        uint totalMileStoneReamining = mileStonePaymentSlots[backend.senderAddress][backend.slotId];// - mileStonePaymentReleased[msg.sender][backend.slotId];
//        uint toStart = mileStonePaymentReleased[msg.sender][backend.slotId]+1;
//        uint totalMoney;
//        for (uint i = toStart; i <= totalMileStoneReamining; i++) {
//            mileStonePaymentReleased[backend.senderAddress][backend.slotId]+=1;
//            totalMoney+=mileStonePaymentAmount[backend.senderAddress][backend.slotId]
//            [senderSlotToReceiver[backend.senderAddress][backend.slotId]]
//            [mileStonePaymentReleased[backend.senderAddress][backend.slotId]];
//            delete mileStonePaymentAmount[backend.senderAddress][backend.slotId]
//            [senderSlotToReceiver[backend.senderAddress][backend.slotId]]
//            [mileStonePaymentReleased[backend.senderAddress][backend.slotId]];
//        }
//        _spents[backend.senderAddress][backend.slotId] += totalMoney;
//        delete _deposits[backend.senderAddress][backend.slotId];
//        delete senderSlotToReceiver[backend.senderAddress][backend.slotId];
//        delete mileStonePaymentSlots[backend.senderAddress][backend.slotId];
//        CBS.transfer(backend.senderAddress, totalMoney);
//        CBR.burnCBRFromPartnerControllers(backend.senderAddress, totalMoney);
//        emit ForcedMileStoneWithdrawn(backend.senderAddress, totalMoney);
//    }
//
//    function addCBSAddress (address _token) external onlyOwner {
//        CBS = ICBS(_token);
//    }
//    function addCBRAddress (address _token) external onlyOwner {
//        CBR = ICBR(_token);
//    }
//    function addSigner (address _signature) external onlyOwner {
//        signer = _signature;
//    }
//
//    function addCBEAddress (address _CBE) external onlyOwner {
//        CBE = IERC20Upgradeable(_CBE);
//    }
//}
