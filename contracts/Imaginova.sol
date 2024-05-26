// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract ImaginovaPayment is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    error UnexpectedRequestID(bytes32 requestId);

    event Response(
        bytes32 indexed requestId,
        string result,
        bytes response,
        bytes err
    );

    address router = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;
    AggregatorV3Interface internal priceFeed;

    string source = 
        "const openaiApiKey = args[0];"
        "const prompt = args[1];"
        "const axios = require('axios');"
        "const response = await axios.post('https://api.openai.com/v1/chat/completions', {"
        "    model: 'gpt-3.5-turbo',"
        "    messages: ["
        "        { role: 'system', content: 'You are a poetic assistant, skilled in explaining complex programming concepts with creative flair.' },"
        "        { role: 'user', content: prompt }"
        "    ]"
        "}, { headers: { 'Authorization': `Bearer ${openaiApiKey}`, 'Content-Type': 'application/json' }});"
        "if (response.data.error) {"
        "    throw Error('Request failed');"
        "}"
        "return Functions.encodeString(response.data.choices[0].message.content);";

    // Callback gas limit
    uint32 gasLimit = 300000;

    // donID - Hardcoded for Sepolia
    bytes32 donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    // State variable to store the returned result
    string public result;

    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // ETH/USD price feed address on Ethereum mainnet
    }

    /**
     * @notice Sends an HTTP request to the OpenAI API
     * @param subscriptionId The ID for the Chainlink subscription
     * @param args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        result = string(response);
        s_lastError = err;

        // Emit an event to log the response
        emit Response(requestId, result, s_lastResponse, s_lastError);
    }

    /**
     * @notice Gets the latest ETH/USD price from the Chainlink price feed
     * @return price The latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}
