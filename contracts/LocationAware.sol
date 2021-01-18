// SPDX-License-Identifier: APACHE OR MIT
pragma solidity ^0.8.0;

import "./Jurisdiction.sol";
import "./Spatial.sol";

contract LocationAware {

    address public owner;
    mapping(address => bool) public subscribedToJurisdiction; // to test within for each transaction
    address[] public jurisdictions;

    constructor () {
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

    function getBalance () public view returns (uint256 balance_) {
        return address(this).balance;
    }


    function subscribeToJurisdiction (address _jurisdiction) public owned(owner) {
        jurisdictions.push(_jurisdiction);
        subscribedToJurisdiction[_jurisdiction] = true;
    }

    function unsubscribeFromJurisdiction (address _jurisdiction) public owned(owner) {
        subscribedToJurisdiction[_jurisdiction] = false;
    }

    function sendWithLocationChecks (
      address payable _to,
      int256[2] memory _locationOfOwner,
      uint256 _value)
      public returns (uint256)
      {

        require(msg.sender == owner);

        uint256 numJurisdictionsToCheck = jurisdictions.length;

        if (numJurisdictionsToCheck == 0) {
            _to.transfer(_value);
            return 0;
            // return "You're not subscribed to any jurisdictions.";

        }

        for (uint256 i = 0; i < numJurisdictionsToCheck; i++) {

            if (subscribedToJurisdiction[jurisdictions[i]] == true) {
                address payable jurisdictionAddress = payable(address(uint160(jurisdictions[i])));

                Jurisdiction jurisdiction = Jurisdiction(jurisdictionAddress);
                uint256 jurisdictionBoundariesLength = jurisdiction.numBoundaryPoints();

                int256[] memory jurisdictionBoundary = new int256[](jurisdictionBoundariesLength);

                for (uint256 j = 0; j < jurisdictionBoundariesLength; j++) {
                    jurisdictionBoundary[j] = jurisdiction.boundaries(j);
                }

                if (withinJurisdictionBoundaries(_locationOfOwner, jurisdictionBoundary) == true) {
                    // transmit value to sender

                    _to.transfer(_value);

                    uint256 taxToPay = _value * jurisdiction.tax() / 100;
                    // transmit tax to jurisdiction
                    jurisdictionAddress.transfer(taxToPay);

                    return taxToPay;
                }
            }
            }

        // potential security flaw if somehow the for loop transmitted but didn't return ....
        _to.transfer(_value);

        return 0;

    }

    function withinJurisdictionBoundaries (int256[2] memory _point, int256[] memory _jurisdictionBoundaries) public pure returns (bool) {
        return Spatial.pointInPolygon(_point, _jurisdictionBoundaries);
    }


}
