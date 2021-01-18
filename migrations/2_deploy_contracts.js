const Trigonometry = artifacts.require("Trigonometry");
const Spatial = artifacts.require("Spatial");


module.exports = async function (deployer) {
  await deployer.deploy(Trigonometry);

  await deployer.link(Trigonometry, [Spatial]);

  await deployer.deploy(Spatial);

  const SpatialContract = await Spatial.deployed();

  console.log(
    "Spatial-Sol deployed at:",
    SpatialContract.address
  );
};
