// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISupplier {
    function deductMaterial(uint _id, uint256 _quantity) external;
}

contract Manufacturer {
    struct Product {
        uint id;
        string name;
        uint256 quantity;
        string batchNumber;
        string supplierName;
        uint256 timestamp;
        string status;
        bool isManufactured;
    }

    address public manufacturer;
    mapping(uint => Product) public products;
    uint public productCount = 0;
    ISupplier public supplierContract;

    modifier onlyManufacturer() {
        require(msg.sender == manufacturer, "Only the manufacturer contract can perform this action");
        _;
    }

    constructor(address _supplierContract) {
        manufacturer = msg.sender;
        supplierContract = ISupplier(_supplierContract);
    }

    function processProduct(uint _materialId, string memory _name, uint256 _quantity, string memory _batchNumber, string memory _supplierName) public onlyManufacturer {
        supplierContract.deductMaterial(_materialId, _quantity);

        productCount++;
        products[productCount] = Product(productCount, _name, _quantity, _batchNumber, _supplierName, block.timestamp, "Manufactured", true);
    }

    function getProduct(uint _id) public view returns (string memory, uint256, string memory, string memory, uint256, string memory) {
        require(products[_id].isManufactured, "Product does not exist");
        return (products[_id].name, products[_id].quantity, products[_id].batchNumber, products[_id].supplierName, products[_id].timestamp, products[_id].status);
    }
}
