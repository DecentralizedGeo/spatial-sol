pragma solidity ^0.5.2;


contract Jurisdiction {

    address public owner; // likely a jurisdiction's DAO contract address ...
    int[] public boundaries;
    uint public numBoundaryPoints;
    string public name;
    uint public tax; // donation rate

    /*
    @param _boundaries: An array of ints representing coordinates of boundary
      vertices in nanodegrees (decimal degrees * 10**9)

    */

    constructor () public {

        owner = msg.sender;

        // uint l = _boundaries.length;

        // // Check to make sure _boundaries array is the right length
        // require(l % 2 == 0,
        //     "Please pass in an even-length boundaries array of [lon1, lat1, lon2, lat2, ... , lonN, latN]");

        // numBoundaryPoints = l;
        // boundaries = _boundaries;
        // name = _name;
        // tax = _tax;
    }

    modifier owned (address _account) {
        require (msg.sender == owner, "Sorry, owner must call function");
        _;
    }


    function () external payable {

    }

    function getBalance () public view returns (uint balance_) {
        return address(this).balance;
    }

    function updateBoundaries (int[] memory _boundaries) public owned(owner) {
      boundaries = _boundaries;

      numBoundaryPoints = _boundaries.length;
    }

    function updateTaxRate (uint _newTaxRate) public owned(owner) {
        tax = _newTaxRate;
    }

    function updateJurisdictionName (string memory _newName) public owned(owner)  {
        name = _newName;
    }

    function transferOwnership (address _newOwner) public owned(owner)  {
        owner = _newOwner;
    }



}

contract LocationAware {

    address public owner;
    mapping(address => bool) subscribedToJurisdiction; // to test within for each transaction
    address[] public jurisdictions;

    constructor () public {
        owner = msg.sender;
    }

    modifier owned(address _address) {
      require (_address == owner);
      _;
    }

    // do we need this? Maybe owner includes funds with each .send() invocation
    function fund () external payable {
        // require(_value == msg.value);
    }

    function getBalance () public view returns (uint balance_) {
        return address(this).balance;
    }


    function subscribeToJurisdiction (address _jurisdiction) public owned(owner) {
        jurisdictions.push(_jurisdiction);
        subscribedToJurisdiction[_jurisdiction] = true;
    }

    function unsubscribeFromJurisdiction (address _jurisdiction) public owned(owner) {
        subscribedToJurisdiction[_jurisdiction] = false;
    }

    /*

    */
    function sendWithLocationChecks (
      address payable _to,
      int[2] memory _locationOfOwner,
      uint _value)
      public returns (uint)
      {

        require(msg.sender == owner);

        uint numJurisdictionsToCheck = jurisdictions.length;

        if (numJurisdictionsToCheck == 0) {
            address(_to).transfer(_value);
            return 0;
            // return "You're not subscribed to any jurisdictions.";

        }

        for (uint i = 0; i < numJurisdictionsToCheck; i++) {

            if (subscribedToJurisdiction[jurisdictions[i]] == true) {
                address payable jurisdictionAddress = address(uint160(jurisdictions[i]));

                Jurisdiction jurisdiction = Jurisdiction(jurisdictionAddress);
                uint jurisdictionBoundariesLength = jurisdiction.numBoundaryPoints();

                int[] memory jurisdictionBoundary = new int[](jurisdictionBoundariesLength);

                for (uint j = 0; j < jurisdictionBoundariesLength; j++) {
                    jurisdictionBoundary[j] = jurisdiction.boundaries(j);
                }

                if (withinJurisdictionBoundaries(_locationOfOwner, jurisdictionBoundary) == true) {
                    // transmit value to sender

                    address(_to).transfer(_value);

                    uint taxToPay = _value * jurisdiction.tax() / 100;
                    // transmit tax to jurisdiction
                    jurisdictionAddress.transfer(taxToPay);

                    return taxToPay;
                }
            }
            }

        // potential security flaw if somehow the for loop transmitted but didn't return ....
        address(_to).transfer(_value);

        return 0;

    }

    function withinJurisdictionBoundaries (int[2] memory _point, int[] memory _jurisdictionBoundaries) public returns (bool) {
        return pointInPolygon(_point, _jurisdictionBoundaries);
    }

    // Translated from the impressive Javascript implementation by substack,
    // https://github.com/substack/point-in-polygon/blob/master/index.js
    // Really helpful explanation by Tom MacWright on Observable,
    // https://observablehq.com/@tmcw/understanding-point-in-polygon
    // Caution: Would be easy to run out of gas by sending complex geometries.
    function pointInPolygon (int[2] memory _point, int[] memory _polygon ) public returns (bool pointInsidePolygon_) {

        int x = _point[0];
        int y = _point[1];

        uint j = _polygon.length - 2;
        uint l = _polygon.length;

        bool inside = false;
        for (uint i = 0; i < l - 1; i = i + 2) {

            int xi = _polygon[i];
            int yi = _polygon[i + 1];
            int xj = _polygon[j];
            int yj = _polygon[j + 1];

            j = i;

            bool intersect = ((yi > y) != (yj > y)) &&
                (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

            if (intersect) inside = !inside;
        }
        return inside;

    }

}
