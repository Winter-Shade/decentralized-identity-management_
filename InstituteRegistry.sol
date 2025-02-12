// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InstituteRegistry {
    struct Institute {
        string name;
        string metadata;
        address admin;
        bool isRegistered;
    }

    mapping(address => Institute) public institutes;
    address[] public instituteList;

    event InstituteRegistered(address indexed instituteAddress, string name);
    event InstituteUpdated(address indexed instituteAddress, string name);

    function registerInstitute(string memory _name, string memory _metadata) public {
        require(!institutes[msg.sender].isRegistered, "Institute already registered");
        
        institutes[msg.sender] = Institute({
            name: _name,
            metadata: _metadata,
            admin: msg.sender,
            isRegistered: true
        });

        instituteList.push(msg.sender);
        emit InstituteRegistered(msg.sender, _name);
    }

    function updateInstitute(string memory _name, string memory _metadata) public {
        require(institutes[msg.sender].isRegistered, "Institute not registered");
        
        institutes[msg.sender].name = _name;
        institutes[msg.sender].metadata = _metadata;
        
        emit InstituteUpdated(msg.sender, _name);
    }

    function getInstitute(address _instituteAddress) public view returns (string memory, string memory, address, bool) {
        Institute memory inst = institutes[_instituteAddress];
        return (inst.name, inst.metadata, inst.admin, inst.isRegistered);
    }

    function getAllInstitutes() public view returns (address[] memory) {
        return instituteList;
    }
}
