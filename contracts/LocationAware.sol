pragma solidity ^0.5.2;

/* import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol"; */


contract Jurisdiction {

    address owner; // likely a jurisdiction's DAO contract address ...
    int[] public boundaries;
    uint public numBoundaryPoints;
    string public name;
    uint public tax; // donation rate

    /*
    @param _boundaries: An array of ints representing coordinates of boundary vertices in nanodegrees (decimal degrees * 10**9)

    */

    constructor (int[] memory _boundaries, uint _tax, string memory _name) public {

        owner = msg.sender;

        uint l = _boundaries.length;

        // Check to make sure _boundaries array is the right length
        require(l % 2 == 0,
            "Please pass in an even-length boundaries array of [lon1, lat1, lon2, lat2, ... , lonN, latN]");

        numBoundaryPoints = l;
        boundaries = _boundaries;
        name = _name;
        tax = _tax;
    }

    modifier owned (address _account) {
        require (msg.sender == owner, "Sorry, owner must call function");
        _;
    }

    function updateTaxRate (uint _newTaxRate) public owned(owner) {
        tax = _newTaxRate;
    }

    function transferOwnership (address _newOwner) public owned(owner)  {
        owner = _newOwner;
    }

    function updateJurisdictionName (string memory _newName) public owned(owner)  {
        name = _newName;
    }

    function sendFunds () public payable {

    }

    function getBalance () public view returns (uint balance_) {
        return address(this).balance;
    }

}




contract LocationAwareWallet {


    address owner;
    address[] subscribedJurisdictions; // to test within for each transaction


    constructor (address[] memory _jurisdictions) public payable {
        owner = msg.sender;
        subscribedJurisdictions = _jurisdictions;
    }

    // do we need this? Maybe owner includes funds with each .send() invocation
    function addFunds () public payable {
        // require(_value == msg.value);
    }

    function getBalance () public view returns (uint balance_) {
        return address(this).balance;
    }

    /*

    */
    function sendWithLocationChecks (
      address payable _to,
      int[2] memory _locationOfOwner,
      uint _value)
      public
      {

        require(msg.sender == owner);

        uint numJurisdictionsToCheck = subscribedJurisdictions.length;

        for (uint i = 0; i < numJurisdictionsToCheck; i++) {

            address jurisdictionAddress = subscribedJurisdictions[i];

            Jurisdiction jurisdiction = Jurisdiction(jurisdictionAddress);
            uint jurisdictionBoundariesLength = jurisdiction.numBoundaryPoints();

            int[] memory jurisdictionBoundary = new int[](jurisdictionBoundariesLength);

            for (uint j = 0; j < jurisdictionBoundariesLength; j++) {
                jurisdictionBoundary[j] = jurisdiction.boundaries(j);
            }

            if (withinJurisdictionBoundaries(_locationOfOwner, jurisdictionBoundary) == true) {
                // transmit value to sender

                address(_to).transfer(_value);

                // transmit tax to jurisdiction
                jurisdiction.sendFunds.value(_value * jurisdiction.tax() / 100);

                // return "HY";
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

    function withinJurisdictionBoundaries (int[2] memory _point, int[] memory _jurisdictionBoundaries) public returns (bool) {

        // int[2][] memory jurisdictionBoundaries = fetchJurisdictionBoundaries(_jurisdictionAddress);
        return pointInPolygon(_point, _jurisdictionBoundaries);
    }

    function getJurisdictionName (address _jurisdictionAddress) public returns (string memory jurisdictionName_) {
        // look up name from address using mapping
    }

    // Translated from the impressive Javascript implementation by substack,
    // https://github.com/substack/point-in-polygon/blob/master/index.js
    // Really helpful explanation by Tom MacWright on Observable,
    // https://observablehq.com/@tmcw/understanding-point-in-polygon
    // Caution: Would be easy to run out of gas by sending complex geometries.
    function pointInPolygon (int[2] memory _point, int[] memory _polygon ) public returns (bool pointInsidePolygon_) {

        int x = _point[0];
        int y = _point[1];

        uint j = _polygon.length - 1;
        uint l = _polygon.length;

        bool inside = false;
        for (uint i = 0; i < l; j = i + 2) {

            int xi = _polygon[i];
            int yi = _polygon[i + 1];
            int xj = _polygon[j];
            int yj = _polygon[j + 1];

            bool intersect = ((yi > y) != (yj > y)) &&
                (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

            if (intersect) inside = !inside;
        }
        return inside;

    }

}
