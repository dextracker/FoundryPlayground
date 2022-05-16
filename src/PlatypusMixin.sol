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
import "./console.sol";

interface IPlatypusRouter {

    function swapTokensForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut, uint256 haircut);
}


contract MixinPlatypus {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibSafeMathV06 for uint256;

    function _tradePlatypus(
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        public
        returns (uint256 boughtAmount)
    {
        IPlatypusRouter router;
        address _router;
        address[] memory _pool;
        IERC20TokenV06[] memory path;
        address[] memory _path;

        {
            (_router, _pool, _path) = abi.decode(bridgeData, (address, address[], address[]));

            // To get around `abi.decode()` not supporting interface array types.
            assembly { path := _path }
        }

        router = IPlatypusRouter(_router);
        //corresponding platypus asset pool for the ERC20's in the path

        require(path.length >= 2, "MixinPlatypus/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(
            path[path.length - 1] == buyToken,
            "MixinPlatypus/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
        );
        // Grant the Platypus router an allowance to sell the first token.
        path[0].approveIfBelow(address(router), sellAmount);

        uint256 beforeBalance = buyToken.balanceOf(address(this));
        router.swapTokensForTokens(
            // Convert to `buyToken` along this path.
            _path,
            //
            _pool,
             // Sell all tokens we hold.
            sellAmount,
             // Minimum buy amount.
            0,
            // Recipient is `this`.
            address(this),

            block.timestamp + 10000
        );
        boughtAmount = buyToken.balanceOf(address(this)).safeSub(beforeBalance);
        return boughtAmount;
    }

    // function _tradePlatypus2(
    //     IERC20TokenV06 buyToken,
    //     uint256 sellAmount,
    //     bytes memory bridgeData
    // )
    //     public
    //     returns (uint256 boughtAmount)
    // {
    //     IPlatypusRouter router = IPlatypusRouter(0x73256EC7575D999C360c1EeC118ECbEFd8DA7D12);
    //     address _router;
    //     address[] memory _pool = new address[](1);
    //     _pool[0] = 0x66357dCaCe80431aee0A7507e2E361B7e2402370;
    //     IERC20TokenV06[] memory path;

    //     address[] memory _path = new address[](2);
    //     _path[0] = address(0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E);
    //     _path[1] = address(0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664);
    //     {
    //         // (_router, _pool, _path) = abi.decode(bridgeData, (address, address[], address[]));

    //         // To get around `abi.decode()` not supporting interface array types.
    //         assembly { path := _path }
    //     }

    //     //router = IPlatypusRouter(_router);
    //     //corresponding platypus asset pool for the ERC20's in the path

    //     require(path.length >= 2, "MixinPlatypus/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
    //     require(
    //         path[path.length - 1] == buyToken,
    //         "MixinPlatypus/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
    //     );

    //     // Grant the Platypus router an allowance to sell the first token.
    //     path[0].approveIfBelow(address(router), sellAmount);
    //     //revert("check");
    //     uint256 beforeBalance = buyToken.balanceOf(address(this));
    //     router.swapTokensForTokens(
    //         // Convert to `buyToken` along this path.
    //         _path,
    //         //
    //         _pool,
    //          // Sell all tokens we hold.
    //         sellAmount,
    //          // Minimum buy amount.
    //         0,
    //         // Recipient is `this`.
    //         address(this),

    //         block.timestamp + 10000
    //     );
    //     boughtAmount = buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    //     return boughtAmount;
    // }
}
