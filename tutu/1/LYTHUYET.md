# Lý thuyết – Kiểu dữ liệu & Vùng nhớ (Data Location)

## 1. Hai nhóm kiểu dữ liệu

### A. Value types (kiểu giá trị) — copy giá trị
Khi gán/truyền sẽ được **sao chép**, sửa bản này không ảnh hưởng bản kia.

| Kiểu | Ví dụ | Ghi chú |
|---|---|---|
| `bool` | `true / false` | |
| `uint8` … `uint256` | `uint256 x = 10;` | số nguyên không âm; `uint` = `uint256` |
| `int8` … `int256` | `int256 y = -5;` | số nguyên có dấu |
| `address` | `0xAbc...` | địa chỉ ví/contract |
| `address payable` | | địa chỉ nhận được ETH (`.transfer`) |
| `bytes1` … `bytes32` | `bytes32 h` | mảng byte cố định |
| `enum` | `enum State { On, Off }` | tập hằng có tên |

### B. Reference types (kiểu tham chiếu) — trỏ tới dữ liệu
Dữ liệu lớn/độ dài thay đổi. **Bắt buộc khai báo vùng nhớ.**

| Kiểu | Ví dụ |
|---|---|
| `string` | `string memory name` |
| `bytes` | mảng byte động |
| Mảng | `uint256[]`, `uint256[5]` |
| `struct` | nhóm nhiều field |
| `mapping` | chỉ tồn tại trong `storage` |

## 2. Ba vùng nhớ (Data Location)

| Vùng | Tồn tại | Sửa được? | Gas | Dùng khi |
|---|---|---|---|---|
| `storage` | Vĩnh viễn trên blockchain | ✅ | Đắt nhất (~20.000 ghi) | biến trạng thái |
| `memory` | Tạm, mất khi hàm xong | ✅ | Rẻ | biến tạm trong hàm |
| `calldata` | Tạm, **chỉ đọc** | ❌ | Rẻ nhất | tham số hàm |

### Quy tắc nhớ
1. Biến trạng thái (ngoài hàm) → luôn `storage`.
2. Tham số/biến cục bộ kiểu tham chiếu → **phải** ghi `memory`/`calldata`.
3. Kiểu giá trị cục bộ (`uint`, `bool`...) → nằm trên stack, không cần ghi vùng nhớ.
4. `mapping` → chỉ sống trong `storage`.

## 3. Bẫy: storage là con trỏ, memory là bản sao
```solidity
uint256[] storage ref = numbers;  // ref TRỎ tới dữ liệu thật -> sửa = sửa luôn
uint256[] memory copy = numbers;  // copy là BẢN SAO -> sửa không ảnh hưởng gốc
```

## 4. struct & mapping
```solidity
struct User { string name; uint256 age; address wallet; bool isActive; }
mapping(address => User) public users;

users[msg.sender] = User(_name, _age, msg.sender, true);  // tạo
User storage u = users[msg.sender];                       // tham chiếu (sửa = ghi thật)
```
- `mapping` không có `.length`, không lặp được; key chưa gán trả về giá trị mặc định (0, address(0), false, "").

## 5. Vì sao quan trọng
- **Gas**: chọn sai vùng nhớ tốn gas vô ích (dùng `calldata` thay `memory` cho tham số → rẻ hơn).
- **Tính đúng đắn**: nhầm `storage`/`memory` → sửa nhầm hoặc không sửa được dữ liệu thật.

> Liên hệ: input data của giao dịch nằm trong vùng `calldata` — đó là lý do tham số `external` đọc từ calldata rẻ nhất.

## Nguồn tham khảo
- Solidity Docs — Types: https://docs.soliditylang.org/en/latest/types.html
- Solidity Docs — Data location & gán: https://docs.soliditylang.org/en/latest/types.html#data-location
- Solidity Docs — Mapping types: https://docs.soliditylang.org/en/latest/types.html#mapping-types
- Solidity Docs — Structs: https://docs.soliditylang.org/en/latest/types.html#structs
- Solidity by Example — Data Locations (storage/memory/calldata): https://solidity-by-example.org/data-locations/
- Solidity by Example — Mapping: https://solidity-by-example.org/mapping/
- ethereum.org — Anatomy of smart contracts: https://ethereum.org/en/developers/docs/smart-contracts/anatomy/
