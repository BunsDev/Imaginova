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
    imaginovafuji: {
      url: "http://127.0.0.1:9650/ext/bc/2r1bPth6o7ogEaJ4uFG9WKCxqggb8Gs5zDD18dTnpzkoGR8Qdv/rpc",
      gasPrice: 225000000000,
      chainId: 1999,
      accounts: [privateKey],
    },
  },
  solidity: "0.8.24",
  allowUnlimitedContractSize: true,
  throwOnTransactionFailures: true,
  throwOnCallFailures: true,
};
