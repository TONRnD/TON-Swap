pragma solidity ^0.5.0;

contract AtomicSwap {

    uint256 SafeTime = 3 hours; // atomic swap timeOut

    struct Swap {
        uint256 secret;
        // bytes32 secret;
        bytes32 secretHash;
        uint256 createdAt;
        uint256 balance;
    }

    // ETH Owner => BTC Owner => Swap
    mapping(address => mapping(address => Swap)) public swaps;


    constructor () public {
        // owner = msg.sender;
    }

    function deposit (address recipient, bytes32 _secretHash) public payable {
        require(swaps[msg.sender][recipient].balance == 0);
        require(_secretHash != 0x66687aadf862bd776c8fc18b8e9f8e20089714856ee233b3902a591d0d5f2925);

        swaps[msg.sender][recipient] = Swap(
            0,
            _secretHash,
            now,
            msg.value
        );
    }

    function refund(address recipient) public {
        Swap memory swap = swaps[msg.sender][recipient];

        require(swap.balance > 0);
        require(swap.createdAt + SafeTime < now);

        msg.sender.transfer(swap.balance);
    }

    function getBalance (address creator) public view returns (uint256) {
        return swaps[creator][msg.sender].balance;
    }

    function getHash (address creator) public view returns (bytes32) {
        return swaps[creator][msg.sender].secretHash;
    }

    function withdraw (address creator, uint256 _secret) public {
        Swap memory swap = swaps[creator][msg.sender];
        require(swap.secret == 0);
        bytes memory __secret = abi.encodePacked(_secret);
        require(sha256(__secret) == swap.secretHash);

        swap.secret = _secret;

        msg.sender.transfer(swap.balance);
    }
}
