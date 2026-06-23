// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    // TODO 1: state — name, symbol, decimals, totalSupply
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // TODO 2: mapping public balanceOf
    mapping(address => uint256) public balanceOf;
    // TODO 3: mapping lồng nhau public allowance  (owner => spender => amount)
    mapping(address => mapping(address => uint256)) public allowance;
    // TODO 4: event Transfer + event Approval
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // TODO 5: constructor(name, symbol, initialSupply)
    //         - set name/symbol, decimals = 18, totalSupply
    //         - balanceOf[msg.sender] = initialSupply
    //         - emit Transfer(address(0), msg.sender, initialSupply)
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }
    // TODO 6: transfer(_to, _amount) returns (bool)
    //         - require _to != address(0), đủ số dư
    //         - cập nhật số dư, emit Transfer
    function transfer(address _to, uint256 _amount) public returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }
    // TODO 7: approve(_spender, _amount) returns (bool)
    //         - allowance[msg.sender][_spender] = _amount
    //         - emit Approval
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    // TODO 8: transferFrom(_from, _to, _amount) returns (bool)
    //         - require _to != address(0), đủ số dư, đủ hạn mức allowance
    //         - chuyển token, trừ allowance, emit Transfer
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(allowance[_from][msg.sender] >= _amount, "Allowance exceeded");
        allowance[_from][msg.sender] -= _amount;
        _transfer(_from, _to, _amount);
        return true;
    }
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _amount, "Insufficient balance");

        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }
    // Câu hỏi tư duy:
    // 1. Vì sao cần approve + transferFrom thay vì chỉ transfer? => ...
    // transfer chỉ cho phép chính chủ chủ động gửi token đi. Nhưng nhiều tình huống cần contract khác tự lấy token từ ví bạn — ví dụ swap trên Uniswap: bạn không thể "gọi" lúc giao dịch khớp. Giải pháp: bạn approve cấp hạn mức trước, rồi Uniswap transferFrom tự rút trong hạn mức đó. Đây là mô hình "ủy quyền chi tiêu".
    // 2. allowance[A][B] nghĩa là gì? => ...
    // "A (chủ token) cho phép B (người được ủy quyền) tiêu tối đa bao nhiêu token của A". B là người gọi transferFrom, A là người bị trừ token.
    // 3. Vì sao constructor emit Transfer từ address(0)? => ...
    //  Theo quy ước ERC-20, mint (tạo token mới) được biểu diễn là chuyển từ address(0). Token chưa từng tồn tại nên không có người gửi thật → dùng địa chỉ 0 làm "nguồn". Nhờ vậy các công cụ off-chain (Etherscan, The Graph) tính đúng tổng cung từ lịch sử event Transfer.
}
