pragma solidity ^0.4.18;

import "./ERC20.sol";

contract AtomicSwap {

  struct Swap {
    address ethHolder;
    uint256 erc20V;
    address erc20Holder;
    address erc20ContractAddress;
    uint256 value;
  }

  enum States {
    OPEN, CLOSED, EXPIRED
  }

  modifier openSwaps(bytes32 sID) {
    require (swapStates[sID] == States.OPEN);
    _;
  }

  event Open(bytes32 sID, address _closeTrader);
  event Close(bytes32 sID);
  event Expire(bytes32 sID);

  mapping (bytes32 => Swap) private swaps;
  mapping (bytes32 => States) private swapStates;

  function open(bytes32 sID, uint256 _erc20V, address _erc20Holder, address _erc20ContractAddress) public payable {

    Swap memory swap = Swap({
      ethHolder: msg.sender,
      value: msg.value,
      erc20V: _erc20V,
      erc20Holder: _erc20Holder,
      erc20ContractAddress: _erc20ContractAddress
    });
    swaps[sID] = swap;
    swapStates[sID] = States.OPEN;

    Open(sID, _erc20Holder);
  }

  function close(bytes32 sID) public openSwaps(sID) {

    Swap memory swap = swaps[sID];
    swapStates[sID] = States.CLOSED;

    ERC20 erc20Contract = ERC20(swap.erc20ContractAddress);
    require(swap.erc20V <= erc20Contract.allowance(swap.erc20Holder, address(this)));
    require(erc20Contract.transferFrom(swap.erc20Holder, swap.ethHolder, swap.erc20V));

    swap.erc20Holder.transfer(swap.value);

    Close(sID);
  }

  function expire(bytes32 sID) public openSwaps(sID) {

    Swap memory swap = swaps[sID];
    swapStates[sID] = States.EXPIRED;

    swap.ethHolder.transfer(swap.value);
    Expire(sID);
  }

}
