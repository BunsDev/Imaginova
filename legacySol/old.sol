// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ImaginovaPayment {
    address public owner;

    enum Package { Free, Pro, Premium }
    struct PackageInfo {
        uint price;
        uint credits;
    }

    mapping(Package => PackageInfo) public packages;
    mapping(address => uint) public userCredits;

    event Purchase(address indexed buyer, Package package, uint credits);

    constructor() {
        owner = msg.sender;
        packages[Package.Free] = PackageInfo({ price: 0, credits: 20 });
        packages[Package.Pro] = PackageInfo({ price: 0.01 ether, credits: 120 });
        packages[Package.Premium] = PackageInfo({ price: 0.05 ether, credits: 2000 });
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function purchase(Package packageType) external payable {
        PackageInfo memory package = packages[packageType];
        require(msg.value >= package.price, "Insufficient payment");

        userCredits[msg.sender] += package.credits;
        emit Purchase(msg.sender, packageType, package.credits);

        // Refund any excess payment
        if (msg.value > package.price) {
            payable(msg.sender).transfer(msg.value - package.price);
        }
    }

    function updatePackage(Package packageType, uint price, uint credits) external onlyOwner {
        packages[packageType] = PackageInfo({ price: price, credits: credits });
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getCredits(address user) external view returns (uint) {
        return userCredits[user];
    }
}