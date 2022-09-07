const { ethers, upgrades } = require("hardhat");

async function main() {
  const factoryAddress = process.env.FACTORY_ADDRESS;

  const FactoryFactory = await ethers.getContractFactory("Factory");
  const factoryFactoryContract = await FactoryFactory.attach(factoryAddress);

  // then create Safe proxy
  const owners = ["0xD68da75C2c9AFDA1C2404491c03E18D297cE0e42"];
  const minApprovals = 1;
  const safeProxy = await factoryFactoryContract.createWallet(
    owners,
    minApprovals
  );
  const receipt = await safeProxy.wait();
  console.log("deploy safe proxy receipt: ", receipt);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
