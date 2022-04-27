//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
interface ICBS is IERC20{
    function burnCBSFromPartnerControllers (address _user, uint _amount) external;
}
