require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-gas-reporter");

const { VALIDATOR_ADDRESS, VALIDATOR_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "mrtrTest",
  networks: {
    mrtrTest: {
      url: VALIDATOR_ADDRESS,
      chainId: 1031,
      accounts: [VALIDATOR_PRIVATE_KEY],
      timeout: 20000,
    },
  },
  gasReporter: {
    enabled: process.env.COINMARKETCAP ? true : false,
    //token: "BRCK", //we need a Mrtr API to report correctly
    currency: "USD", //I need coinMarketCap API to report in usd;
    gasPrice: 200, //our gasPrice?
  },
};
