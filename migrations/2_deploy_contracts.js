const LocationAware = artifacts.require("LocationAware");
const Jurisdiction = artifacts.require("Jurisdiction");

module.exports = function (deployer) {
  deployer.deploy(Jurisdiction);
  deployer.deploy(LocationAware);
}
