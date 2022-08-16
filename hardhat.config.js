require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-gas-reporter");


module.exports = {
  networks: {
    mrtrTest: {
      url: `http://35.238.106.48:8545`,
      chainId: 1031,
      accounts: process.env.MRTR_PRIVATE_KEY,
      timeout: 20000,   
    },
  },
  gasReporter: {
    enabled: (process.env.COINMARKETCAP) ? true : false,
    //token: "BRCK", //we need a Mrtr API to report correctly 
    currency: "USD",  //I need coinMarketCap API to report in usd;
    gasPrice: 200,    //our gasPrice?
  },

  solidity: {
    version: "0.8.10",
    optimizer: {
      enabled: true,
      runs: 10000,
    }
  }
};