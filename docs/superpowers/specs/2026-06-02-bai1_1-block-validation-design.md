# Design Spec: bai1_1 Block Validation

## 1) Objective
Implement `isValidBlock(block: Block): boolean` for `lessons/bai1_1` so it validates a block by recomputing SHA256 and comparing against `current_hash`, while also handling malformed runtime input safely.

## 2) Scope
In scope:
- Keep existing exported API unchanged:
  - `type Block`
  - `isValidBlock(block: Block): boolean`
- Add defensive runtime validation inside `isValidBlock`.
- Use strict hash comparison with no normalization.
- Match current test hash formula exactly.

Out of scope:
- Changing function signature/types.
- Throwing errors for invalid input.
- Altering hash formula or field order.
- Any unrelated refactor.

## 3) Architecture
Single-file implementation in `lessons/bai1_1/solution.ts`:
- One exported function: `isValidBlock`.
- Internal logic has two phases:
  1. Runtime shape/type validation.
  2. Deterministic hash recomputation and strict comparison.

This keeps the lesson simple and aligned with existing course structure.

## 4) Components
### A. Runtime validation gate
Inside `isValidBlock`, validate:
- input is a non-null object
- `index` is a finite number
- `timestamp` is a string
- `transactions` is an array
- `previous_hash` is a string
- `current_hash` is a string

If any check fails, return `false`.

### B. Hash recomputation
Construct hash input exactly as:
`index + timestamp + JSON.stringify(transactions) + previous_hash`

Compute SHA256 hex digest using Node `crypto`.

### C. Final decision
Return result of strict comparison:
`computedHash === current_hash`

## 5) Data Flow
1. Receive `block`.
2. Validate runtime shape/types.
3. If invalid, return `false`.
4. Build hash input in exact required order and format.
5. Compute SHA256 hex.
6. Compare strictly with `block.current_hash`.
7. Return `true` only on exact match; otherwise `false`.

## 6) Error Handling
- Non-throwing boolean validator.
- Any malformed input or mismatch returns `false`.
- No trim/lowercase normalization; formatting differences are invalid.
- Guarantees predictable caller behavior (boolean-only outcome).

## 7) Testing Plan
Baseline:
- Existing positive case should return `true`.
- Existing tampered hash case should return `false`.

Defensive scenarios to validate:
- wrong field types (for example, non-number `index`, non-array `transactions`)
- missing fields
- non-string hash fields
- formatting-only differences in `current_hash` (expect `false` due to strict compare)

Success criteria:
- valid input plus exact hash returns `true`
- malformed runtime shape returns `false`
- hash mismatch returns `false`
- no exceptions thrown

## 8) Trade-off Decision Record
Chosen approach: inline validation plus hashing in one function.

Why:
- Smallest, clearest implementation for this exercise.
- Matches current tests and lesson expectations.
- Adds requested safety checks without overengineering.

Alternatives considered:
- Extract helper functions (cleaner but unnecessary indirection here).
- Schema-style validation (most extensible, but overkill for bai1_1).


Khi dùng toán tử + với một mảng, JavaScript ép mảng về chuỗi bằng Array.prototype.toString() (tương đương array.join(",")), không
  phải JSON. Hai cách cho kết quả khác hẳn:

  ┌──────────────┬────────────────────────────────┬─────────────────────────┐
  │ transactions │ JSON.stringify(tx) (test dùng) │ Nối thẳng "" + tx (bẫy) │
  ├──────────────┼────────────────────────────────┼─────────────────────────┤
  │ []           │ "[]"                           │ "" (rỗng!)              │
  ├──────────────┼────────────────────────────────┼─────────────────────────┤
  │ [{a:1}]      │ '[{"a":1}]'                    │ "[object Object]"       │
  ├──────────────┼────────────────────────────────┼─────────────────────────┤
  │ [1,2,3]      │ "[1,2,3]"                      │ "1,2,3"                 │
  ├──────────────┼────────────────────────────────┼─────────────────────────┤
  │ ["a","b"]    │ '["a","b"]'                    │ "a,b"                   │
  └──────────────┴────────────────────────────────┴─────────────────────────┘

  (Hai dòng đầu mình đã chạy thật để xác nhận ở bước trước.)

  3. Hậu quả trên đúng block của bài

  block1 trong test có transactions: []. Hash kỳ vọng được tính với:
  value = 0 + "2024-01-01T00:00:00Z" + "[]" + "0"
        = "02024-01-01T00:00:00Z[]0"

  Còn sinh viên nối thẳng mảng:
  value = 0 + "2024-01-01T00:00:00Z" + "" + "0"      ← mất "[]"
        = "02024-01-01T00:00:00Z0"

  → Hai chuỗi khác nhau → SHA256 khác nhau → computedHash !== current_hash → isValidBlock(block1) trả về false dù block hoàn toàn hợp
  lệ.

  Kết quả: dòng console.log("✅ Block 1:", ...) in ra false thay vì true. Sinh viên tưởng logic so sánh của mình sai, loay hoay sửa
  chỗ khác — trong khi lỗi thật chỉ là quên JSON.stringify mảng.

  4. Vì sao bẫy này "ác"

  - Với transactions: [] (mảng rỗng), nối thẳng ra chuỗi rỗng — rất khó nhận ra vì nhìn không thấy gì sai.
  - [object Object] cũng là một cái bẫy nổi tiếng: mọi object khác nhau đều ra cùng chuỗi "[object Object]" → mất sạch dữ liệu
  transaction trong hash.

  5. Bạn đã thoát bẫy

  Lời giải của bạn dùng:
  JSON.stringify(candidate.transactions)
  → khớp đúng cách test.ts sinh hash, nên isValidBlock(block1) = true. ✅

  ---
  Tóm gọn: Bẫy 2 = đề ghi + transactions + khiến người làm nối thẳng mảng, nhưng JS ép mảng bằng toString() ([]→"", [{...}]→"[object
  Object]") khác hoàn toàn JSON.stringify mà test dùng để sinh current_hash → hash lệch → block hợp lệ bị báo sai.