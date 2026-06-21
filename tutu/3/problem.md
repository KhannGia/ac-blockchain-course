# Bài thực hành – Tấn công & Vá lỗ hổng Reentrancy

> ⚠️ Mục đích GIÁO DỤC. Chỉ chạy trên Remix VM với contract do chính bạn deploy.
> Không bao giờ dùng để tấn công contract của người khác.

## 🎯 Mục tiêu
- Hiểu **reentrancy** bằng cách tự khai thác nó.
- Viết một contract tấn công sử dụng `receive()` để gọi đệ quy.
- Vá lỗ hổng bằng **Checks-Effects-Interactions** và `nonReentrant`.

## 📄 Đề bài

Trong file `SM.sol` đã có sẵn contract `VulnerableBank` **cố tình viết sai** (chuyển tiền trước, trừ sổ sau).

### Phần 1 — Viết contract `Attacker`
Khai thác `VulnerableBank` để rút nhiều tiền hơn số bạn đã gửi.

1. Biến: `VulnerableBank public bank;` và `address public owner;`
2. `constructor(address _bankAddress)`: lưu địa chỉ bank và `owner = msg.sender`.
3. Hàm `attack()` khai báo **`payable`**:
   - `require(msg.value > 0)`.
   - Gọi `bank.deposit{value: msg.value}()` để nạp tiền mồi.
   - Gọi `bank.withdraw(msg.value)` để châm ngòi.
4. Hàm `receive() external payable`:
   - Nếu `address(bank).balance >= msg.value` (bank còn đủ tiền) → gọi lại `bank.withdraw(msg.value)`.
   - *(Dùng `msg.value` ở đây = số ETH bank vừa gửi tới trong lần gọi này.)*
5. Hàm `collect()`: chuyển toàn bộ ETH của contract Attacker về cho `owner`.

### Phần 2 — Vá lỗ hổng
Tạo contract `SafeBank` (copy từ `VulnerableBank`) và sửa cho an toàn:
- Áp dụng đúng thứ tự **Checks → Effects → Interactions** trong `withdraw`.
- Thêm `modifier nonReentrant` và gắn vào `withdraw`.
- Chứng minh: deploy lại `Attacker` trỏ vào `SafeBank` → `attack()` phải **thất bại/không rút thừa được**.

### Câu hỏi tư duy (comment trong SM.sol)
> 1. Trong contract `Attacker`, vì sao lại đặt logic gọi lại `withdraw` trong `receive()` mà không phải hàm thường?
> 2. Giữa hai cách vá (CEI và nonReentrant), cách nào ngăn được gốc rễ vấn đề? Có nên dùng cả hai không?

## 💡 Gợi ý kịch bản test trên Remix (VM)
1. Deploy `VulnerableBank`.
2. Dùng 2-3 tài khoản khác nhau gọi `deposit` (mỗi tài khoản nạp ~5 ETH) để "mồi" tiền cho bank.
3. Deploy `Attacker` với địa chỉ của `VulnerableBank`.
4. Gọi `attack()` với VALUE = 1 ETH.
5. Kiểm tra `bank.getContractBalance()` → gần như bằng 0.
6. Gọi `collect()` → ETH cướp được chuyển về ví hacker.
7. Lặp lại quy trình với `SafeBank` → `attack()` phải revert.

## ✅ Tiêu chí hoàn thành
- [ ] `Attacker` rút được nhiều ETH hơn số đã nạp từ `VulnerableBank`
- [ ] `receive()` gọi lại `withdraw` có điều kiện dừng (không lặp vô hạn gây hết gas vô nghĩa)
- [ ] `collect()` chuyển ETH về owner
- [ ] `SafeBank` chống được chính cuộc tấn công đó (CEI + nonReentrant)
- [ ] Trả lời 2 câu hỏi tư duy
