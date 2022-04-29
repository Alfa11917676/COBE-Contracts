
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";

contract Backend is EIP712Upgradeable {

    string private constant SIGNING_DOMAIN = "COBE";
    string private constant SIGNATURE_VERSION = "1";

    struct BackendSigner {
        address senderAddress; //the address of the interacting user
        address receiverAddress;
        bool action; // this should be mint/burn. If mint = true, if burn = false.
        uint256 numberOfSlots;
        uint256 slotId;
        uint256 timestamp; //nonce
        uint256 bankBalance;
        uint256 amount; //The current amount to be minted to the user
        bytes signature;
    }

    function __Backend_init() internal {
        __EIP712_init(SIGNING_DOMAIN, SIGNATURE_VERSION);
    }

    function getSigner(BackendSigner memory whitelist) public view returns(address){
        return _verify(whitelist);
    }

    /// @notice Returns a hash of the given whitelist, prepared using EIP712 typed data hashing rules.

    function _hash(BackendSigner memory whitelist) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("BackendSigner(address senderAddress,address receiverAddress,bool action,uint256 numberOfSlots,uint256 slotId,uint256 timestamp,uint256 bankBalance,uint256 amount)"),
                whitelist.senderAddress,
                whitelist.receiverAddress,
                whitelist.action,
                whitelist.numberOfSlots,
                whitelist.slotId,
                whitelist.timestamp,
                whitelist.bankBalance,
                whitelist.amount
            )));
    }

    function _verify(BackendSigner memory whitelist) internal view returns (address) {
        bytes32 digest = _hash(whitelist);
        return ECDSAUpgradeable.recover(digest, whitelist.signature);
    }

}