# Lý thuyết – Hàm nâng cao: xử lý ETH, require & Events

## 1. State Mutability — tính chất của hàm
| Từ khóa | Đọc state | Ghi state | Nhận ETH | Gọi từ ngoài tốn gas |
|---|---|---|---|---|
| `pure` | ❌ | ❌ | ❌ | Không |
| `view` | ✅ | ❌ | ❌ | Không |
| *(none)* | ✅ | ✅ | ❌ | Có |
| `payable` | ✅ | ✅ | ✅ | Có |

> Quên `payable` mà gửi ETH vào → giao dịch revert.

## 2. Biến toàn cục hay dùng
| Biến | Ý nghĩa |
|---|---|
| `msg.sender` | địa chỉ người gọi hàm |
| `msg.value` | số **wei** ETH gửi kèm (1 ETH = 10^18 wei) |
| `address(this).balance` | số dư ETH của chính contract |
| `block.timestamp` | thời gian block hiện tại (giây) |
| `block.number` | số thứ tự block |

## 3. require — kiểm tra điều kiện
```solidity
require(điều_kiện, "thông báo lỗi");
```
- Điều kiện sai → **revert toàn bộ giao dịch** (hoàn tác mọi thay đổi), trả lại gas chưa dùng.
- Dùng cho: kiểm tra quyền, số dư, input hợp lệ.

## 4. Gửi ETH ra khỏi contract
```solidity
(bool ok, ) = msg.sender.call{value: amount}("");
require(ok, "Transfer failed");
```
- `call` là cách chuyển ETH được khuyến nghị hiện nay. Luôn `require` kiểm tra kết quả.
- `{value: ...}` đặt TRƯỚC dấu ngoặc tham số.

## 5. Events — log cho off-chain
```solidity
event Deposited(address indexed user, uint256 amount);  // khai báo
emit Deposited(msg.sender, msg.value);                  // phát log
```
- `indexed` → cho phép lọc/tìm theo trường đó (tối đa 3 indexed).
- Rẻ hơn lưu storage rất nhiều; frontend/Etherscan dùng để theo dõi hoạt động.
- Không đọc được từ contract khác (chỉ off-chain).

## 6. modifier — tái sử dụng điều kiện
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;   // <- thân hàm được chèn vào đây
}
function withdrawAll() public onlyOwner { ... }
```
- `_;` là chỗ Solidity "dán" toàn bộ code của hàm vào. Code trước `_;` chạy trước, sau `_;` chạy sau.

## 7. Đơn vị tiền
| Đơn vị | Giá trị |
|---|---|
| wei | nhỏ nhất |
| gwei | 10^9 wei (hay dùng cho gas) |
| ether | 10^18 wei |

`msg.value`, `address(this).balance` đều tính bằng **wei**.

## Nguồn tham khảo
- Solidity Docs — State Mutability (`view`/`pure`/`payable`): https://docs.soliditylang.org/en/latest/contracts.html#state-mutability
- Solidity Docs — Units & globally available variables (`msg`, `block`...): https://docs.soliditylang.org/en/latest/units-and-global-variables.html
- Solidity Docs — Error handling (`require`/`revert`/`assert`): https://docs.soliditylang.org/en/latest/control-structures.html#error-handling-assert-require-revert-and-exceptions
- Solidity Docs — Events: https://docs.soliditylang.org/en/latest/contracts.html#events
- Solidity Docs — Function Modifiers: https://docs.soliditylang.org/en/latest/contracts.html#function-modifiers
- Solidity by Example — Payable: https://solidity-by-example.org/payable/
- Solidity by Example — Sending Ether (`transfer`/`send`/`call`): https://solidity-by-example.org/sending-ether/
- Solidity by Example — Events: https://solidity-by-example.org/events/
- ethereum.org — Đơn vị & giá trị (wei/gwei/ether): https://ethereum.org/en/developers/docs/intro-to-ether/
