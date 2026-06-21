// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Welcome {
    // Biến greeting public => Solidity tự sinh getter greeting()
    string public greeting;

    // Constructor nhận giá trị khởi tạo cho greeting khi deploy
    constructor(string memory initialGreeting) {
        greeting = initialGreeting;
    }

    // Hàm trả về greeting hiện tại
    function getGreeting() public view returns (string memory) {
        return greeting;
    }

    // Trả về greeting kèm địa chỉ người gọi (msg.sender)
    function getGreetingWithSender() public view returns (string memory, address) {
        return (greeting, msg.sender);
    }
}
