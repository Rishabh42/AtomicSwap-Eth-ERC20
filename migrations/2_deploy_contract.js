var AtomicSwap = artifacts.require("./AtomicSwap.sol");
var testToken = artifacts.require("./testToken.sol");

module.exports = function(deployer){
  deployer.deploy(AtomicSwap);
  deployer.deploy(testToken);
};
