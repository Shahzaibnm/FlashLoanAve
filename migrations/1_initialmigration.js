
const FlashLoan = artifacts.require("FlashLoan");

module.exports = function(deployer) {

  deployer.deploy(FlashLoan,"0xc4dCB5126a3AfEd129BC3668Ea19285A9f56D15D");
};