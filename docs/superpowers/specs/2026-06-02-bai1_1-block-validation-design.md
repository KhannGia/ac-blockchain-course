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
