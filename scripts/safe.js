const { ethers } = require("hardhat");
const { Signer } = require("ethers");

async function main() {

    const [deployer, owners] = await ethers.getSigners();
    console.log("Deploying Account:", await deployer.getAddress());


    const Safe = await ethers.getContractFactory("MrtrSafe");
    const safe = await Safe.deploy();
    await safe.deployed();
    console.log("contract deployed to:", safe.address);
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });