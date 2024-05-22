// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import "./Batch.sol";

contract ImaginovaPayment is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    enum Package { Free, Pro, Premium }
    struct PackageInfo {
        uint price;
        uint credits;
    }

    Batch internal batchContract;

    mapping(Package => PackageInfo) public packages;
    mapping(address => uint) public userCredits;

    // Chainlink Functions parameters
    address private router;
    bytes32 private donID;
    uint256 private fee;
    string public aiResponse;
    uint32 private gasLimit = 300000;

    event Purchase(address indexed buyer, Package package, uint credits);
    event RequestFulfilled(bytes32 indexed requestId, string response);

    constructor(
        address _router,
        bytes32 _donID,
        uint256 _fee
    ) FunctionsClient(_router) ConfirmedOwner(msg.sender) {
        router = _router;
        donID = _donID;
        fee = _fee;

        packages[Package.Free] = PackageInfo({ price: 0, credits: 20 });
        packages[Package.Pro] = PackageInfo({ price: 0.01 ether, credits: 120 });
        packages[Package.Premium] = PackageInfo({ price: 0.05 ether, credits: 2000 });
        batchContract = Batch(0x0000000000000000000000000000000000000808);
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
        payable(owner()).transfer(address(this).balance);
    }

    function getCredits(address user) external view returns (uint) {
        return userCredits[user];
    }

    // Chainlink Functions to connect to OpenAI API
    function requestAIResponse(string memory prompt) public onlyOwner {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(
            string(abi.encodePacked(
                "const prompt = args[0];",
                "const apiResponse = await Functions.makeHttpRequest({",
                "url: `https://api.openai.com/v1/engines/davinci/completions`,",
                "method: `POST`,",
                "headers: {",
                "`Authorization`: `Bearer YOUR_OPENAI_API_KEY`,",
                "`Content-Type`: `application/json`",
                "},",
                "data: JSON.stringify({",
                "`prompt`: prompt,",
                "`max_tokens`: 100",
                "})",
                "});",
                "if (apiResponse.error) {",
                "throw Error('Request failed');",
                "}",
                "const { data } = apiResponse;",
                "return Functions.encodeString(data.choices[0].text);"
            ))
        );
        string[] memory args = new string[](1);
        args[0] = prompt;
        req.setArgs(args);

        _sendRequest(
            req.encodeCBOR(),
            uint64(fee),
            gasLimit,
            donID
        );
    }

    function fulfillRequest(bytes32 _requestId, bytes memory _response, bytes memory _err) internal override {
        if (_err.length > 0) {
            aiResponse = string(_err); // In case of error, store the error message
        } else {
            aiResponse = string(_response); // In case of success, store the response
        }
        emit RequestFulfilled(_requestId, aiResponse);
    }
}
