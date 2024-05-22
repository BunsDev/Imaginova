const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const { ethers } = require("ethers");

module.exports = buildModule("Imaginova", (m) => {
  const routerAddress = "0xb83E47C2bC239B3bf370bc41e1459A34b41238D0"; // Replace with actual router address
  const donID = ethers.utils.formatBytes32String("fun-avalanche-mainnet-1"); // Replace with actual DON ID
  const fee = ethers.utils.parseUnits("0.001", 18).toString(); // Example fee (0.1 LINK), converted to string to avoid BigNumber issues

  // const imaginova = m.contract("ImaginovaPayment", [routerAddress, donID, fee]);
  const imaginova = m.contract(
    "ImaginovaPayment",
    [routerAddress, donID, fee],
    {
      gasLimit: 3000000, // Increase the gas limit
    }
  );

  return { imaginova };
});
