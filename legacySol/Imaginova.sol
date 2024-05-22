// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// import "./Batch.sol";


contract ImaginovaPayment {
    address public owner;

    enum Package { Free, Pro, Premium }
    struct PackageInfo {
        uint price;
        uint credits;
    }

    AggregatorV3Interface internal priceFeed;
    Batch internal batchContract;

    mapping(Package => PackageInfo) public packages;
    mapping(address => uint) public userCredits;

    event Purchase(address indexed buyer, Package package, uint credits);

    constructor() {
        owner = msg.sender;
        packages[Package.Free] = PackageInfo({ price: 0, credits: 20 });
        packages[Package.Pro] = PackageInfo({ price: 0.01 ether, credits: 120 });
        packages[Package.Premium] = PackageInfo({ price: 0.05 ether, credits: 2000 });
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e); 
        batchContract = Batch(0x0000000000000000000000000000000000000808);
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