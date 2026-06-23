# Bài 4 – Xây dựng ERC-20 Token từ số 0

## 🎯 Mục tiêu
- Hiểu chuẩn ERC-20: 6 hàm + 2 event bắt buộc.
- Tự cài đặt `transfer`, `approve`, `transferFrom`, `allowance`.
- Nắm cơ chế ủy quyền (`approve` / `transferFrom`) — nền tảng của DeFi.
- Làm việc với `mapping` lồng nhau.

## 📄 Đề bài
Viết contract `MyToken` cài đặt đầy đủ chuẩn ERC-20 (KHÔNG dùng thư viện ngoài).

### Yêu cầu state
1. `string public name;`
2. `string public symbol;`
3. `uint8 public decimals;`        // thường = 18
4. `uint256 public totalSupply;`
5. `mapping(address => uint256) public balanceOf;`
6. `mapping(address => mapping(address => uint256)) public allowance;`

### Events
- `event Transfer(address indexed from, address indexed to, uint256 value);`
- `event Approval(address indexed owner, address indexed spender, uint256 value);`

### Constructor
- `constructor(string memory _name, string memory _symbol, uint256 _initialSupply)`
- Gán name, symbol, `decimals = 18`.
- `totalSupply = _initialSupply`.
- Cấp toàn bộ cung ban đầu cho người deploy: `balanceOf[msg.sender] = _initialSupply`.
- Phát event `Transfer(address(0), msg.sender, _initialSupply)` (quy ước: mint = chuyển từ address(0)).

### Hàm cần viết
1. `transfer(address _to, uint256 _amount) public returns (bool)`
   - require `_to != address(0)`.
   - require đủ số dư.
   - trừ `balanceOf[msg.sender]`, cộng `balanceOf[_to]`.
   - emit `Transfer`, return true.
2. `approve(address _spender, uint256 _amount) public returns (bool)`
   - gán `allowance[msg.sender][_spender] = _amount`.
   - emit `Approval`, return true.
3. `transferFrom(address _from, address _to, uint256 _amount) public returns (bool)`
   - require `_to != address(0)`.
   - require `balanceOf[_from] >= _amount`.
   - require `allowance[_from][msg.sender] >= _amount`.
   - chuyển token: trừ `_from`, cộng `_to`.
   - trừ hạn mức: `allowance[_from][msg.sender] -= _amount`.
   - emit `Transfer`, return true.

*(Lưu ý: `balanceOf` và `allowance` khai báo `public` nên Solidity tự sinh getter — không cần viết tay `balanceOf()` / `allowance()`.)*

### Câu hỏi tư duy (comment trong SM.sol)
> 1. Vì sao cần `transferFrom` + `approve` thay vì chỉ dùng `transfer`? Cho một ví dụ thực tế.
> 2. `allowance[A][B]` đọc nghĩa là gì? Ai là người tiêu, ai là chủ token?
> 3. Vì sao constructor phát `Transfer(address(0), ...)` mà không phải từ một địa chỉ thật?

## 💡 Gợi ý test trên Remix
1. Deploy với `_name="My Token"`, `_symbol="MTK"`, `_initialSupply=1000000000000000000000` (1000 token, 18 decimals).
2. Account 1 gọi `transfer(account2, ...)` → kiểm tra `balanceOf`.
3. Account 1 gọi `approve(account3, 100...)`, rồi **chuyển sang Account 3** gọi `transferFrom(account1, account4, 100...)` → quan sát allowance giảm.

## ✅ Tiêu chí hoàn thành
- [ ] Đủ 6 state + 2 event chuẩn ERC-20
- [ ] Constructor cấp cung & emit Transfer từ address(0)
- [ ] `transfer` chặn địa chỉ 0 và thiếu số dư
- [ ] `approve` set đúng allowance + emit
- [ ] `transferFrom` kiểm tra cả số dư lẫn hạn mức, trừ allowance
- [ ] Trả lời 3 câu hỏi tư duy
