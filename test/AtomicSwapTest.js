const atomicSwap = artifacts.require("./AtomicSwap.sol");
const testToken = artifacts.require("./testToken.sol");

contract('AtomicSwap', (accounts) => {
  const alice = accounts[2];
  const bob = accounts[3];
  const sID_swap = "0x41f6c6fbdfd4184172d61b390922270db087519137c43d3052fbad33876964f7";
  const sID_expiry = "0x923dbb72ea83e6a61a4b042fdc0133de7461f42ac67fef11db850e984e618d8e";

  const etherValue = 50000;
  const erc20Value = 100000;

  it("Alice deposits her ether", async () => {
    const swap = await atomicSwap.deployed();
    const token = await testToken.deployed();
    await swap.open(sID_swap, erc20Value, bob, token.address, {from:alice, value: etherValue});
  });

  it("Bob closes the swap", async() => {
  const swap = await atomicSwap.deployed();
  const token = await testToken.deployed();
  await token.transfer(bob, 100000, {from: accounts[0]})
  await token.approve(swap.address, 100000, {from: bob});
  const allowance = await token.allowance(bob,swap.address);
  assert.equal(100000,allowance)
  await swap.close(sID_swap);
  })

  it("Alice withdraws after expiry", async () => {
    const swap = await atomicSwap.deployed();
    await swap.expire(sID_expiry);
  })

});
