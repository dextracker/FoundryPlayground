// SPDX-License-Identifier: Unlicense
pragma solidity ^0.6;

import "ds-test/test.sol";
import "../Mixin2.sol";
import "../cheats.sol";
import "../console.sol";

contract ContractTest is DSTest {
    function setUp() public {

    }

    function testExample() public {
        MixinGMX mixin = new MixinGMX();
        bytes memory temp = "0x12345566";
        CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
        cheats.prank(0x53f7c5869a859F0AeC3D334ee8B4Cf01E3492f21);
        IERC20TokenV06(0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB).transfer(address(mixin), 100000000000000000000);
        address[] memory p = new address[](2);
        p[0] = address(0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB);
        p[1] = address(0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664);
        address r = address(0x5F719c2F1095F7B9fc68a68e35B51194f4b6abe8);
        address re = address(0x67b789D48c926006F5132BFCe4e976F0A7A63d5D);
        address v = address(0x9ab2De34A33fB459b538c43f251eB825645e8595);
        bytes memory bridgeData = abi.encode(r, re, v, p);
        // console.log(r);
        // console.log(re);
        // console.log(v);
        // console.log(p[0]);
        // console.log(p[1]);
        // IGmxRouter router ;
        // address _router;
        // address reader;
        // address vault;
        // IERC20TokenV06[] memory path;
        // address[] memory _path;
        // (_router, reader, vault, _path) = abi.decode(bridgeData, (address, address, address, address[]));
        // //bytes(0x0000000000000000000000005f719c2f1095f7b9fc68a68e35b51194f4b6abe800000000000000000000000067b789d48c926006f5132bfce4e976f0a7a63d5d0000000000000000000000009ab2de34a33fb459b538c43f251eb825645e859500000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000002000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c664000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c7);
        // console.log(_router);
        // console.log(reader);
        // console.log(vault);
        // console.log(_path[0]);
        // console.log(_path[1]);

        // {
        //     (_router, reader, vault, _path) = abi.decode(bridgeData, (address, address, address, address[]));
        // }
        mixin._tradeGMX(
            IERC20TokenV06(0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664),
            100000000000000,
            bridgeData
        );
    }
}