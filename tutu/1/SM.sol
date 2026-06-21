// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Profile {
    // TODO 1: Khai báo struct User { name, age, wallet, isActive }
    struct User {
        string name;
        uint256 age;
        address wallet;
        bool isActive;
    }
    // TODO 2: Khai báo mapping(address => User) public users
    mapping(address => User) public users;
    // TODO 3: Hàm register(string calldata _name, uint256 _age)
    //         - tạo hồ sơ cho msg.sender, isActive = true
    function register(string calldata _name, uint256 _age) public {
        users[msg.sender] = User(_name, _age, msg.sender, true);
    }
    // TODO 4: Hàm updateName(string memory _newName)
    //         - sửa name của hồ sơ người gọi
    function updateName(string memory _newName) public {
        users[msg.sender].name = _newName;
    }
    // TODO 5: Hàm getUser(address _addr) trả về 4 trường thông tin
    function getUser(address _addr) public view returns (string memory, uint256, address, bool) {
        User storage u = users[_addr];
        return (u.name, u.age, u.wallet, u.isActive);
    }
    // Câu hỏi tư duy: trả lời bằng comment ở đây
    // - Dùng `User storage u`  => có được ghi vĩnh viễn vào blockchain
    // - Dùng `User memory u`   => chỉ tồn tại trong bộ nhớ của hàm, không ghi vĩnh viễn
}
