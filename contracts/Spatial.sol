// SPDX-License-Identifier: APACHE OR MIT

pragma solidity ^0.7.0;

/*
    This library is intended to give Ethereum developers access to spatial functions to calculate
    geometric values and topologicial relationships on the EVM. It is a translation of Turf.js,
    a geospatial analysis library in Javascript. http://turfjs.org/
    Code first developed by John IV (@johnx25bd) at ETHParis 2019.
*/

import "./Trigonometry.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Spatial {

        using SafeMath for uint256;

        uint256 public earthRadius = 6371008800000000; // in nanometers,
        uint256 public piScaled = 3141592654; // approx ... will affect precision

        /*
        Trigonemtric functions
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

        // Babylonian method of finding square root,
        // From https://ethereum.stackexchange.com/questions/2910/can-i-square-root-in-solidity
        function sqrt (int256 _x) public pure returns (uint256 y_) {

            if (_x < 0) {
                _x = _x * -1;
            }

            uint256 x = uint256(_x);

            uint256 z = (x + 1) / 2;
            y_ = x;
            while (z < y_) {
                y_ = z;
                z = (x / z + z) / 2;
            }
        }

        /*
        Conversion helper functions
        */
        function degreesToNanoradians(uint256 _degrees) public view returns (uint256 radians_ ) {
            return nanodegreesToNanoradians(_degrees * 10**9);
        }

        function nanodegreesToNanoradians(uint256 _nanodegrees) public view returns (uint256 radians_ ) {
            uint256 nanodegrees = _nanodegrees % (360 * 10**9);
            return nanodegrees * ( piScaled / 180 ) / 10**9;
        }

        function nanoradiansToDegrees (uint256 _nanoradians ) public view returns (uint256 degrees_) {
            return ( 180 * _nanoradians ) / piScaled;
        }

        //
        function earthNanoradiansToNanometers (uint256 _nanoradians) public view returns (uint256 nanometers_) {
            return (_nanoradians * earthRadius) / 10**9;
        }

        function earthNanodegreesToNanometers (uint256 _nanodegrees) public view returns (uint256 nanometers_) {
            return earthNanoradiansToNanometers(nanodegreesToNanoradians(_nanodegrees));
        }

        /*
        @params Accepts two points in nanodegrees, [longitude, latitude].
        @returns distance between points on earth in nanometers
        NOTE: This calculates Euclidean distance, not Haversine distance. For near points
            this will be fine, but the further they are the greater the underestimation error.
        WARNING: NOT WORKING YET!!
        */
        function distance (int[2] memory ptA, int[2] memory ptB) public view returns (uint distanceNanometers_) {

            /* int x1 = ptA[0];
            int y1 = ptA[1];
            int x2 = ptB[0];
            int y2 = ptB[1];
            uint across = (x2 - x1) < 0 ? uint((x2 - x1) * -1) : uint(x2 - x1);
            uint up = (y2 - y1) < 0 ? uint((y2 - y1) * -1) : uint(y2 - y1);
            return nanodegreesToNanoradians(sqrt(int(across * across) + int(up * up))); */

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
        // NOTE: Not working yet. Relies on distance()
        function length (int256[2][] memory _coordinates) public view returns (uint256 length_) {

            /* require (isLine(_coordinates) == true);
            uint l = _coordinates.length;
            length_ = 0;
            for (uint i = 0; i < (l - 1); i++) {
                length_ += distance(_coordinates[i], _coordinates[i + 1]);
            }
            return length_; */

        }

        // Returns perimeter of polygon
        // NOTE: Not working yet. Relies on distance()
        function perimeter (int256[2][] memory _coordinates ) public view returns (uint256 perimeter_) {
/*
            require (isPolygon(_coordinates) == true);
            uint l = _coordinates.length;
            perimeter_ = 0;
            for (uint i = 0; i < (l - 1); i++) {
                perimeter_ += distance(_coordinates[i], _coordinates[i + 1]);
            }
            return perimeter_; */

        }

        /*
        Here we start brainstorming how algorithms might accept projected points rather
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

        // Returns whether _point exists within bounding box
        function pointInBbox (int256[2] memory _point, int256[2][2] memory _bbox) public pure returns (bool ptInsideBbox_) {
            require(_bbox[0][0] < _bbox[1][0] && _bbox[0][1] < _bbox[1][1]);
            if ((_point[0] > _bbox[0][0]) && (_point[0] < _bbox[1][0]) && (_point[1] > _bbox[1][0]) && (_point[1] < _bbox[1][1]) ) {
                return true;
            } else {
                return false;
            }
        }

        // Tests whether point is in polygon
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
}