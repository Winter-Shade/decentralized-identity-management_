// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerifyCredentials {
    struct Credential {
        string credentialHash; // Hash of the verifiable credential
        address issuer; // Institution that issued the credential
        address holder; // User who received the credential
        bool isValid; // Status of the credential
    }

    mapping(bytes32 => Credential) public credentials; // Mapping of credential ID to Credential struct

    event CredentialIssued(address indexed issuer, address indexed holder, bytes32 credentialId);
    event CredentialRevoked(bytes32 indexed credentialId);

    modifier onlyIssuer(bytes32 _credentialId) {
        require(credentials[_credentialId].issuer == msg.sender, "Not the issuer of this credential");
        _;
    }

    function issueCredential(address _holder, string memory _credentialHash) public returns (bytes32) {
        bytes32 credentialId = keccak256(abi.encodePacked(_holder, _credentialHash, block.timestamp));

        credentials[credentialId] = Credential({
            credentialHash: _credentialHash,
            issuer: msg.sender,
            holder: _holder,
            isValid: true
        });

        emit CredentialIssued(msg.sender, _holder, credentialId);
        return credentialId;
    }

    function verifyCredential(bytes32 _credentialId) public view returns (bool, string memory, address, address) {
        Credential memory cred = credentials[_credentialId];
        return (cred.isValid, cred.credentialHash, cred.issuer, cred.holder);
    }

    function revokeCredential(bytes32 _credentialId) public onlyIssuer(_credentialId) {
        credentials[_credentialId].isValid = false;
        emit CredentialRevoked(_credentialId);
    }
}
