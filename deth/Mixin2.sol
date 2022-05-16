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

interface IGmxRouter {

    // /// @dev Swaps an exact amount of input tokens for as many output tokens as possible, along the route determined by the path.
    // ///      The first element of path is the input token, the last is the output token, and any intermediate elements represent
    // ///      intermediate pairs to trade through (if, for example, a direct pair does not exist).
    // /// @param _path An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
    // /// @param _amountIn The amount of input tokens to send.
    // /// @param _minOut The minimum amount of output tokens that must be received for the transaction not to revert.
    // /// @param _reciever Recipient of the output tokens.
    function swap(
       address[] calldata _path, uint256 _amountIn, uint256 _minOut, address _receiver
    ) external;
}

contract MixinGMX {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibSafeMathV06 for uint256;

    address immutable WAVAX = address(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);
    address immutable AVAX = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function _tradeGMX(
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        public
        returns (uint256 boughtAmount)
    {
        //0x5F719c2F1095F7B9fc68a68e35B51194f4b6abe8,0x67b789D48c926006F5132BFCe4e976F0A7A63d5D,0x9ab2De34A33fB459b538c43f251eB825645e8595,[0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7,0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664]
        IGmxRouter router ;
        address _router;
        address reader;
        address vault;
        IERC20TokenV06[] memory path;
        address[] memory _path;


        {
            (_router, reader, vault, _path) = abi.decode(bridgeData, (address, address, address, address[]));

            // To get around `abi.decode()` not supporting interface array types.
            assembly { path := _path }
        }

        router = IGmxRouter(_router);
        require(path.length >= 2, "MixinGMX/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(
            path[path.length - 1] == buyToken,
            "MixinGMX/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
        );
        // Grant the GMX router an allowance to sell the first token.
        path[0].approveIfBelow(address(router), sellAmount);

        uint256 beforeBalance = buyToken.balanceOf(address(this));
        router.swap(
            // Convert to `buyToken` along this path.
            _path,
             // Sell all tokens we hold.
            sellAmount,
             // Minimum buy amount.
            0,
            // Recipient is `this`.
            address(this)
        );
        boughtAmount = buyToken.balanceOf(address(this)).safeSub(beforeBalance);
        return boughtAmount;
    }
}
