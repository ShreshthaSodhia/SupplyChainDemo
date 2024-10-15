// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRetailer {
    function getProduct(uint _id) external view returns (string memory, uint256, uint256, string memory);
}

contract Consumer {
    address public consumer;
    IRetailer public retailerContract;

    constructor(address _retailerContract) {
        consumer = msg.sender;
        retailerContract = IRetailer(_retailerContract);
    }

    function browseProduct(uint _productId) public view returns (string memory, uint256, uint256, string memory) {
        // Consumer buys the product, can verify details
        return retailerContract.getProduct(_productId);
    }
}
