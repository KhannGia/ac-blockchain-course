# Bài thực hành – Hàm nâng cao: xử lý ETH, require & Events

## 🎯 Mục tiêu
- Dùng `payable` để nhận ETH; đọc `msg.value`, `msg.sender`.
- Kiểm tra điều kiện bằng `require`.
- Khai báo & phát **Events**.
- Viết & dùng **modifier** (`onlyOwner`).
- Phân biệt `view` và hàm thường.

## 📄 Đề bài
Viết smart contract tên `Bank` — một "heo đất chung" cho phép nhiều người gửi/rút ETH.

### Yêu cầu
1. Biến trạng thái:
   - `mapping(address => uint256) public balances` — số dư đã gửi của từng địa chỉ.
   - `address public owner` — gán trong `constructor` bằng `msg.sender`.
2. Hai event:
   - `event Deposited(address indexed user, uint256 amount);`
   - `event Withdrawn(address indexed user, uint256 amount);`
3. Một `modifier onlyOwner()` — chỉ cho phép `owner` gọi.
4. Hàm `deposit()` khai báo **`payable`**:
   - `require` số ETH gửi (`msg.value`) phải lớn hơn 0.
   - Cộng `msg.value` vào `balances[msg.sender]`.
   - Phát event `Deposited`.
5. Hàm `withdraw(uint256 _amount)`:
   - `require` `balances[msg.sender] >= _amount`.
   - **Trừ sổ trước** (`balances[msg.sender] -= _amount`), **chuyển ETH sau**.
   - Chuyển ETH: `(bool ok, ) = msg.sender.call{value: _amount}(""); require(ok, "...");`
   - Phát event `Withdrawn`.
6. Hàm `getMyBalance()` **`view`**: trả về `balances[msg.sender]`.
7. Hàm `getContractBalance()` **`view onlyOwner`**: trả về `address(this).balance`.

### Câu hỏi tư duy (trả lời bằng comment trong SM.sol)
> Vì sao ở hàm `withdraw` ta phải **trừ sổ (effects) TRƯỚC** rồi mới **chuyển ETH (interaction)**?
> Điều gì có thể xảy ra nếu làm ngược lại (chuyển tiền trước, trừ sổ sau)?

## 💡 Gợi ý triển khai
- Remix: chọn compiler `0.8.x`.
- Để test `deposit`: nhập số ETH vào ô **VALUE** (đổi đơn vị sang Ether) trên panel Deploy & Run trước khi bấm `deposit`.
- 1 ETH = 1_000_000_000_000_000_000 wei (10^18). `msg.value` tính bằng wei.
- `address(this)` = địa chỉ của chính contract.

## ✅ Tiêu chí hoàn thành
- [ ] Compile thành công với 0.8.x
- [ ] `deposit` nhận ETH và cộng đúng số dư, phát event
- [ ] `withdraw` chặn rút quá số dư, trừ sổ trước khi chuyển tiền, phát event
- [ ] `getMyBalance` trả về đúng số dư người gọi
- [ ] `getContractBalance` chỉ owner gọi được
- [ ] Đã trả lời câu hỏi tư duy trong comment
