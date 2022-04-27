//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
interface ICBR is IERC20{
    function burnCBRFromPartnerControllers (address _user, uint _amount) external;
    function mintExactToken(address user, uint _amount) external;
}
