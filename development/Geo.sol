pragma solidity ^0.4.17;


/*
    This library is a translation of Turf.js, a geospatial analysis library in Javascript.
    http://turfjs.org/

*/

import "github.com/Sikorkaio/sikorka/contracts/trigonometry.sol";
import "github.com/bokkypoobah/SimpleTokenCrowdsaleContractAudit/contracts/SafeMath.sol";

contract Geo {

        using SafeMath for uint;

        uint earthRadius = 6371008800000000; // in nanometers,
        uint piScaled = 3141592654; // approx ... will affect precision


        function sinDegrees (uint _degrees) public pure returns (int) {
            uint degrees = _degrees % 360;
            uint16 angle16bit = uint16((degrees * 16384) / 360);
            return Trigonometry.sin(angle16bit);
        }

        function sinNanodegrees (uint _nanodegrees) public pure returns (int) {
            return sinDegrees(_nanodegrees / 10 ** 9 );
        }

        function cosDegrees (uint _degrees) public pure returns (int) {
            uint degrees = _degrees % 360;
            uint16 angle16bit = uint16((degrees * 16384) / 360);
            return Trigonometry.cos(angle16bit);
        }

        function cosNanodegrees (uint _nanodegrees) public pure returns (int) {
            return cosDegrees(_nanodegrees / 10 ** 9 );
        }

        // Checks to make sure first and last coordinates are the same. Otherwise it is a linestring.
        function isPolygon (int[2][] _coordinates) public pure returns (bool) {

            uint l = _coordinates.length;
            if ((l > 2) &&
                (_coordinates[0][0] == _coordinates[l - 1][0]) &&
                (_coordinates[0][1] == _coordinates[l - 1][1]))
            {
                return true;
            } else {
                return false;
            }
        }

        function isLine (int[2][] _coordinates) public pure returns (bool) {
            uint l = _coordinates.length;

            if ((l > 1) &&
                ((_coordinates[0][0] != _coordinates[l - 1][0]) ||
                (_coordinates[0][1] != _coordinates[l - 1][1])))
            {
                return true;
            } else {
                return false;
            }
        }

        // From https://ethereum.stackexchange.com/questions/2910/can-i-square-root-in-solidity
        function sqrt (int _x) public view returns (uint y_) {

            if (_x < 0) {
                _x = _x * -1;
            }

            uint x = uint(_x);

            uint z = (x + 1) / 2;
            y_ = x;
            while (z < y_) {
                y_ = z;
                z = (x / z + z) / 2;
            }
        }

        function degreesToNanoradians(uint _degrees) public view returns (uint radians_ ) {
            return nanodegreesToNanoradians(_degrees * 10**9);
        }

        function nanodegreesToNanoradians(uint _nanodegrees) public view returns (uint radians_ ) {
            uint nanodegrees = _nanodegrees % (360 * 10**9);
            return nanodegrees * ( piScaled / 180 ) / 10**9;
        }

        function nanoradiansToDegrees (uint _nanoradians ) public view returns (uint degrees_) {
            return ( 180 * _nanoradians ) / piScaled;
        }

        //
        function earthNanoradiansToNanometers (uint _nanoradians) public view returns (uint nanometers_) {
            return (_nanoradians * earthRadius) / 10**9;
        }

        function earthNanodegreesToNanometers (uint _nanodegrees) public view returns (uint nanometers_) {
            return earthNanoradiansToNanometers(nanodegreesToNanoradians(_nanodegrees));
        }

        /*
        @params Accepts two points in nanodegrees, [longitude, latitude].
        @returns distance between points on earth in nanometers
        NOTE: This calculates Euclidean distance, not Haversine distance. For near points
            this will be fine, but the further they are the greater the underestimation error.
        WARNING: NOT WORKING YET!!
        */
        function distance (int[2] ptA, int[2] ptB) public view returns (uint distanceNanometers_) {

            int x1 = ptA[0];
            int y1 = ptA[1];

            int x2 = ptB[0];
            int y2 = ptB[1];

            uint across = (x2 - x1) < 0 ? uint((x2 - x1) * -1) : uint(x2 - x1);

            uint up = (y2 - y1) < 0 ? uint((y2 - y1) * -1) : uint(y2 - y1);

            return nanodegreesToNanoradians(sqrt(int(across * across) + int(up * up)));

        }



        // Note: this must be a polygon in clockwise
        // https://www.mathopenref.com/coordpolygonarea.html
        function area ( int[2][] _coordinates ) public view returns (uint area_) {
            require(isPolygon(_coordinates) == true);

            uint l = _coordinates.length;

            int counter = 0;
            for (uint i = 0; i < l; i++) {

                int clockwiseCounter = _coordinates[i][0] * _coordinates[i + 1][1];
                int anticlockwiseCounter = _coordinates[i][1] * _coordinates[i + 1][0];

                counter += clockwiseCounter - anticlockwiseCounter;
            }

            return uint(counter / 2);
        }


        // Returns centroid of group of points or
        function centroid (int[2][] _coordinates) public view returns (int[2]) {

            int l;
            if (isPolygon(_coordinates) == true) {
                l = int(_coordinates.length) - 1;
            } else {
                l = int(_coordinates.length);
            }

            int lonTotal = 0;
            int latTotal = 0;

            for (uint i = 0; i < uint(l); i++) {
                lonTotal += _coordinates[i][0];
                latTotal += _coordinates[i][1];
            }

            int lonCentroid = lonTotal / l;
            int latCentroid = latTotal / l;

            return [lonCentroid, latCentroid];
        }

        function boundingBox (int[2][] _coordinates) public view returns (int[2][2]) {

            require(_coordinates.length != 1); // A bounding box needs to contain at least two points.

            int minLon = 180 * 10**9;
            int minLat = 90 * 10**9;
            int maxLon = -180 * 10**9;
            int maxLat = -90 * 10**9;

            int l = int(_coordinates.length);

            for ( uint i = 0; i < uint(l); i++ ) {
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


        function length (int[2][] _coordinates) public view returns (uint length_) {

            require (isLine(_coordinates) == true);

            uint l = _coordinates.length;

            length_ = 0;
            for (uint i = 0; i < (l - 1); i++) {
                length_ += distance(_coordinates[i], _coordinates[i + 1]);
            }

            return length_;

        }

        function perimeter (int[2][] _coordinates ) public view returns (uint perimeter_) {

            require (isPolygon(_coordinates) == true);
            uint l = _coordinates.length;

            perimeter_ = 0;
            for (uint i = 0; i < (l - 1); i++) {
                perimeter_ += distance(_coordinates[i], _coordinates[i + 1]);
            }

            return perimeter_;

        }

        function bearingFromAzimuthalEquidistantProjectedPoints ( uint[2] ptA, uint[2] ptB ) public view returns (uint) {


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
        function boundingBoxBuffer (int[2] _point, int _buffer) public view returns (int[2][2] ) {
            int[2] memory ll = [_point[0] - _buffer, _point[1] - _buffer];
            int[2] memory ur = [_point[0] + _buffer, _point[1] + _buffer];

            return ([ll, ur]);
        }

        function pointInBbox (int[2] _point, int[2][2] _bbox) public view returns (bool ptInsideBbox_) {
            require(_bbox[0][0] < _bbox[1][0] && _bbox[0][1] < _bbox[1][1]);
            if ((_point[0] > _bbox[0][0]) && (_point[0] < _bbox[1][0]) && (_point[1] > _bbox[1][0]) && (_point[1] < _bbox[1][1]) ) {
                return true;
            } else {
                return false;
            }
        }

        function pointInPolygon (int[2] memory _point, int[2][] memory _polygon ) public returns (bool pointInsidePolygon_) {

                int x = _point[0];
                int y = _point[1];

                uint j = _polygon.length - 1;
                uint l = _polygon.length;

                bool inside = false;
                for (uint i = 0; i < l; j = i++) {

                    int xi = _polygon[i][0];
                    int yi = _polygon[i][1];
                    int xj = _polygon[j][0];
                    int yj = _polygon[j][1];

                    bool intersect = ((yi > y) != (yj > y)) &&
                        (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

                    if (intersect) inside = !inside;
                }
                return inside;

            }


}
