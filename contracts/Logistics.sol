// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IManufacturer {
    function getProduct(uint _id) external view returns (string memory, uint256, string memory, string memory, uint256, string memory);
}

contract Logistics {
    struct Delivery {
        uint id;
        string productName;
        uint256 quantity;
        string destination;
        uint256 timestamp;
        string status;
        bool isDelivered;
    }

    address public logisticsProvider;
    mapping(uint => Delivery) public deliveries;
    uint public deliveryCount = 0;
    IManufacturer public manufacturerContract;
    mapping(address => bool) public authorizedRetailers;

    modifier onlyLogisticsProvider() {
        require(msg.sender == logisticsProvider, "Only the logistics provider can perform this action");
        _;
    }

    modifier onlyAuthorizedRetailer() {
        require(authorizedRetailers[msg.sender], "Only authorized retailers can confirm the delivery");
        _;
    }

    constructor(address _manufacturerContract) {
        logisticsProvider = msg.sender;
        manufacturerContract = IManufacturer(_manufacturerContract);
    }

    function deliverProduct(uint _productId, string memory _destination) public onlyLogisticsProvider {
        // Fetch product details from Manufacturer
        (string memory productName, uint256 quantity,,,uint256 timestamp, string memory status) = manufacturerContract.getProduct(_productId);

        require(keccak256(bytes(status)) == keccak256(bytes("Manufactured")), "Product not ready for delivery");

        deliveryCount++;
        deliveries[deliveryCount] = Delivery(deliveryCount, productName, quantity, _destination, block.timestamp, "In Transit", false);
    }

    function confirmDelivery(uint _deliveryId) public onlyAuthorizedRetailer {
        require(deliveries[_deliveryId].isDelivered == false, "Delivery already confirmed");

        deliveries[_deliveryId].isDelivered = true;
        deliveries[_deliveryId].status = "Delivered";
    }

    function authorizeRetailer(address _retailer) public onlyLogisticsProvider {
        authorizedRetailers[_retailer] = true;
    }
}
