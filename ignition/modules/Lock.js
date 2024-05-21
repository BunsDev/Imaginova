const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Imaginova", (m) => {
  const imaginova = m.contract("ImaginovaPayment");

  return { imaginova };
});
