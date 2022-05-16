// SPDX-License-Identifier: Apache-2.0

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;
import "./0xLib.sol";

interface IPoolCollection{}

interface IBancorV3 {

     struct TradeAmountAndFee {
        uint256 amount; // the source/target amount (depending on the context) resulting from the trade
        uint256 tradingFeeAmount; // the trading fee amount
        uint256 networkFeeAmount; // the network fee amount (always in units of BNT)
    }

    /**
     * @dev performs a trade by providing the source amount and returns the target amount and the associated fee
     *
     * requirements:
     *
     * - the caller must be the network contract
     */
    function tradeBySourceAmount(
        address sourceToken,
        address targetToken,
        uint256 sourceAmount,
        uint256 minReturnAmount,
        uint256 deadline,
        address beneficiary
    ) external returns (TradeAmountAndFee memory);

    /**
     * @dev performs a trade by providing the target amount and returns the required source amount and the associated fee
     *
     * requirements:
     *
     * - the caller must be the network contract
     */
    function tradeByTargetAmount(
        bytes32 contextId,
        address sourceToken,
        address targetToken,
        uint256 targetAmount,
        uint256 maxSourceAmount
    ) external returns (TradeAmountAndFee memory);



    function poolCollections() external view returns (IPoolCollection[] memory);


}

contract MixinBancorV3 {

    using LibERC20TokenV06 for IERC20TokenV06;
    function test (address banc) public returns( IPoolCollection[] memory){
        IPoolCollection[] memory temp = IBancorV3(banc).poolCollections();
        return temp;
    }

    function _tradeBancorV3(
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        public
        returns (uint256 boughtAmount)
    {
        IBancorV3 router;
        IERC20TokenV06[] memory path;
        address[] memory _path;
        {
            (router, _path) = abi.decode(bridgeData, (IBancorV3, address[]));
            // To get around `abi.decode()` not supporting interface array types.
            assembly { path := _path }
        }

        require(path.length >= 2, "MixinUniswapV2/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(
            path[path.length - 1] == buyToken,
            "MixinUniswapV2/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
        );
        // Grant the Uniswap router an allowance to sell the first token.
        path[0].approveIfBelow(address(router), sellAmount);

        IBancorV3.TradeAmountAndFee memory amountOut = router.tradeBySourceAmount(
            _path[0],
            _path[1],
             // Sell all tokens we hold.
            sellAmount,
             // Minimum buy amount.
            0,
            //deadline
            block.timestamp + 10000,

            address(this)
        );
        return amountOut.amount;
    }
}
