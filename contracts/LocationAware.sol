pragma solidity ^0.5.2;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";


contract PhysicalJurisdiction {

    address owner; // likely a jurisdiction's DAO contract address ...
    int[2][] public boundaries;
    int[2][2] public boundingBox;
    uint public numBoundaryPoints;
    string name;
    uint tax; // donation rate

    /*
    @param _boundaries: An array of ints representing coordinates of boundary vertices in nanodegrees (decimal degrees * 10**9)

    */
    constructor (int[] memory _boundaries, uint _tax, string memory _name) public {

        owner = msg.sender;

        uint l = _boundaries.length;

        // Check to make sure _boundaries array is the right length
        require(l % 2 == 0, "Please pass in an even-length boundaries array of [lon1, lat1, lon2, lat2, ... , lonN, latN");
        // test that first point == last point
        numBoundaryPoints = l / 2;

        // Convert _boundaries array into int[2][] array of point pairs:
        // In same loop calculate bounding box

        int minLon = 180 * 10**9; // should we use nanodegrees? 😬🤔
        int minLat = 90 * 10**9;
        int maxLon = -180 * 10**9;
        int maxLat = -90 * 10**9;

        for (uint i = 0; i < l; i += 2) {
            int[2] memory coords = [_boundaries[i], _boundaries[i + 1]];

            if (coords[0] < minLon) {
                minLon = coords[0];
            }
            if (coords[1] < minLat) {
                minLat = coords[1];
            }
            if (coords[0] > maxLon) {
                maxLon = coords[0];
            }
            if (coords[1] > maxLon) {
                maxLat = coords[1];
            }

            boundaries.push(coords);
        }

        boundingBox = [[minLon, minLat], [maxLon, maxLat]];
        tax = _tax;
        name = _name;

    }

    function updateTaxRate (uint _newTaxRate) public {
        require(msg.sender == owner);
        tax = _newTaxRate;
    }

    function transferOwnership (address _newOwner) public {
        require(msg.sender == owner);
        owner = _newOwner;
    }

    function updateJurisdictionName (string memory _newName) public {
        require(msg.sender == owner);
        name = _newName;
    }

}




contract LocationAwareWallet {


    address owner;
    address[] jurisdictions; // to test within for each transaction

    constructor (address _owner, address[] memory _jurisdictions) public {
        owner = _owner;
        jurisdictions = _jurisdictions;
    }

    // do we need this? Maybe owner includes funds with each .send() invocation
    function addFunds () public payable {

    }

    /*

    */
    function sendWithLocationChecks (
      address payable _to,
      int[2] memory _locationOfOwner,
      uint _value)
      public returns (
        string memory jurisdiction_)
      {

        require(msg.sender == owner);

        uint numJurisdictionsToCheck = jurisdictions.length;

        for (uint i = 0; i < numJurisdictionsToCheck; i++) {

            address jurisdictionAddress = jurisdictions[i];
            // int[2][] memory jurisdictionPolygon = fetchJurisdictionPolygon(jurisdictionAddress);

            if (withinJurisdictionBoundaries(_locationOfOwner, jurisdictionAddress) == true) {
                // transmit value to sender
                address(_to).transfer(_value);

                // transmit tax to jurisdiction

                return getJurisdictionName(jurisdictionAddress);
                // return jurisdictionAddress;
            }
        }


        // potential security flaw if somehow the for loop transmitted but didn't return ....
        address(_to).transfer(_value);

    }

    function withinJurisdictionBbox(int[2] memory _point, int[2][2] memory _bbox) public returns (bool) {

        int lon = _point[0];
        int lat = _point[1];

        if ((lon > _bbox[0][0] && lon < _bbox[1][0]) && (lat > _bbox[0][1] && lat < _bbox[1][1])) {
            return true;
        } else {
            return false;
        }
    }


    function fetchJurisdictionBbox(address _jurisdiction) public returns (int[2][2] memory jurisdictionBbox_) {

    }

    function fetchJurisdictionBoundaries(address _jurisdictionAddress) public returns (int[2][] memory jurisdictionBoundaries_) {

    }

    function withinJurisdictionBoundaries (int[2] memory _point, address _jurisdictionAddress) public returns (bool) {

        int[2][] memory jurisdictionBoundaries = fetchJurisdictionBoundaries(_jurisdictionAddress);
        return pointInPolygon(_point, jurisdictionBoundaries);
    }

    function getJurisdictionName (address _jurisdictionAddress) public returns (string memory jurisdictionName_) {
        // look up name from address using mapping
    }

    // Translated from the impressive Javascript implementation by substack,
    // https://github.com/substack/point-in-polygon/blob/master/index.js
    // Really helpful explanation by Tom MacWright on Observable,
    // https://observablehq.com/@tmcw/understanding-point-in-polygon
    // Caution: Would be easy to run out of gas by sending complex geometries.
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
