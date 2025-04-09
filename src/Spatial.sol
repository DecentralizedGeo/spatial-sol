// SPDX-License-Identifier: APACHE OR MIT


pragma solidity ^0.8.0;

/*
    THIS IS A RESEARCH CODEBASE: WE WILL BE DEVELOPING Spatial.sol v0 SOON — 
    We just want to keep this up for reference. The production implementation
    will likely use very different data structures and algorithms due to 
    the constraints of the EVM.

    This library is intended to give Ethereum developers access to spatial functions to calculate
    geometric values and topologicial relationships on the EVM. It is essentially a translation of
    Turf.js, a geospatial analysis library in Javascript. http://turfjs.org/
    Code first developed by John X (@johnx25bd, Founder at Astral) at ETHParis 2019.
*/

import "./Trigonometry.sol";

library Spatial {
        uint256 public constant earthRadius = 6371008800000000; // in nanometers
        uint256 public constant piScaled = 3141592654; // approx ... will affect precision

        /*
        Trigonometric functions
        */
        function sinDegrees (uint256 _degrees) public pure returns (int256) {
            uint256 degrees = _degrees % 360;
            uint16 angle16bit = uint16((degrees * 16384) / 360);
            return Trigonometry.sin(angle16bit);
        }

        function sinNanodegrees (uint256 _nanodegrees) public pure returns (int256) {
            return sinDegrees(_nanodegrees / 10 ** 9 );
        }

        function cosDegrees (uint256 _degrees) public pure returns (int256) {
            uint256 degrees = _degrees % 360;
            uint16 angle16bit = uint16((degrees * 16384) / 360);
            return Trigonometry.cos(angle16bit);
        }

        function cosNanodegrees (uint256 _nanodegrees) public pure returns (int256) {
            return cosDegrees(_nanodegrees / 10 ** 9 );
        }

        /*
        Testing geometries
        */

        // Checks to make sure first and last coordinates are the same. Otherwise it is a linestring.
        function isPolygon (int256[2][] memory _coordinates) public pure returns (bool) {
            uint256 l = _coordinates.length;
            if ((l > 2) &&
                (_coordinates[0][0] == _coordinates[l - 1][0]) &&
                (_coordinates[0][1] == _coordinates[l - 1][1]))
            {
                return true;
            } else {
                return false;
            }
        }

        function isLine (int256[2][] memory _coordinates) public pure returns (bool) {
            uint256 l = _coordinates.length;

            if ((l > 1) &&
                ((_coordinates[0][0] != _coordinates[l - 1][0]) ||
                (_coordinates[0][1] != _coordinates[l - 1][1])))
            {
                return true;
            } else {
                return false;
            }
        }

        // Babylonian method of finding square root (untested0)
        function sqrt(uint y) internal pure returns (uint z) {
            if (y > 3) {
                z = y;
                uint x = y / 2 + 1;
                while (x < z) {
                    z = x;
                    x = (y / x + x) / 2;
                }
            } else if (y != 0) {
                z = 1;
            } else {
                z = 0;
            }
            return z;
        }

        function abs(int x) internal pure returns (int) {
            return x >= 0 ? x : -x;
        }


        /*
        Conversion helper functions
        */
        function degreesToNanoradians(uint256 _degrees) public pure returns (uint256 radians_ ) {
            return nanodegreesToNanoradians(_degrees * 10**9);
        }

        function nanodegreesToNanoradians(uint256 _nanodegrees) public pure returns (uint256 radians_ ) {
            uint256 nanodegrees = _nanodegrees % (360 * 10**9);
            return nanodegrees * ( piScaled / 180 ) / 10**9;
        }

        function nanoradiansToDegrees (uint256 _nanoradians ) public pure returns (uint256 degrees_) {
            return ( 180 * _nanoradians ) / piScaled;
        }

        //
        function earthNanoradiansToNanometers (uint256 _nanoradians) public pure returns (uint256 nanometers_) {
            return (_nanoradians * earthRadius) / 10**9;
        }

        function earthNanodegreesToNanometers (uint256 _nanodegrees) public pure returns (uint256 nanometers_) {
            return earthNanoradiansToNanometers(nanodegreesToNanoradians(_nanodegrees));
        }


        /*
        @params Accepts two points in nanodegrees, [longitude, latitude].
        @returns distance between points on earth in nanometers
        NOTE: This calculates Euclidean distance, not Haversine distance. For near points
            this will be fine, but the further they are the greater the underestimation error.
        WARNING: TESTS FAILING!!
        */
        function distance(int[2] memory ptA, int[2] memory ptB) public pure returns (uint distanceNanometers_) {
            int x1 = ptA[0];
            int y1 = ptA[1];
            int x2 = ptB[0];
            int y2 = ptB[1];

            // Calculate the differences in x and y
            int deltaX = x2 - x1;
            int deltaY = y2 - y1;

            // Calculate Euclidean distance in nanodegrees
            uint distanceInNanodegrees = sqrt(uint(deltaX * deltaX + deltaY * deltaY));

            // Earth's radius in nanometers (6,371 km in nanometers)
            uint earthRadiusNanometers = 6371000000000;

            // Convert distance from nanodegrees to radians
            uint distanceInRadians = distanceInNanodegrees * 10**9 / 180 * piScaled / 10**9;

            // Convert radians to distance in nanometers
            distanceNanometers_ = distanceInRadians * earthRadiusNanometers / 10**9;
        }



        // https://www.mathopenref.com/coordpolygonarea.html
        // Only accepts simple polygons, not multigeometry polygons
        function area (int256[2][] memory _coordinates ) public pure returns (uint256 area_) {
            require(isPolygon(_coordinates) == true);

            uint256 l = _coordinates.length;

            int256 counter = 0;
            for (uint256 i = 0; i < l; i++) {

                int256 clockwiseCounter = _coordinates[i][0] * _coordinates[i + 1][1];
                int256 anticlockwiseCounter = _coordinates[i][1] * _coordinates[i + 1][0];

                counter += clockwiseCounter - anticlockwiseCounter;
            }

            return uint256(counter / 2);
        }


        // Returns centroid of group of points or
        function centroid (int256[2][] memory _coordinates) public pure returns (int256[2] memory) {

            int256 l;
            if (isPolygon(_coordinates) == true) {
                l = int256(_coordinates.length) - 1;
            } else {
                l = int256(_coordinates.length);
            }

            int256 lonTotal = 0;
            int256 latTotal = 0;

            for (uint256 i = 0; i < uint256(l); i++) {
                lonTotal += _coordinates[i][0];
                latTotal += _coordinates[i][1];
            }

            int256 lonCentroid = lonTotal / l;
            int256 latCentroid = latTotal / l;

            return [lonCentroid, latCentroid];
        }

        // Returns bounding box of geometry as [[minLon, minLat], [maxLon, maxLat]]
        function boundingBox (int256[2][] memory _coordinates) public pure returns (int256[2][2] memory) {

            require(_coordinates.length != 1); // A bounding box needs to contain at least two points.

            int256 minLon = 180 * 10**9;
            int256 minLat = 90 * 10**9;
            int256 maxLon = -180 * 10**9;
            int256 maxLat = -90 * 10**9;

            int256 l = int256(_coordinates.length);

            for (uint256 i = 0; i < uint256(l); i++ ) {
                if (_coordinates[i][0] < minLon) {
                    minLon = _coordinates[i][0];
                }
                if (_coordinates[i][1] < minLat) {
                    minLat = _coordinates[i][1];
                }
                if (_coordinates[i][0] > maxLon) {
                    maxLon = _coordinates[i][0];
                }
                if (_coordinates[i][1] > maxLon) {
                    maxLat = _coordinates[i][1];
                }
            }

            return [[minLon, minLat], [maxLon, maxLat]];
        }

        // Returns length of linestring
        function length (int256[2][] memory _coordinates) public pure returns (uint256 length_) {

            require (isLine(_coordinates) == true);
            uint l = _coordinates.length;
            length_ = 0;
            for (uint i = 0; i < (l - 1); i++) {
                length_ += distance(_coordinates[i], _coordinates[i + 1]);
            }
            return length_;

        }

        // Returns perimeter of polygon
        // NOTE: Not working yet. Relies on distance()
        function perimeter (int256[2][] memory _coordinates ) public pure returns (uint256 perimeter_) {

            require (isPolygon(_coordinates) == true);
            uint l = _coordinates.length;
            perimeter_ = 0;
            for (uint i = 0; i < (l - 1); i++) {
                perimeter_ += distance(_coordinates[i], _coordinates[i + 1]);
            }
            return perimeter_; 

        }

        /*
        Here we start brainstorming how algorithms might accept projected points rather than
        coordinates to overcome the challenge of implementing the computationally-intensive
        Haversine formula on chain ... if points converted into an equidistant projection are passed
        into the function, wouldn't the Euclidean distance between them result in accurate (relative)
        measures of their distance? Would it be possible to convert distance back into Earth units
        accurately? Probably - more research needed ....
        */

        function distanceBetweenAzimuthalEquidistantProjectedPoints(uint256[2] memory ptA, uint256[2] memory ptB) public view returns (uint256) {
          //
        }

        function bearingFromAzimuthalEquidistantProjectedPoints ( uint256[2] memory ptA, uint256[2] memory ptB ) public view returns (uint256) {

            // uint lonA = ptA[0];
            // uint lonB = ptB[0];
            // uint latA = ptA[1];
            // uint latB = ptB[1];

            // uint lonD = (int(lonB) - int(lonA)) < 0 ?

            // // var a = sinDegrees(lonB - lonA) * cosDegrees(latB);
            // // var b = cosDegrees(latA) * sinDegrees(latB) -
            //     // sinDegrees(latA) * cosDegrees(latB) * cosDegrees(lonD);


            // return Trigonometry.sin(16384 / 2);
        }


        // Since we are working with ints we suggest passing in nanodegrees, which ~= 0.1 mm
        // But it will work with any consistent units, so long as they are ints.
        // This is much cheaper than using radial buffer
        function boundingBoxBuffer (int256[2] memory _point, int256 _buffer) public pure returns (int256[2][2] memory) {
            int256[2] memory ll = [_point[0] - _buffer, _point[1] - _buffer];
            int256[2] memory ur = [_point[0] + _buffer, _point[1] + _buffer];

            return ([ll, ur]);
        }

        // Boolean functions:

        // Returns whether _point exists within bounding box _bbox
        function pointInBbox (int256[2] memory _point, int256[2][2] memory _bbox) public pure returns (bool ptInsideBbox_) {
            require(_bbox[0][0] < _bbox[1][0] && _bbox[0][1] < _bbox[1][1]);
            if ((_point[0] > _bbox[0][0]) && (_point[0] > _bbox[0][1]) && (_point[1] < _bbox[1][0]) && (_point[1] < _bbox[1][1]) ) {
                return true;
            } else {
                return false;
            }
        }

        // Translated from the impressive Javascript implementation by substack,
        // https://github.com/substack/point-in-polygon/blob/master/index.js
        // Really helpful explanation by Tom MacWright on Observable,
        // https://observablehq.com/@tmcw/understanding-point-in-polygon
        // Caution: Would be easy to run out of gas by sending geometries with many vertices.
        function pointInPolygon (int256[2] memory _point, int256[] memory _polygon) public pure returns (bool) {

        int256 x = _point[0];
        int256 y = _point[1];

        uint256 j = _polygon.length - 2;
        uint256 l = _polygon.length;

        bool pointInsidePolygon = false;
        for (uint i = 0; i < l - 1; i = i + 2) {

            int256 xi = _polygon[i];
            int256 yi = _polygon[i + 1];
            int256 xj = _polygon[j];
            int256 yj = _polygon[j + 1];

            j = i;

            bool intersect = ((yi > y) != (yj > y)) &&
                (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

            if (intersect) pointInsidePolygon = !pointInsidePolygon;
        }
        return pointInsidePolygon;

    }

        
    /*

    This function was inside Topo.sol 
    function pointInPolygon (int256[2] memory _point, int256[2][] memory _polygon ) public pure returns (bool pointInsidePolygon_) {

            int256 x = _point[0];
            int256 y = _point[1];

            uint256 j = _polygon.length - 1;
            uint256 l = _polygon.length;

            bool inside = false;
            for (uint256 i = 0; i < l; j = i++) {

                int256 xi = _polygon[i][0];
                int256 yi = _polygon[i][1];
                int256 xj = _polygon[j][0];
                int256 yj = _polygon[j][1];

                bool intersect = ((yi > y) != (yj > y)) &&
                    (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

                if (intersect) inside = !inside;
            }
            return inside;

    }
        
    */
}
