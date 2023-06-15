// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

// Inherit ChainlinkClient to gain access to Chainlink's functions
contract TwitterSentiment is ChainlinkClient {
    // Variable to hold the sentiment score
    uint256 public sentimentScore;

    // Variables to hold the oracle, job ID, and fee for the Chainlink request
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    // Constructor to initialize the oracle, job ID, and fee
    constructor(address _oracle, string memory _jobId, uint256 _fee) public {
        setPublicChainlinkToken();
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
    }

    // Function to make a Chainlink request
    function requestSentimentData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "http://your-server.com/twitter/sentiment");
        
        // Set the path to find the desired data in the API response
        request.add("path", "sentiment");
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    // Function to handle the Chainlink response
    function fulfill(bytes32 _requestId, uint256 _sentiment) public recordChainlinkFulfillment(_requestId) {
        sentimentScore = _sentiment;
    }

    // Helper function to convert a string to a bytes32
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
