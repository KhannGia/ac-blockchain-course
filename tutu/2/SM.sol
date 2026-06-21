// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    // TODO 1: mapping balances + address public owner
    mapping(address => uint256) public balances;
    address public owner;
    
    // TODO 2: event Deposited(...) và event Withdrawn(...)
    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    // TODO 3: constructor gán owner = msg.sender
    constructor() {
        owner = msg.sender;
    }
    // TODO 4: modifier onlyOwner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // TODO 5: hàm deposit() payable
    //         - require msg.value > 0
    //         - cộng vào balances[msg.sender]
    //         - emit Deposited
    function deposit() public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    // TODO 6: hàm withdraw(uint256 _amount)
    //         - require đủ số dư
    //         - trừ sổ TRƯỚC, chuyển ETH SAU (dùng call{value:...})
    //         - emit Withdrawn
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount; // Trừ sổ trước
        (bool success, ) = msg.sender.call{value: _amount}(""); // Chuyển ETH sau
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, _amount);
    }
    // TODO 7: hàm getMyBalance() view returns (uint256)
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    // TODO 8: hàm getContractBalance() view onlyOwner returns (uint256)
    function getContractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
    // Câu hỏi tư duy: vì sao trừ sổ trước, chuyển ETH sau?
    // => Trừ sổ trước để khi call trao quyền điều khiển cho người nhận, state đã được cập nhật. 
    // Nếu chuyển tiền trước, kẻ tấn công có thể gọi lại withdraw khi số dư cũ vẫn còn (reentrancy) và rút nhiều lần
}
