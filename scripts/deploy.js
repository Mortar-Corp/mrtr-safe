const { ethers, upgrades } = require("hardhat");

async function main() {
  const Factory = await ethers.getContractFactory("Factory");
  const factory = await Factory.deploy();

  await factory.deployed();

  console.log("factory: ", factory);

  // first deploy Factory upgradable beacon
  // const Factory = await ethers.getContractFactory("Factory");
  // const beaconFactory = await upgrades.deployBeacon(Factory);
  // await beaconFactory.deployed();
  // console.log("beaconFactory deets:", beaconFactory);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
