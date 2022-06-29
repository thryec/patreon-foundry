//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract CreatorList is Ownable {
    // public mint
    bytes32 public creatorListMerkleRoot;

    // Frontend verify functions
    function verifyMsgSender(address userAddress, bytes32[] memory proof)
        public
        view
        returns (bool)
    {
        return _verify(proof, _hash(userAddress), creatorListMerkleRoot);
    }

    // Internal verify functions
    function _verifyMsgSender(bytes32[] memory proof)
        internal
        view
        returns (bool)
    {
        return _verify(proof, _hash(msg.sender), creatorListMerkleRoot);
    }

    function _verify(
        bytes32[] memory proof,
        bytes32 addressHash,
        bytes32 creatorListMerkleRoot
    ) internal pure returns (bool) {
        return MerkleProof.verify(proof, creatorListMerkleRoot, addressHash);
    }

    function _hash(address _address) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_address));
    }

    function setcreatorListMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        creatorListMerkleRoot = merkleRoot;
    }

    modifier onlyCreatorList(bytes32[] memory proof) {
        require(
            _verifyPublicSender(proof),
            "CreatorList: Caller is not on the Creator List"
        );
        _;
    }
}
