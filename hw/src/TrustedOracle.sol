// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./interface.sol";

interface ITrustedOracle {
    function getPrice() external view returns (uint256);
}

contract TrustedOracle {
    address public owner;

    address[] oracles;

    event AddNewOracle(address oracle);

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function addOracle(address oracle) external payable onlyOwner {
        oracles.push(oracle);
        emit AddNewOracle(oracle);
    }

    function getAveragePrice() external payable returns (uint256) {
        uint256 price = 0;
        uint256 count = getOracleCount();
        for (uint256 i = 0; i < count; i++) {
            price += ITrustedOracle(oracles[i]).getPrice();
        }

        return price / count;
    }

    function getOracleCount() public view returns (uint256) {
        return oracles.length;
    }
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract ChainlinkOracle {
    AggregatorV3Interface internal priceFeed;

    constructor(address addr) {
        priceFeed = AggregatorV3Interface(addr);
    }

    function getPrice() public view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();

        return uint256(price);
    }

    function getDecimals() public pure returns (uint8) {
        return 8;
    }
}
