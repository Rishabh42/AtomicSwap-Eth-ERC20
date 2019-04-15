const atomicSwap = artifacts.require("./AtomicSwap.sol");
const testToken = artifacts.require("./testToken.sol");

contract('AtomicSwap', (accounts) => {
  const alice = accounts[1];
  const bob = accounts[2];
  const sID_swap = "0x41f6c6fbdfd4184172d61b390922270db087519137c43d3052fbad33876964f7";
  const sID_expiry = "0xH956332806hh7nn77055e8535300c42b1423cac321938e7fe30b252abf8fe74";

  const etherValue = 50000;
  const erc20Value = 100000;

  it("Alice deposits her ether", async () => {
    const swap = await atomicSwap.deployed();
    const token = await testToken.deployed();
    await swap.open(sID_swap, erc20Value, bob, token.address, {from:alice, value: etherValue});
  });

});
