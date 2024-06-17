// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Trigonometry.sol";

contract TrigonometryTest is Test {
    function testSin() public pure {
        // Test sin(0) should be 0
        int result = Trigonometry.sin(0);
        assertEq(result, 0, "sin(0) should be 0");

        // Test sin(90 degrees) should be approx 32767 (max value)
        // 90 degrees in this scale is 16384/4 = 4096
        result = Trigonometry.sin(4096);
        assertApproxEqAbs(result, 32767, 1, "sin(90 degrees) should be approximately 32767");

        // Test sin(180 degrees) should be 0
        // 180 degrees in this scale is 16384/2 = 8192
        result = Trigonometry.sin(8192);
        assertEq(result, 0, "sin(180 degrees) should be 0");

        // Test sin(270 degrees) should be approximately -32767
        // 270 degrees in this scale is 3*16384/4 = 12288
        result = Trigonometry.sin(12288);
        assertApproxEqAbs(result, -32767, 1, "sin(270 degrees) should be approximately -32767");

        // Test sin(360 degrees) should be 0
        // 360 degrees in this scale is 16384
        result = Trigonometry.sin(16384);
        assertEq(result, 0, "sin(360 degrees) should be 0");
    }

    function testCos() public pure {
        // Test cos(0) should be approximately 32767 (max value)
        int result = Trigonometry.cos(0);
        assertApproxEqAbs(result, 32767, 1, "cos(0) should be approximately 32767");

        // Test cos(90 degrees) should be 0
        // 90 degrees in this scale is 16384/4 = 4096
        result = Trigonometry.cos(4096);
        assertEq(result, 0, "cos(90 degrees) should be 0");

        // Test cos(180 degrees) should be approximately -32767
        // 180 degrees in this scale is 16384/2 = 8192
        result = Trigonometry.cos(8192);
        assertApproxEqAbs(result, -32767, 1, "cos(180 degrees) should be approximately -32767");

        // Test cos(270 degrees) should be 0
        // 270 degrees in this scale is 3*16384/4 = 12288
        result = Trigonometry.cos(12288);
        assertEq(result, 0, "cos(270 degrees) should be 0");

        // Test cos(360 degrees) should be approximately 32767
        // 360 degrees in this scale is 16384
        result = Trigonometry.cos(16384);
        assertApproxEqAbs(result, 32767, 1, "cos(360 degrees) should be approximately 32767");
    }
}