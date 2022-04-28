
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract Backend is EIP712 {

    string private constant SIGNING_DOMAIN = "COBE_CBS";
    string private constant SIGNATURE_VERSION = "1";

    struct BackendSigner {
        address receiverAddress;
        bool action; // this should be mint/burn. If mint = true, if burn = false.
        uint256 timestamp; //nonce
        uint256 bankBalance;
        uint256 amount; //The current amount to be minted to the user
        bytes signature;
    }

     constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){}

    function getSigner(BackendSigner memory whitelist) public view returns(address){
        return _verify(whitelist);
    }

    /// @notice Returns a hash of the given whitelist, prepared using EIP712 typed data hashing rules.

    function _hash(BackendSigner memory whitelist) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("BackendSigner(address receiverAddress,bool action,uint256 timestamp,uint256 bankBalance,uint256 amount)"),
                whitelist.receiverAddress,
                whitelist.action,
                whitelist.timestamp,
                whitelist.bankBalance,
                whitelist.amount
            )));
    }

    function _verify(BackendSigner memory whitelist) internal view returns (address) {
        bytes32 digest = _hash(whitelist);
        return ECDSA.recover(digest, whitelist.signature);
    }

}