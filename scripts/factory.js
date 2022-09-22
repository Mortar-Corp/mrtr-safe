const { ethers, upgrades } = require("hardhat");
const { BigNumber } = require("@ethersproject/bignumber");
const { Signer } = require("ethers");
const fs = require("fs");
const file = require("../artifacts/contracts/MrtrSafe.sol/MrtrSafe.json");
const proxy = require("../artifacts/contracts/Proxy/BeaconProxy.sol/BeaconProxy.json");

async function main() {
    
    const [deployer, owners] = await ethers.getSigners();
    console.log("Deploying Account:", await deployer.getAddress());

    //const Factory = await ethers.getContractFactory("Factory");

    //await factory.getWalletBeacon()
    //console.log("beacon contract:", beacon.address);
    //console.log("beacon contract address:", beacon.address);
    //console.log("Beacon Owned By:", deployer.address);
   
    //const bytes = file.bytecode;
    //const abi = file.abi;
    // let V1contract = await Impl.deploy();
    // await V1contract.deployed();
    // console.log("Impl Address:", V1contract.address);
    const safe = await ethers.getContractFactory("MrtrSafe");
    const beacon = await upgrades.deployBeacon(safe);
    await beacon.deployed();
    await beacon.transferOwnership(deployer);
    beacon.attach(beacon.address)
    
    console.log("beacon contract address:", beacon.address);
    console.log("Beacon Owned By:", deployer.address);

    // const bytesProxy = proxy.bytecode;
    // const abiProxy = proxy.abi;
    // const proxyImpl = new ethers.ContractFactory(abiProxy, bytesProxy, owners);



    // //proxyImpl.connect(owners);
    // await factory.createWallet(
    //     [
    //         "0xA55ebE225d35A66a6df523846824fb9f9Fe4300C",
    //         "0x7FfdD2c05C3760A5Bcb10c39ac5bF55702ebcc43"
    //     ],
    //     2
    // );
    //const firstWallet = 

 
    //const walletProxy = await upgrades.deployBeaconProxy(beacon.address, Impl, [], {initializer: "__MrtrSafe_init", unsafeAllow: "delegatecall"});
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