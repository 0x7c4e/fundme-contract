// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

// before optimization, 783,444 gas
// after - 739,900
contract FundMe {
    using PriceConverter for uint256;

    // Minimum funding amount in USD, expressed in whole dollars
    // since the getconversionrate func returns amount in 18 decimal place, our mimunumusd value also has to be in 18 decimal place
    // here's 5 dollar in 18 dcimal place, can also be written as 5 * 1e18;
    uint256 public constant MINIMUM_USD = 5e18;

    // create an array of addresses that fund us, to keep track
    address[] public funders;

    address public immutable i_owner;

    // create a constructor to assign an owner to this contract (so that only owners can wwithdraw funds)
    constructor() {
        i_owner = msg.sender;
    }

    // create a map to see how much each funder has sent
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    // Allow users to send ETH to this contract
    function fund() public payable {
        // Require that the amount being sent is at least the equivalent of the MINIMUM_USD in ETH
        // Note: The value of `msg.value` is in wei (1 ETH = 1e18 wei)
        // we use the getconversionrate func here to convert msg.value to usd
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH."); 
        // update the funders array whenever someone sends us funds
        funders.push(msg.sender);

        // update the map as well 
        // get the current value (balance) if they've funded before and ass the msg.value (current amount being funded0 to it
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    // Function to withdraw all funds

    // we loop through an array of addresses (for funders that have funded the contract), for each address we reset their contribution amount stored in the map to 0.

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex ++) 
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
        // withdraw funds from the contract
        // there are 3 ways to do this, we can use transfer, send, or call. 
        // using transfer or send comes with downsides, we'll use call which is a low level function
        // call returns 2 values but since we only need one (the bool to verify), we can put a comma and leave the returndata out
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
     }

     fallback() external payable {
        fund();
      }
}



// DEPLOYED CONTRACT ADDRESS
// 0xBd354A770683FE4edf10392b3A71aD5a5D7B40dE