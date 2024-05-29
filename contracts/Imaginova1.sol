// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
// import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
// import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

// contract ImaginovaPayment is FunctionsClient, ConfirmedOwner {
//     using FunctionsRequest for FunctionsRequest.Request;

//     bytes32 public s_lastRequestId;
//     bytes public s_lastResponse;
//     bytes public s_lastError;

//     error UnexpectedRequestID(bytes32 requestId);

//     event Response(
//         bytes32 indexed requestId,
//         string character,
//         bytes response,
//         bytes err
//     );

    
//     address router = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;


//     string source =
//         "const characterId = args[0];"
//         "const apiResponse = await Functions.makeHttpRequest({"
//         "url: `https://swapi.info/api/people/${characterId}/`"
//         "});"
//         "if (apiResponse.error) {"
//         "throw Error('Request failed');"
//         "}"
//         "const { data } = apiResponse;"
//         "return Functions.encodeString(data.name);";

//     //Callback gas limit
//     uint32 gasLimit = 300000;

//     // donID - Hardcoded for Sepolia
//     // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
//     bytes32 donID =
//         0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

//     // State variable to store the returned character information
//     string public character;

//     /**
//      * @notice Initializes the contract with the Chainlink router address and sets the contract owner
//      */
//     constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

//     /**
//      * @notice Sends an HTTP request for character information
//      * @param subscriptionId The ID for the Chainlink subscription
//      * @param args The arguments to pass to the HTTP request
//      * @return requestId The ID of the request
//      */
//     function sendRequest(
//         uint64 subscriptionId,
//         string[] calldata args
//     ) external onlyOwner returns (bytes32 requestId) {
//         FunctionsRequest.Request memory req;
//         req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
//         if (args.length > 0) req.setArgs(args); // Set the arguments for the request

//         // Send the request and store the request ID
//         s_lastRequestId = _sendRequest(
//             req.encodeCBOR(),
//             subscriptionId,
//             gasLimit,
//             donID
//         );

//         return s_lastRequestId;
//     }

//     /**
//      * @notice Callback function for fulfilling a request
//      * @param requestId The ID of the request to fulfill
//      * @param response The HTTP response data
//      * @param err Any errors from the Functions request
//      */
//     function fulfillRequest(
//         bytes32 requestId,
//         bytes memory response,
//         bytes memory err
//     ) internal override {
//         if (s_lastRequestId != requestId) {
//             revert UnexpectedRequestID(requestId); // Check if request IDs match
//         }
//         // Update the contract's state variables with the response and any errors
//         s_lastResponse = response;
//         character = string(response);
//         s_lastError = err;

//         emit Response(requestId, character, s_lastResponse, s_lastError);
//     }
// }








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





