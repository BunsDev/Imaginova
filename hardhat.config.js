require("@nomicfoundation/hardhat-toolbox");
const fs = require("fs");
const privateKey = fs.readFileSync("secrete.txt").toString();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {
      chainId: 4202,
    },
    sepolia: {
      url: "https://rpc.sepolia-api.lisk.com",
      accounts: [privateKey],
      gasPrice: 1000000000,
    },
    BitTorrent: {
      url: "https://pre-rpc.bt.io/",
      accounts: [privateKey],
      gasPrice: 1000000000,
    },
    zkEVMCardonaTestnet: {
      url: "https://polygon-zkevm-cardona.blockpi.network/v1/rpc/public",
      accounts: [privateKey],
    },
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [privateKey],
    },
    matic: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/2bGIFu-iEnl9RvAOTe1ddZI2gBnuYQGS",
      accounts: [privateKey],
    },
  },
  solidity: "0.8.24",
  allowUnlimitedContractSize: true,
  throwOnTransactionFailures: true,
  throwOnCallFailures: true,
};
// npx hardhat ignition deploy ./ignition/modules/Lock.js --network BitTorrent
// yarn add "@nomicfoundation/hardhat-chai-matchers@^2.0.0" "@nomicfoundation/hardhat-ethers@^3.0.0" "@nomicfoundation/hardhat-ignition-ethers@^0.15.0" "@nomicfoundation/hardhat-network-helpers@^1.0.0" "@nomicfoundation/hardhat-verify@^2.0.0" "@typechain/ethers-v6@^0.5.0" "@typechain/hardhat@^9.0.0" "@types/chai@^4.2.0" "@types/mocha@>=9.1.0" "chai@^4.2.0" "hardhat-gas-reporter@^1.0.8" "solidity-coverage@^0.8.1" "typechain@^8.3.0"
