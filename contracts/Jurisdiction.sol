// A demo contract showcasing a possible application built with Spatial.sol

// SPDX-License-Identifier: APACHE OR MIT
pragma solidity ^0.8.0;


contract Jurisdiction {

    address public owner; // likely a jurisdiction's DAO contract address ...
    int256[] public boundaries;
    uint256 public numBoundaryPoints;
    string public name;
    uint256 public tax; // donation rate

    /*
    @param _boundaries: An array of ints representing coordinates of boundary
      vertices in nanodegrees (decimal degrees * 10**9)

    */

    constructor () {

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

    function getBalance () public view returns (uint256 balance_) {
        return address(this).balance;
    }

    function updateBoundaries (int256[] memory _boundaries) public owned(owner) {
      boundaries = _boundaries;

      numBoundaryPoints = _boundaries.length;
    }

    function updateTaxRate (uint256 _newTaxRate) public owned(owner) {
        tax = _newTaxRate;
    }

    function updateJurisdictionName (string memory _newName) public owned(owner)  {
        name = _newName;
    }

    function transferOwnership (address _newOwner) public owned(owner)  {
        owner = _newOwner;
    }

}

