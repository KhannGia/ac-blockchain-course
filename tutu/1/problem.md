# Bài thực hành – Kiểu dữ liệu & Vùng nhớ (Data Location)

## 🎯 Mục tiêu
- Phân biệt **value types** và **reference types**.
- Hiểu và dùng đúng 3 vùng nhớ: **storage / memory / calldata**.
- Làm việc với `struct` và `mapping`.

## 📄 Đề bài
Viết một smart contract tên là `Profile` để quản lý hồ sơ cá nhân.

### Yêu cầu
1. Khai báo một `struct User` gồm các trường:
   - `string name`
   - `uint256 age`
   - `address wallet`
   - `bool isActive`
2. Một biến `mapping(address => User) public users` lưu hồ sơ theo địa chỉ.
3. Hàm `register(string calldata _name, uint256 _age)`:
   - Tạo hồ sơ cho `msg.sender`, với `wallet = msg.sender` và `isActive = true`.
   - Chú ý: `_name` được nhận qua **`calldata`**.
4. Hàm `updateName(string memory _newName)`:
   - Sửa lại `name` trong hồ sơ của người gọi.
   - So sánh: ở đây dùng **`memory`** — hãy nghĩ xem có đổi sang `calldata` được không và vì sao.
5. Hàm `getUser(address _addr)` trả về đầy đủ 4 trường thông tin của một hồ sơ.

### Câu hỏi tư duy (trả lời bằng comment trong file SM.sol)
> Trong hàm `updateName`, nếu bạn viết:
> ```solidity
> User storage u = users[msg.sender];
> u.name = _newName;
> ```
> thì thay đổi có được **ghi vĩnh viễn vào blockchain** không?
> Còn nếu dùng `User memory u = users[msg.sender];` rồi sửa `u.name` thì sao?

## 💡 Gợi ý triển khai
- Dán vào Remix tại: https://remix.ethereum.org
- Chọn compiler `0.8.x`
- Để hàm `getUser` trả về được nhiều giá trị, khai báo vùng nhớ cho biến trả về (`memory`).
- `mapping` chỉ tồn tại trong `storage` — không cần (và không thể) đặt nó ở `memory`.

## ✅ Tiêu chí hoàn thành
- [ ] Contract compile thành công với compiler 0.8.x
- [ ] `register` tạo được hồ sơ mới cho người gọi
- [ ] `updateName` đổi được tên hồ sơ của người gọi
- [ ] `getUser` trả về đúng 4 trường
- [ ] Đã trả lời câu hỏi tư duy trong comment
