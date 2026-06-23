# Lý thuyết – Reentrancy: Tấn công & Vá

> ⚠️ Nội dung GIÁO DỤC. Chỉ áp dụng trên Remix VM với contract do chính bạn deploy.

## 1. Reentrancy là gì?
Lỗ hổng xảy ra khi một hàm **gọi ra ngoài (external call) TRƯỚC khi cập nhật state**.
Lời gọi ra ngoài **trao quyền điều khiển** cho contract nhận — nó có thể **gọi lại** hàm ban đầu khi state còn "cũ" (chưa bị trừ) → rút nhiều lần.

## 2. Pattern Checks-Effects-Interactions (CEI)
Luôn viết hàm theo thứ tự:
```solidity
function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount); // 1. CHECKS      (kiểm tra)
    balances[msg.sender] -= _amount;          // 2. EFFECTS     (đổi state)
    (bool ok, ) = msg.sender.call{value:_amount}(""); // 3. INTERACTIONS
    require(ok);
}
```

### ❌ Sai (chuyển tiền trước, trừ sổ sau)
```
1. Hacker gọi withdraw(1 ETH)        — balances vẫn = 1 (chưa trừ)
2. Contract chuyển 1 ETH → kích hoạt receive() của hacker
3. receive() GỌI LẠI withdraw(1 ETH)
4. require kiểm tra: balances vẫn = 1 ✅ (chưa trừ) → tiếp tục rút
5. Lặp tới khi bank cạn tiền
```

### ✅ Đúng (trừ sổ trước)
```
1. Hacker gọi withdraw(1 ETH)
2. balances bị trừ về 0 NGAY        ← state mới đã ghi
3. Chuyển tiền → hacker gọi lại withdraw
4. require: balances = 0 → REVERT ❌  → cửa đã đóng
```

## 3. Contract tấn công hoạt động thế nào
```
Attacker.attack()
  └─ bank.deposit{1 ETH}()
  └─ bank.withdraw(1 ETH)
        └─ bank gửi ETH → kích hoạt Attacker.receive()
              └─ receive(): nếu bank còn tiền → bank.withdraw(1 ETH) lại  (đệ quy)
```
- Logic tấn công đặt trong `receive()` vì hàm này **tự động chạy** khi contract nhận ETH — đúng thời điểm `withdraw` chưa kịp trừ sổ.
- Phải có **điều kiện dừng** (`if bank còn tiền`) nếu không khi bank cạn, `withdraw` revert → kéo cả giao dịch revert → tấn công thất bại.

## 4. Hai lớp phòng thủ
| | CEI (trừ sổ trước) | nonReentrant (mutex lock) |
|---|---|---|
| Bản chất | Sửa **đúng gốc**: state không bao giờ stale khi gọi ra ngoài | **Tấm khiên**: chặn mọi lời gọi lồng nhau |
| Trị gốc? | ✅ Có | Chặn triệu chứng, rất chắc chắn |
| Điểm yếu | Dễ quên ở hàm phức tạp | Tốn thêm chút gas |

```solidity
bool private locked;
modifier nonReentrant() {
    require(!locked, "Reentrant call");
    locked = true;
    _;
    locked = false;
}
function withdraw(uint256 _amount) public nonReentrant { ... }
```

**Best practice: dùng CẢ HAI** — CEI làm chính, `nonReentrant` làm lưới an toàn.

## 5. Bài học lịch sử
- **The DAO hack (2016)**: bị rút ~60 triệu USD đúng bằng lỗ hổng reentrancy → dẫn tới hard fork chia Ethereum/Ethereum Classic.

## 6. Lưu ý gửi ETH
- `transfer` / `send`: giới hạn 2300 gas (chống reentrancy thụ động nhưng dễ hỏng với contract phức tạp).
- `call{value:}`: linh hoạt, được khuyến nghị, NHƯNG **phải** tự bảo vệ bằng CEI + nonReentrant.

## Nguồn tham khảo
- Solidity Docs — Security Considerations (Reentrancy, Checks-Effects-Interactions): https://docs.soliditylang.org/en/latest/security-considerations.html
- SWC-107 — Reentrancy: https://swcregistry.io/docs/SWC-107
- ConsenSys Smart Contract Best Practices — Reentrancy: https://consensys.github.io/smart-contract-best-practices/attacks/reentrancy/
- Solidity by Example — Re-Entrancy hack: https://solidity-by-example.org/hacks/re-entrancy/
- OpenZeppelin — ReentrancyGuard: https://docs.openzeppelin.com/contracts/5.x/api/utils#ReentrancyGuard
- ethereum.org — Smart contract security: https://ethereum.org/en/developers/docs/smart-contracts/security/
- Bối cảnh The DAO hack (2016): https://www.gemini.com/cryptopedia/the-dao-hack-makerdao
