const { ethers, upgrades } = require("hardhat");

async function main() {
  // get Factories
  const Factory = await ethers.getContractFactory("Factory");
  const Safe = await ethers.getContractFactory("MortarGnosis");

  // first deploy wallet Upgradable beacon
  const beaconSafe = await upgrades.deployBeacon(Safe);
  await beaconSafe.deployed();
  console.log("Wallet Beacon deployed to:", beaconSafe.address);

  // then deploy factory
  const factoryContract = await upgrades.deployProxy(Factory, [
    beaconSafe.address,
  ]);
  await factoryContract.deployed();
  console.log("Factory deployed to: ", factoryContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
