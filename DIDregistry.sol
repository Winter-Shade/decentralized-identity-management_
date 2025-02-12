// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserDIDRegistry {
    struct User {
        string did; // Decentralized Identifier (DID)
        address wallet; // User's blockchain wallet address
        bool isRegistered; // Registration status
    }

    mapping(address => User) public users;

    event UserRegistered(address indexed user, string did);

    modifier onlyUnregistered() {
        require(!users[msg.sender].isRegistered, "User already registered");
        _;
    }

    function registerUser(string memory _did) public onlyUnregistered {
        // DID should be unique and assigned only after Aadhaar verification from backend
        users[msg.sender] = User({
            did: _did,
            wallet: msg.sender,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _did);
    }

    function getUser(address _user) public view returns (string memory, address, bool) {
        User memory user = users[_user];
        return (user.did, user.wallet, user.isRegistered);
    }
}
