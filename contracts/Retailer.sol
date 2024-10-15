// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILogistics {
    function confirmDelivery(uint _deliveryId) external;
}

contract Retailer {
    struct Product {
        uint id;
        string name;
        uint256 quantity;
        uint256 price;
        string status;
        bool isSold;
    }

    address public retailer;
    mapping(uint => Product) public products;
    uint public productCount = 0;
    ILogistics public logisticsContract;

    modifier onlyRetailer() {
        require(msg.sender == retailer, "Only the retailer can perform this action");
        _;
    }

    constructor(address _logisticsContract) {
        retailer = msg.sender;
        logisticsContract = ILogistics(_logisticsContract);
    }

    function receiveProduct(uint _deliveryId, string memory _name, uint256 _quantity, uint256 _price) public onlyRetailer {
        logisticsContract.confirmDelivery(_deliveryId);
        
        productCount++;
        products[productCount] = Product(productCount, _name, _quantity, _price, "Received", false);
    }

    function sellProduct(uint _id) public onlyRetailer {
        require(products[_id].isSold == false, "Product already sold");

        products[_id].isSold = true;
        products[_id].status = "Sold";
    }

    function getProduct(uint _id) public view returns (string memory, uint256, uint256, string memory) {
        return (products[_id].name, products[_id].quantity, products[_id].price, products[_id].status);
    }
}
