


    // SPDX-License-Identifier: Unlicense
pragma solidity ^0.6;

import "ds-test/test.sol";
import "../BancorV3Sampler.sol";
import "../BancorV3Mixin.sol";
import "../cheats.sol";
import "../console.sol";

contract BancorV3Test is DSTest {

    function setUp() public {

    }

    function testTradeBancorV3() public {
        address bancorNetwork = 0xeEF417e1D5CC832e619ae18D2F140De2999dD4fB;
        MixinBancorV3 mixin = new MixinBancorV3();
        //IPoolCollection[] memory t = mixin.test(bancorNetwork);
        IERC20TokenV06 link = IERC20TokenV06(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        IERC20TokenV06 eth = IERC20TokenV06(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        address linkWallet = 0xbe6977E08D4479C0A6777539Ae0e8fa27BE4e9d6;
        CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
        cheats.startPrank(linkWallet);
        link.transfer(address(mixin), 1000000000);
        cheats.stopPrank();
        address[] memory path = new address[](2);
        path[0] = address(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        path[1] = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        bytes memory bridgeData = abi.encode(bancorNetwork, path);
        mixin._tradeBancorV3(
            eth,
            1000000,
            bridgeData
        );
        //log_address(t[0]);
    }

    function testSampleBancorV3() public {
        address bancor = 0x8E303D296851B320e6a697bAcB979d13c9D6E760;
        BancorV3Sampler sampler = new BancorV3Sampler();
        address[] memory p = new address[](2);
        uint256[] memory swapAmount = new uint256[](1);
        swapAmount[0] = 10000000000;
        p[0] = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        p[1] = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        uint256[] memory sellAmount = sampler.sampleSellsFromBancorV3(
            bancor,
            p,
           swapAmount
        );
        log_uint(sellAmount[0]);

        uint256[] memory buyAmount = sampler.sampleBuysFromBancorV3(
            bancor,
            p,
            swapAmount
        );

        log_uint(buyAmount[0]);
    }

}