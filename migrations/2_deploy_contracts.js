const Trigonometry = artifacts.require("Trigonometry");
const Spatial = artifacts.require("Spatial");
const Jurisdiction = artifacts.require("Jurisdiction");
const LocationAware = artifacts.require("LocationAware");


module.exports = async function (deployer) {
  await deployer.deploy(Trigonometry);

  await deployer.link(Trigonometry, [Spatial]);

  await deployer.deploy(Spatial);

  await deployer.deploy(Jurisdiction);

  const JurisdictionContract = await Jurisdiction.deployed();

  console.log(
    "Juristiction Contract deployed at:",
    JurisdictionContract.address
  );

  await deployer.link(Spatial, [LocationAware]);

  await deployer.deploy(LocationAware);

  const LocationAwareContract = await LocationAware.deployed();

  console.log(
    "Location Aware Contract deployed at:",
    LocationAwareContract.address
  );
};
