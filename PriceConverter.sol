// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Import the data feed ABI from the Chainlink package (can also be imported directly from GitHub).
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
     // Get the price of ETH in terms of USD using Chainlink's data feed
    function getPrice() internal  view returns (uint256) {
        // Instantiate the price feed contract at the Chainlink ETH/USD price feed address
        // The address below is for Goerli testnet; update this for the appropriate network
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        // Get the latest price data
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        
        // The `answer` variable represents the price of 1 ETH in terms of USD, 
        // with 8 decimal places (e.g., 1,500.00000000 for $1,500).
        
        // Since `msg.value` (ETH sent) is expressed in wei (18 decimals) and `answer` is in 8 decimals, 
        // we need to match their scales for consistency. This is done by multiplying `answer` by 1e10 
        // to make it 18 decimals.
        
        // Note: `answer` is an `int256`, but we return it as a `uint256` after converting its type.
        return uint256(answer * 1e10); // Convert to 18 decimals
    }

    // Get the conversion rate from USD to ETH
    function getConversionRate(uint256 ethAmount) internal  view returns (uint256) {
        // get the ethPrice that's returned from the getprice func
        uint256 ethPrice = getPrice();
        // convert the amount to usd using the rate
        // we have to divide by 1e18 here because when we multiply the price and amount we're getting 36 decimal place
        // dividing will return our answer back to 18 decimal place as expected
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}