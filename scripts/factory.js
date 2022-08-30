const { ethers, upgrades } = require("hardhat");
const { Signer } = require("ethers");

async function main() {

    constant [mrtr, owners] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();
    await factory.deployed();
    console.log("Factory Address:", factory.address);

    const MrtrSafe = await ethers.getContractFactory("MrtrSafe");
    const walletBeacon = await upgrades.deployBeacon(new(MrtrSafe.address));
    await deployBeacon.deployed();
    walletBeacon.transferOwnership(mrtr);
    console.log("walletBeacon address:", walletBeacon.address);

 
    const Proxy = await upgrades.deployBeaconProxy(walletBeacon, [walletBeacon, MrtrSafe], {initializer: "__MrtrSafe_init.selector"});
    

}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.log("\nFailed Deployment !")
    console.error(error);
    process.exitCode = 1;
  });