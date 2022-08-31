const { ethers, upgrades } = require("hardhat");

async function upgrade() {
  // Upgrade factory proxy
  const walletBeaconAddress = "0x199D9a45aC8392FeDdb33f648669E47DA613c2d6";

  const WalletV2 = await ethers.getContractFactory("MortarGnosis");

  await upgrades.upgradeBeacon(walletBeaconAddress, WalletV2);
  console.log("Wallet beacon proxies upgraded!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
upgrade().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
