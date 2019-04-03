pragma solidity >=0.4.22 <0.6.0;

contract AtomicSwap {

    struct Swap {
        uint256 sTimestamp;
        uint256 refundTime;
        uint256 initiatorValue;
        uint256 participantValue;
        address initiator;
        address participant;
        bytes32 key;
        bytes32 hashedkey;
        bool emptied;
    }

    mapping(bytes32 => Swap) public swaps;

    modifier isInitiator(bytes32 _hashedKey) {
	    require(msg.sender == swaps[_hashedKey].initiator);
	    _;
	}

	modifier isRedeemable(bytes32 _hashedkey, bytes memory _key) {
	    require(keccak256(_key) == _hashedkey);
		require(block.timestamp < swaps[_hashedkey].sTimestamp + swaps[_hashedkey].refundTime);
	    require(swaps[_hashedkey].emptied == false);
	    _;
	}

}
