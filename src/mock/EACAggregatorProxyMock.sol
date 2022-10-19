pragma solidity ^0.6.0;
import "../PriceSource.sol";

/*
    Mock results of chainlink feeds
    We only are concerned about answer as this is all the QiDAO vaults consume (no addition checks or freshness requirements)
*/
contract EACAggregatorProxyMock is PriceSource {
    uint80 public _roundId;
    int256 public _answer;
    uint256 public _startedAt;
    uint256 public _updatedAt;
    uint80 public _answeredInRound;

    function latestRoundData() external view override returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _answer, _startedAt, _updatedAt, _answeredInRound);
    }

    function decimals() external view override returns (uint8) {
        return 8;
    }

    function publishAnswer(int256 answer) public {
        _answer = answer;
    }
}
