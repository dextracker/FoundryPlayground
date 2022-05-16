// SPDX-License-Identifier: Unlicense
pragma solidity ^0.6;

import "ds-test/test.sol";
import "../PlatypusSampler.sol";
import "../PlatypusMixin.sol";
import "../cheats.sol";
import "../console.sol";

interface IPlatypusPool {
    function assetOf(address token) external view returns (address);
}

contract PlatypusTest is DSTest {
    address router = 0x73256EC7575D999C360c1EeC118ECbEFd8DA7D12;
    address YUSD = address(0x111111111111ed1D73f860F57b2798b683f2d325);
    address USDT_e = address(0xc7198437980c041c805A1EDcbA50c1Ce5db95118);
    address USDC = address(0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E);
    address YUSD_POOL = address(0xC828D995C686AaBA78A4aC89dfc8eC0Ff4C5be83);
    address STABLE_POOL = address(0x66357dCaCe80431aee0A7507e2E361B7e2402370);
    address wallet = 0xFFffFfffFff5d3627294FeC5081CE5C5D7fA6451;
    function setUp() public {

    }
    function testSwapPlatypus() public {
        MixinPlatypus mixin = new MixinPlatypus();
        IPlatypusPool pool = IPlatypusPool(0x66357dCaCe80431aee0A7507e2E361B7e2402370);



        CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
        cheats.startPrank(wallet);
        IERC20TokenV06 token0 = IERC20TokenV06(YUSD);
        //log_uint(token0.balanceOf(address(usdcWallet)));
        token0.transfer(
            address(mixin),
            5000000000000000000000
        );
        cheats.stopPrank();



        address[] memory path = new address[](3);
        address[] memory pools = new address[](2);
        uint256[] memory swapAmount = new uint256[](1);
        swapAmount[0] = 2000000000000000000;
        pools[0] = YUSD_POOL;
        pools[1] = STABLE_POOL;
        path[0] = YUSD;
        path[1] = USDC;
        path[2] = USDT_e;


        bytes memory bridgeData = abi.encode(router, pools, path);
        address _router;
        address[] memory _pool;
        address[] memory _path;

        (_router, _pool, _path) = abi.decode(bridgeData, (address, address[], address[]));
        log_named_address("_router", _router);
        log_named_address("_pool", _pool[0]);
        log_named_address("_path[0]", _path[0]);
        log_named_address("_path[1]", _path[1]);
        uint256 boughtAmount = mixin._tradePlatypus(
            IERC20TokenV06(0xc7198437980c041c805A1EDcbA50c1Ce5db95118),
            swapAmount[0],
            bridgeData
        );
        log_named_uint("BOUGHT AMOUNT", boughtAmount);
        //log_uint(boughtAmount);
    }

    function testSamplePlatypus() public {
        PlatypusSampler sampler = new PlatypusSampler();
        address[] memory path = new address[](3);
        address[] memory pools = new address[](2);
        uint256[] memory swapAmount = new uint256[](1);
        swapAmount[0] = 6537000000;
        // pools[0] = YUSD_POOL;
        // pools[1] = STABLE_POOL;
        // path[0] = YUSD;
        // path[1] = USDC;
        // path[2] = USDT_e;

        pools[0] = 0x66357dCaCe80431aee0A7507e2E361B7e2402370;
        pools[1] = 0xB8E567fc23c39C94a1f6359509D7b43D1Fbed824;
        path[0] = 0xc7198437980c041c805A1EDcbA50c1Ce5db95118;
        path[1] = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;
        path[2] = 0xD24C2Ad096400B6FBcd2ad8B24E7acBc21A1da64;

        uint256[] memory sellAmount = sampler.sampleSellsFromPlatypus(
            router,
            path,
            pools,
           swapAmount
        );
        log_named_uint("SELL QUOTE ",sellAmount[0]);
        swapAmount[0] = 6537000000;

        uint256[] memory buyAmount = sampler.sampleBuysFromPlatypus(
            router,
            path,
            pools,
            sellAmount
        );
        log_named_uint("BUY QUOTE ",buyAmount[0]);
    }

}