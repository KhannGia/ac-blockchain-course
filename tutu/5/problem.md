# Bài 4.3 – Mint, Burn & Ownable

## 🎯 Mục tiêu
- Áp dụng mẫu **Ownable** (phân quyền chủ sở hữu).
- Cài đặt `mint` (tạo token, chỉ owner) và `burn` (đốt token).
- Hiểu quan hệ đối xứng mint ↔ burn qua `totalSupply` và `address(0)`.
- (Tùy chọn) Giới hạn tổng cung tối đa (capped supply).

## 📄 Đề bài
Mở rộng `MyToken` (ERC-20 ở bài 4) thêm các tính năng quản trị. File `SM.sol` đã dựng sẵn ERC-20 hoàn chỉnh; bạn chỉ cần thêm phần mới ở các TODO.

### Yêu cầu
1. **Ownable**
   - Thêm biến `address public owner`.
   - Gán `owner = msg.sender` trong constructor.
   - Thêm `modifier onlyOwner()`.
   - Thêm hàm `transferOwnership(address _newOwner) public onlyOwner` (require `_newOwner != address(0)`).
2. **mint**
   - `mint(address _to, uint256 _amount) public onlyOwner`.
   - require `_to != address(0)`.
   - Tăng `totalSupply`, cộng `balanceOf[_to]`.
   - emit `Transfer(address(0), _to, _amount)`.
3. **burn**
   - `burn(uint256 _amount) public` (KHÔNG cần onlyOwner — ai cũng đốt token của chính mình).
   - require đủ số dư.
   - Trừ `balanceOf[msg.sender]`, giảm `totalSupply`.
   - emit `Transfer(msg.sender, address(0), _amount)`.

### (Tùy chọn — nâng cao) Capped supply
- Thêm `uint256 public immutable maxSupply;` nhận giá trị trong constructor.
- Trong `mint`: require `totalSupply + _amount <= maxSupply`.

### Câu hỏi tư duy (comment trong SM.sol)
> 1. Vì sao `mint` cần `onlyOwner` còn `burn` thì không?
> 2. Điều gì xảy ra với `totalSupply` sau một chuỗi: mint 100 → transfer 30 → burn 20? (giả sử bắt đầu từ 0)
> 3. Vì sao nên dùng `immutable` cho `maxSupply` thay vì biến storage thường?

## 💡 Gợi ý test trên Remix
1. Deploy, kiểm tra `owner` = tài khoản deploy.
2. Owner gọi `mint(account2, 500e18)` → kiểm tra `totalSupply` và `balanceOf[account2]` tăng.
3. **Đổi sang account khác** gọi `mint(...)` → phải **revert** (không phải owner).
4. Account2 gọi `burn(100e18)` → `totalSupply` và số dư account2 giảm.
5. (Nếu làm capped) mint vượt `maxSupply` → revert.

## ✅ Tiêu chí hoàn thành
- [ ] `owner` set trong constructor + `onlyOwner` + `transferOwnership`
- [ ] `mint` chỉ owner gọi được, tăng cung đúng, emit từ address(0)
- [ ] `burn` đốt token của người gọi, giảm cung đúng, emit về address(0)
- [ ] (Tùy chọn) capped supply chặn mint vượt trần
- [ ] Trả lời 3 câu hỏi tư duy
