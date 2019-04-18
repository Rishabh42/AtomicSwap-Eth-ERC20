pragma solidity >=0.4.22 <0.6.0;

import "./ERC20.sol";

contract AtomicSwap {

  struct Swap {
    address payable initiatorEth;
    uint256 erc20V;
    address payable participantERC20;
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

  function open(bytes32 sID, uint256 _erc20V, address payable _participantERC20, address payable _erc20ContractAddress) public payable {

    Swap memory swap = Swap({
      initiatorEth: msg.sender,
      value: msg.value,
      erc20V: _erc20V,
      participantERC20: _participantERC20,
      erc20ContractAddress: _erc20ContractAddress
    });
    swaps[sID] = swap;
    swapStates[sID] = States.OPEN;

   emit Open(sID, _participantERC20);
  }

  function close(bytes32 sID) public openSwaps(sID) {

    Swap memory swap = swaps[sID];
    swapStates[sID] = States.CLOSED;

    ERC20 erc20Contract = ERC20(swap.erc20ContractAddress);
    require(swap.erc20V <= erc20Contract.allowance(swap.participantERC20, address(this)));
    erc20Contract.transferFrom(swap.participantERC20, swap.initiatorEth, swap.erc20V);

    swap.participantERC20.transfer(swap.value);

    emit Close(sID);
  }

  function expire(bytes32 sID) public openSwaps(sID) {

    Swap memory swap = swaps[sID];
    swapStates[sID] = States.EXPIRED;

    swap.initiatorEth.transfer(swap.value);
    emit Expire(sID);
  }

}
