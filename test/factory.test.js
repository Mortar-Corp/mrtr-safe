
const { expect } = require("chai");
const { BN } = require("bn.js");
const { ethers, upgrades } = require("hardhat");

const zeroAddr = "0x0000000000000000000000000000000000000000";
let mrtr, owner1, owner2, owner3;
const _owners = [];


describe("Factory Test", function () {
    before("Setup", async () => {
        signers = await ethers.getSigners();
        owner1 = signers[0];
        owner2 = signers[1];
        owner3 = signers[2];
        
        const Factory = await ethers.getContractFactory("Factory");
        const MrtrSafe = await ethers.getContractFactory("MrtrSafe");
        const beacon = await upgrades.deployBeacon(MrtrSafe);
        const instance = await upgrades.deployBeaconProxy(beacon, MrtrSafe, [_owners, _minApprovals], {initializer: "__MrtrSafe_init", unsafeAllow: "delegatecall"})

    })
})

