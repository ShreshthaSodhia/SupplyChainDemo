// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Supplier {
    struct Material {
        uint id;
        string name;
        uint256 quantity;
        string location;
        uint256 timestamp;
        bool isAdded;
    }

    address public supplier;
    mapping(uint => Material) public materials;
    uint public materialCount = 0;

    mapping(address => bool) public authorizedManufacturers;

    modifier onlySupplier() {
        require(msg.sender == supplier, "Only the supplier can perform this action");
        _;
    }

    modifier onlyAuthorizedManufacturer() {
        require(authorizedManufacturers[msg.sender], "Only authorized manufacturers can perform this action");
        _;
    }

    constructor() {
        supplier = msg.sender;
    }

    function addMaterial(string memory _name, uint256 _quantity, string memory _location) public onlySupplier {
        materialCount++;
        materials[materialCount] = Material(materialCount, _name, _quantity, _location, block.timestamp, true);
    }

    function authorizeManufacturer(address _manufacturer) public onlySupplier {
        authorizedManufacturers[_manufacturer] = true;
    }

    function deductMaterial(uint _id, uint256 _quantity) public onlyAuthorizedManufacturer {
        require(materials[_id].isAdded, "Material does not exist");
        require(materials[_id].quantity >= _quantity, "Insufficient material quantity");
        materials[_id].quantity -= _quantity;
    }

    function getMaterial(uint _id) public view returns (string memory, uint256, string memory, uint256) {
        require(materials[_id].isAdded, "Material does not exist");
        return (materials[_id].name, materials[_id].quantity, materials[_id].location, materials[_id].timestamp);
    }
}
