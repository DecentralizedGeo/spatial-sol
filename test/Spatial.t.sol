// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Spatial.sol";

contract SpatialTest is Test {

    function testSinDegrees() pure public {
        int256 result = Spatial.sinDegrees(0);
        assertEq(result, 0, "sin(0 degrees) should be 0");

        result = Spatial.sinDegrees(90);
        assertApproxEqAbs(result, 32767, 1, "sin(90 degrees) should be approximately 32767");

        result = Spatial.sinDegrees(180);
        assertEq(result, 0, "sin(180 degrees) should be 0");

        result = Spatial.sinDegrees(270);
        assertApproxEqAbs(result, -32767, 1, "sin(270 degrees) should be approximately -32767");

        result = Spatial.sinDegrees(360);
        assertEq(result, 0, "sin(360 degrees) should be 0");
    }

    function testCosDegrees() pure public {
        int256 result = Spatial.cosDegrees(0);
        assertApproxEqAbs(result, 32767, 1, "cos(0 degrees) should be approximately 32767");

        result = Spatial.cosDegrees(90);
        assertEq(result, 0, "cos(90 degrees) should be 0");

        result = Spatial.cosDegrees(180);
        assertApproxEqAbs(result, -32767, 1, "cos(180 degrees) should be approximately -32767");

        result = Spatial.cosDegrees(270);
        assertEq(result, 0, "cos(270 degrees) should be 0");

        result = Spatial.cosDegrees(360);
        assertApproxEqAbs(result, 32767, 1, "cos(360 degrees) should be approximately 32767");
    }

    function testDistance() pure public {
        int[2] memory ptA = [int(0), int(0)];
        int[2] memory ptB = [int(111320000), int(0)];
        uint distance = Spatial.distance(ptA, ptB);
        assertApproxEqAbs(distance, 111320000, 1, "Distance between points should be approximately 111320000 nanometers");

        ptA = [int(0), int(0)];
        ptB = [int(0), int(111320000)];
        distance = Spatial.distance(ptA, ptB);
        assertApproxEqAbs(distance, 111320000, 1, "Distance between points should be approximately 111320000 nanometers");

        ptA = [int(0), int(0)];
        ptB = [int(111320000), int(111320000)];
        distance = Spatial.distance(ptA, ptB);
        assertApproxEqAbs(distance, 157430000, 1, "Distance between points should be approximately 157430000 nanometers");
    }

    function testIsPolygon() pure public {
        int256[2][] memory coordinates;
        coordinates[0] = [int256(0), int256(0)];
        coordinates[1] = [int256(1), int256(0)];
        coordinates[2] = [int256(1), int256(1)];
        coordinates[3] = [int256(0), int256(0)];
        bool result = Spatial.isPolygon(coordinates);
        assertTrue(result, "Coordinates should form a polygon");

        coordinates[3] = [int256(0), int256(1)];
        result = Spatial.isPolygon(coordinates);
        assertFalse(result, "Coordinates should not form a polygon");
    }

    function testIsLine() pure public {
        int256[2][] memory coordinates;
        coordinates[0] = [int256(0), int256(0)];
        coordinates[1] = [int256(1), int256(1)];
        bool result = Spatial.isLine(coordinates);
        assertTrue(result, "Coordinates should form a line");

        coordinates[1] = [int256(0), int256(0)];
        result = Spatial.isLine(coordinates);
        assertFalse(result, "Coordinates should not form a line");
    }

    function testArea() pure public {
        int256[2][] memory coordinates;
        coordinates[0] = [int256(0), int256(0)];
        coordinates[1] = [int256(1), int256(0)];
        coordinates[2] = [int256(1), int256(1)];
        coordinates[3] = [int256(0), int256(0)];
        uint256 area = Spatial.area(coordinates);
        assertEq(area, 1, "Area should be 1");
    }

    function testCentroid() pure public {
        int256[2][] memory coordinates;
        coordinates[0] = [int256(0), int256(0)];
        coordinates[1] = [int256(2), int256(0)];
        coordinates[2] = [int256(1), int256(1)];
        int256[2] memory centroid = Spatial.centroid(coordinates);
        assertEq(centroid[0], 1, "Centroid longitude should be 1");
        assertEq(centroid[1], 0, "Centroid latitude should be 0");
    }

    function testBoundingBox() pure public {
        int256[2][] memory coordinates;
        coordinates[0] = [int256(0), int256(0)];
        coordinates[1] = [int256(2), int256(1)];
        coordinates[2] = [int256(1), int256(3)];
        int256[2][2] memory bbox = [[int256(0), int256(0)], [int256(2), int256(3)]];
        bbox = Spatial.boundingBox(coordinates);
        assertEq(bbox[0][0], 0, "Min longitude should be 0");
        assertEq(bbox[0][1], 0, "Min latitude should be 0");
        assertEq(bbox[1][0], 2, "Max longitude should be 2");
        assertEq(bbox[1][1], 3, "Max latitude should be 3");
    }

    function testLength() public pure {
        int256[2][] memory linestring;
        linestring[0] = [int256(0), int256(0)];
        linestring[1] = [int256(111320000), int256(0)];
        linestring[2] = [int256(111320000), int256(111320000)];
        
        uint256 length = Spatial.length(linestring);
        
        // The length should be the sum of the distances between each pair of points.
        // Distance between (0, 0) and (111320000, 0) is 111320000 nanometers.
        // Distance between (111320000, 0) and (111320000, 111320000) is 111320000 nanometers.
        uint256 expectedLength = 111320000 + 111320000;
        
        assertEq(length, expectedLength, "The length of the linestring should be 222640000 nanometers");
    }


    function testPerimeter() pure public {
        // Define a square polygon with side length 111320000 nanometers
        int256[2][] memory polygon;
        polygon[0] = [int256(0), int256(0)];
        polygon[1] = [int256(111320000), int256(0)];
        polygon[2] = [int256(111320000), int256(111320000)];
        polygon[3] = [int256(0), int256(111320000)];
        polygon[4] = [int256(0), int256(0)];

        // Call the perimeter function
        uint256 perimeter = Spatial.perimeter(polygon);

        // The expected perimeter is the sum of all sides of the square
        uint256 expectedPerimeter = 4 * 111320000;

        // Assert that the calculated perimeter matches the expected perimeter
        assertEq(perimeter, expectedPerimeter, "The perimeter of the polygon should be 445280000 nanometers");
    }

    function testPerimeterNonPolygon() public {
        // Define a non-polygon shape (a line) which should fail the require statement
        int256 [2][] memory linestring;
        linestring[0] = [int256(0), int256(0)];
        linestring[1] = [int256(111320000), int256(0)];
        linestring[2] = [int256(111320000), int256(111320000)];

        // Expect a revert since the coordinates do not form a polygon
        vm.expectRevert();
        Spatial.perimeter(linestring);
    }

    function testPointInBbox() pure public {
        int256[2] memory point = [int256(1), int256(1)];
        int256[2][2] memory bbox = [[int256(0), int256(0)], [int256(2), int256(2)]];
        bool result = Spatial.pointInBbox(point, bbox);
        assertTrue(result, "Point should be inside bounding box");

        point = [int256(3), int256(3)];
        result = Spatial.pointInBbox(point, bbox);
        assertFalse(result, "Point should be outside bounding box");
    }

    function testPointInPolygon() pure public {
        int256[] memory polygon;
        int256[2] memory point = [int256(1), int256(1)];
        polygon[0] = int256(0);
        polygon[1] = int256(0);
        polygon[2] = int256(2);
        polygon[3] = int256(0);
        polygon[4] = int256(2);
        polygon[5] = int256(2);
        polygon[6] = int256(0);
        polygon[7] = int256(2);
        bool result = Spatial.pointInPolygon(point, polygon);
        assertTrue(result, "Point should be inside polygon");

        point = [int256(3), int256(3)];
        result = Spatial.pointInPolygon(point, polygon);
        assertFalse(result, "Point should be outside polygon");
    }
}