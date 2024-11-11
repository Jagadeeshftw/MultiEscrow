// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MultiEscrow {
    
    event Withdraw(address from, address to, uint256 amount);
    event Allocation(uint256 allocation1, uint256 allocation2, uint256 allocation3);
    event Blacklist(address user);

    address private owner;
    uint256 private depositedAmount;
    mapping(address => uint256) balances;
    mapping(address => bool) blacklist;

    constructor(address _owner) payable {
        owner = _owner;
        depositedAmount = msg.value;
    }

    receive() external payable {
        depositedAmount += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(amount <= balances[msg.sender]);
        require(!blacklist[msg.sender]);

        balances[msg.sender] -= amount;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent);

        emit Withdraw(address(this), msg.sender, amount);
    }
    function blacklistt(address user) external {
        require(msg.sender == owner);
        blacklist[user] = true;
        emit Blacklist(user);
    }

    function customDistribute(uint[3] memory amount, bool custom, address jack, address jill, address eve) public {
        require(msg.sender == owner);
        if (custom) {
            require(amount[0] + amount[1] + amount[2] <= depositedAmount);
            balances[jack] = amount[0];
            balances[jill] = amount[1];
            balances[eve] = amount[2];
        } else {
            uint256 amounts = depositedAmount / 3;
            balances[jack] = amounts;
            balances[jill] = amounts;
            balances[eve] = amounts;
        }
        emit Allocation(balances[jack], balances[jill], balances[eve]);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function isBlacklisted() external view returns (bool) {
        return blacklist[msg.sender];
    }
}
