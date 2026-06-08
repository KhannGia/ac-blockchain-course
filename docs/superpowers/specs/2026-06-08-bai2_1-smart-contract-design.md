# Design Spec: bai2_1 SmartContract

## 1) Objective
Implement a `SmartContract` class in `lessons/bai2_1/solution.ts` that simulates a
smart contract storing and updating a `message`, with safe non-throwing runtime
validation, consistent with the defensive style established in bai1_1.

## 2) Scope
In scope:
- Keep the API required by `problem.md` unchanged:
  - `constructor(initialMessage)`
  - `updateMessage(newMsg: string): void`
  - `getMessage(): string`
- Keep `message` as a `private` field.
- Add runtime `typeof` guards so invalid (non-string) input is handled safely.

Out of scope:
- Changing method signatures or field types.
- Adding events/logs, owner, or change history (the Solidity-extension option was
  explicitly rejected during brainstorming).
- Any unrelated refactor.

## 3) Architecture
Single-file implementation in `lessons/bai2_1/solution.ts` with one exported class
`SmartContract`:
- `private message: string` — internal state, always a valid string.
- A small internal guard: `typeof x === "string"`.

This keeps the lesson simple and aligned with the existing course structure.

## 4) Components
### A. Constructor
- If `initialMessage` is a string → assign it to `message`.
- Otherwise → fall back to `""`.

### B. updateMessage(newMsg)
- If `newMsg` is a string → update `message`.
- Otherwise → no-op (keep the previous `message`), do not throw.

### C. getMessage()
- Return the current `message`.

## 5) Data Flow
1. `new SmartContract(initialMessage)` → guard → set `message` or `""`.
2. `updateMessage(newMsg)` → guard → set `message` or no-op.
3. `getMessage()` → return `message`.

## 6) Error Handling
- Non-throwing throughout.
- Invalid (non-string) input is silently rejected.
- `getMessage()` always returns a valid string.
- No normalization (no trim/lowercase); the user-supplied string is stored as-is.
- The empty string `""` is a valid value and is accepted by both constructor and
  `updateMessage`.

## 7) Testing Plan
Baseline (existing `test.ts`):
- `new SmartContract("Hello")` → `getMessage()` returns `"Hello"`.
- After `updateMessage("Blockchain!")` → `getMessage()` returns `"Blockchain!"`.

Defensive scenarios to validate:
- Constructor with non-string input → `getMessage()` returns `""`.
- `updateMessage(non-string)` → previous `message` is preserved.
- Empty string `""` is accepted as a valid update.

Success criteria:
- All valid operations behave as expected.
- Invalid input never throws and never corrupts state.
- `getMessage()` always returns a string.

## 8) Trade-off Decision Record
Chosen approach: silent reject of invalid input (keep previous value; constructor
falls back to `""`).

Why:
- Consistent with bai1_1's non-throwing validator decision.
- Preserves the exact API signatures required by the problem (the setter returns
  `void`, so a boolean result is not available to signal rejection).
- Guarantees `getMessage()` always returns a valid string.

Alternatives considered:
- Throw `TypeError` on invalid input (fail fast, but inconsistent with bai1_1's
  non-throwing choice).
- Coerce with `String(x)` (never errors, but hides bugs — e.g. `String(null)`
  becomes `"null"`).
