const { ethers, upgrades } = require("hardhat");

async function upgrade() {
  // Upgrade factory proxy
  const factoryBeaconAddress = process.env.FACTORY_BEACON_PROXY_TESTNET;

  const FactoryV2 = await ethers.getContractFactory("Factory");

  await upgrades.upgradeBeacon(factoryBeaconAddress, FactoryV2);
  console.log("Factory beacon proxies upgraded");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
upgrade().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
