const {  ethers } = require("hardhat");

async function attach(name, address) {
    const Factory = await ethers.getContractFactory(name);
    return Factory.attach(address);
}

async function main() {
    const [owners, manager] = await ethers.getSigners();

    const registry = (await attach("MrtrSafe")).connect(owners);
    const { chainId } = await ethers.provider.getNetwork();
    const symbol = AND || BRCK;
    const signatures = await owners._signTypedData(

        {
            name: "Name",
            version: "1.0.0",
            chainId,
            verifyingContract: registry.address,
        },
        {
            Withdraw: [
                {name: "symbol", type: "string"},
                {name: "amount", type: "uint256"},
                {name: "nonce", type: "uint256"},
            ],
        },

        {symbol, amount, nonce},
    );
    console.log({ registry: registry.address, symbol, amount});
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });