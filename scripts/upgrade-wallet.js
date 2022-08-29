const { ethers, upgrades } = require("hardhat");

async function upgrade() {
  // Upgrade factory proxy
  const walletBeaconAddress = process.env.WALLET_BEACON_PROXY_TESTNET;

  const WalletV2 = await ethers.getContractFactory("Factory");

  await upgrades.upgradeBeacon(walletBeaconAddress, WalletV2);
  console.log("Wallet beacon proxies upgraded");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
upgrade().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
