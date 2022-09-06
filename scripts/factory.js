const { ethers, upgrades, artifacts } = require("hardhat");
const { BigNumber } = require("@ethersproject/bignumber");
const { Signer } = require("ethers");
const file = require("../artifacts/contracts/MrtrSafe.sol/MrtrSafe.json");

async function main() {
    
    const [deployer, owners] = await ethers.getSigners();
    const _owners = [owners];

    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();
    await factory.deployed();
    console.log("Factory Address:", factory.address);
    console.log("Deployer Address:", deployer.address);

   
    const bytes = file.bytecode;
    const abi = file.abi;
    const Impl = new ethers.ContractFactory(abi, bytes, deployer);
    const ImplContract = await Impl.deploy();
    const beacon = await upgrades.deployBeacon(Impl);
    beacon.transferOwnership(deployer);
    await beacon.deployed();
    console.log("Impl contract:", ImplContract.address);
    console.log("beacon contract address:", beacon.address);
    console.log("Beacon Owned By:", deployer.address);
 
    // const walletProxy = await upgrades.deployBeaconProxy(beacon, Impl, [], {initializer: "__MrtrSafe_init", unsafeAllow: "delegatecall"});
    // await walletProxy.deployed();
    // console.log("First Proxy Address:", walletProxy.address);

    //const Proxy = await Proxy.attach(walletProxy.address);   

    // Proxy.createWallet()


}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.log("\nFailed Deployment !")
    console.error(error);
    process.exitCode = 1;
  });