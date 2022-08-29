const { ethers, upgrades } = require("hardhat");

async function main() {
  // first deploy Factory upgradable beacon
  const Factory = await ethers.getContractFactory("Factory");
  const beaconFactory = await upgrades.deployBeacon(Factory);
  await beaconFactory.deployed();
  console.log("beaconFactory deets:", beaconFactory);

  // deploy beacon proxy for Factory
  // init() on proxy returns ugpradable wallet beacon
  // const factoryProxy = await upgrades.deployProxy(beaconFactory, Factory);
  // await factoryProxy.deployed();
  // console.log("factoryProxy deets:", factoryProxy);

  // then deploy Wallet proxy from wallet beacon address
  // factoryProxy.createWallet();
  // const walletFactory = await upgrades.deployBeacon(Wallet);
  // await walletFactory.deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
