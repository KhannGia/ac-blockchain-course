# Lý thuyết – ERC-20 Token

## 1. ERC-20 là gì?
Bộ **quy tắc chuẩn** để một token được mọi ví/sàn/contract khác hiểu và tương tác.
Cứ cài đủ giao diện chuẩn → MetaMask, Uniswap... tự nhận ra token của bạn.

## 2. Giao diện bắt buộc: 6 hàm + 2 event
```solidity
// đọc thông tin
function totalSupply() returns (uint256);
function balanceOf(address account) returns (uint256);
function allowance(address owner, address spender) returns (uint256);
// chuyển token
function transfer(address to, uint256 amount) returns (bool);
function transferFrom(address from, address to, uint256 amount) returns (bool);
function approve(address spender, uint256 amount) returns (bool);
// events
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
```

## 3. State cần có
```solidity
string  public name;        // "My Token"
string  public symbol;      // "MTK"
uint8   public decimals;    // thường 18
uint256 public totalSupply;
mapping(address => uint256) public balanceOf;                     // số dư
mapping(address => mapping(address => uint256)) public allowance; // ủy quyền (2 tầng)
```
> `balanceOf`/`allowance` để `public` → Solidity tự sinh getter, KHÔNG viết tay hàm cùng tên (sẽ trùng → lỗi).

## 4. decimals — vì sao thường là 18
EVM không có số thập phân. `decimals = 18` nghĩa là 1 token = 10^18 đơn vị nhỏ nhất.
- "1000 token" lưu là `1000 * 10^18`.
- Frontend chia lại cho 10^18 để hiển thị.

## 5. ⭐ Cơ chế approve / transferFrom (nền tảng DeFi)
Bạn KHÔNG tự gửi token cho Uniswap — bạn **cho phép** nó tự lấy.
```
Bước 1: BẠN approve(Uniswap, 100)
        → allowance[bạn][Uniswap] = 100

Bước 2: UNISWAP transferFrom(bạn, pool, 100)
        → check allowance[bạn][Uniswap] >= 100 ✅
        → chuyển token: balanceOf[bạn] -= 100; balanceOf[pool] += 100
        → trừ hạn mức: allowance[bạn][Uniswap] -= 100
```

| Hàm | Ai gọi | Tác dụng |
|---|---|---|
| `transfer(to, x)` | chính chủ token | gửi token của mình |
| `approve(spender, x)` | chính chủ token | cấp hạn mức cho `spender` |
| `transferFrom(from, to, x)` | **spender** (bên thứ 3) | lấy token từ `from` (trong hạn mức) |

`allowance[A][B]` đọc: "**A** cho phép **B** tiêu tối đa bao nhiêu token của A".

## 6. Quy ước mint/burn qua event Transfer
- **Mint** (tạo token): `emit Transfer(address(0), to, amount)` — coi như token "đến từ" địa chỉ 0.
- **Burn** (đốt token): `emit Transfer(from, address(0), amount)` — token "đi về" địa chỉ 0.
- Constructor cấp cung ban đầu = một lần mint, nên emit từ `address(0)`.

## 7. Bẫy bảo mật của approve (race condition)
Đổi allowance từ giá trị khác 0 sang giá trị khác 0 có thể bị "tiêu kép" nếu spender nhanh tay.
- Cách an toàn: approve về 0 trước, rồi mới set giá trị mới; hoặc dùng `increaseAllowance`/`decreaseAllowance` (OpenZeppelin).

## 8. Thực tế: OpenZeppelin
Trong dự án thật, ít ai viết ERC-20 tay — dùng thư viện đã kiểm toán:
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract MyToken is ERC20 {
    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, 1000 * 10**decimals());
    }
}
```
Viết tay (bài này) để **hiểu bên trong**; dùng OpenZeppelin khi **làm thật** cho an toàn.

## Nguồn tham khảo
- EIP-20 — ERC-20 Token Standard (bản gốc): https://eips.ethereum.org/EIPS/eip-20
- ethereum.org — ERC-20 Token Standard: https://ethereum.org/en/developers/docs/standards/tokens/erc-20/
- OpenZeppelin — ERC20 (hướng dẫn): https://docs.openzeppelin.com/contracts/5.x/erc20
- OpenZeppelin — ERC20 API: https://docs.openzeppelin.com/contracts/5.x/api/token/erc20
- Solidity by Example — ERC20: https://solidity-by-example.org/app/erc20/
- Bẫy approve race condition (mô tả trong EIP-20, mục "approve"): https://eips.ethereum.org/EIPS/eip-20#approve
- Solidity Docs — Contracts (interface, kế thừa, import): https://docs.soliditylang.org/en/latest/contracts.html
