// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

// payble это когда мы можем платить внутри функции (когда мы используем поле value в наших функциях)

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";


/*
interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}
*/

contract FundMe {

   using SafeMathChainlink for uint256;

   mapping(address => uint256) public addressToAmountFunded;
   address[] public funders;
   address public owner;

   constructor() public {
       owner = msg.sender;
   }

   function fund() public payable {
       uint256 minimumUSD = 50 * 10 ** 18;
       require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
       addressToAmountFunded[msg.sender] += msg.value;
       funders.push(msg.sender);
   } 

   function getVersion() public view returns(uint256) {
       AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
       return priceFeed.version();
   }

    function getPrice() public view returns(uint256) {
        // получаем доступ к запущенному контракту
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 100000000000);
        // 2,894.94000000
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd; 
        // 0.000002894940000000
    }

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
        // проверь require и потом сделай остаток кода, можно педаль поставить перед require
    }
    
    function withdraw() payable onlyOwner public {

        // перечисляем весь баланс на контракте msg.sender


        msg.sender.transfer(address(this).balance);
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // очищаем массив funders
        funders = new address[](0);
    }

}
