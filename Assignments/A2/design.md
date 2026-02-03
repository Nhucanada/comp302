# Assignment 2 - Design Documentation

## Overview
This document details the design choices and lesson material used for each problem in Assignment 2, which covers unary numbers and mathematical expression manipulation.

---

## Question 1: Unary Numbers (nat type)

The `nat` type represents natural numbers using a unary (tally mark) system:
```ocaml
type nat = Z | S of nat
```
- `Z` represents zero
- `S n` represents the successor of `n` (i.e., `n + 1`)

### Q1a: nat_of_int (int → nat)

**Implementation:**
```ocaml
let q1a_nat_of_int (n : int) : nat =
  let rec helper n acc =
    if n = 0 then acc
    else helper (n - 1) (S acc)
  in
  helper n Z
```

**Design Choices:**
1. **Tail-recursive with accumulator**: Uses an inner helper function with an accumulator `acc` that builds up the result
2. **Accumulator semantics**: Start with `Z` (zero) and add `S` constructors as we count down from `n`
3. The helper is tail-recursive because the recursive call is the last operation

### Q1b: int_of_nat (nat → int)

**Implementation:**
```ocaml
let q1b_int_of_nat (n : nat) : int =
  let rec helper n acc =
    match n with
    | Z -> acc
    | S n' -> helper n' (acc + 1)
  in
  helper n 0
```

**Design Choices:**
1. **Tail-recursive with accumulator**: Uses pattern matching to peel off `S` constructors
2. **Accumulator semantics**: Start with `0` and increment for each `S` constructor encountered
3. Similar to computing the length of a linked list (l4.ml, lines 256-260)

### Q1c: add (nat → nat → nat)

**Implementation:**
```ocaml
let rec q1c_add (n : nat) (m : nat) : nat =
  match n with
  | Z -> m
  | S n' -> q1c_add n' (S m)
```

**Design Choices:**
1. **No external function calls**: Only uses recursive calls to itself, as required
2. **Tail-recursive approach**: Peel off `S` from `n` and add it to `m`
3. This is essentially "transferring" the tally marks from `n` to `m`
4. Algorithm: `n + m = (n-1) + (m+1)` until `n = 0`

**Lesson Material Used:**
- **Lesson 3 (l3.ml)**: Tail-recursive functions with accumulators (lines 11-15, sum_tr pattern)
- **Lesson 4 (l4.ml)**: Recursive types and pattern matching (lines 220-260, linked list operations)
- The `nat` type is structurally similar to a list without elements, so list operations translate directly

---

## Question 2: Expression Manipulation

### Q2a: neg (exp → exp)

**Implementation:**
```ocaml
let q2a_neg (e : exp) : exp = Times (Const (-1.0), e)
```

**Design Choice:** Represents negation as multiplication by `-1.0`, keeping the expression representation minimal.

### Q2b: minus (exp → exp → exp)

**Implementation:**
```ocaml
let q2b_minus (e1 : exp) (e2 : exp) : exp = Plus (e1, q2a_neg e2)
```

**Design Choice:** Subtraction is addition of the negation: `e1 - e2 = e1 + (-e2)`

### Q2c: pow (exp → nat → exp)

**Implementation:**
```ocaml
let rec q2c_pow (e1 : exp) (p : nat) : exp =
  match p with
  | Z -> Const 1.0
  | S p' -> Times (e1, q2c_pow e1 p')
```

**Design Choices:**
1. **Right-associative multiplication**: `e^3 = e * (e * (e * 1))` as required by the grader
2. **Base case**: `e^0 = 1.0`
3. **Recursive case**: `e^n = e * e^(n-1)`

**Lesson Material Used:**
- **Lesson 4 (l4.ml)**: Recursive types with constructors carrying data (lines 163-179, symbol with fields)
- **Lesson 4 (l4.ml)**: Pattern matching on recursive types

---

## Question 3: Expression Evaluation

**Implementation:**
```ocaml
let rec eval (a : float) (e : exp) : float =
  match e with
  | Const c -> c
  | Var -> a
  | Plus (e1, e2) -> eval a e1 +. eval a e2
  | Times (e1, e2) -> eval a e1 *. eval a e2
  | Div (e1, e2) -> eval a e1 /. eval a e2
```

**Design Choices:**
1. **Recursive evaluation**: Evaluate subexpressions first, then combine results
2. **Variable substitution**: When encountering `Var`, return the value `a`
3. **Pattern matching on exp type**: Handle each constructor case

**Algorithm Explanation:**
- For compound expressions (`Plus`, `Times`, `Div`), recursively evaluate both subexpressions to get float values, then apply the corresponding OCaml operator
- This is a classic tree traversal pattern

**Lesson Material Used:**
- **Lesson 4 (l4.ml)**: Pattern matching on algebraic data types (lines 68-76, beats function)
- **Lesson 8 (l8.ml)**: Expression evaluation pattern (lines 354-358, eval function in CPS section)
- **Lesson 1 (l1.ml)**: Float operators (`+.`, `*.`, `/.`)

---

## Question 4: Symbolic Differentiation

**Implementation:**
```ocaml
let rec diff (e : exp) : exp =
  match e with
  | Const _ -> Const 0.0
  | Var -> Const 1.0
  | Plus (e1, e2) -> Plus (diff e1, diff e2)
  | Times (e1, e2) -> Plus (Times (diff e1, e2), Times (e1, diff e2))
  | Div (e1, e2) -> Div (q2b_minus (Times (diff e1, e2)) (Times (e1, diff e2)),
                         Times (e2, e2))
```

**Design Choices:**
1. **Direct rule application**: Each derivative rule is implemented exactly as stated, without simplification
2. **Reuses q2b_minus**: The quotient rule uses subtraction, which we implement via `q2b_minus`

**Differentiation Rules Implemented:**
| Expression | Derivative | Implementation |
|------------|------------|----------------|
| `Const c` | `0` | `Const 0.0` |
| `Var` | `1` | `Const 1.0` |
| `Plus(e1, e2)` | `D(e1) + D(e2)` | `Plus (diff e1, diff e2)` |
| `Times(e1, e2)` | `D(e1)*e2 + e1*D(e2)` | `Plus (Times (diff e1, e2), Times (e1, diff e2))` |
| `Div(e1, e2)` | `(D(e1)*e2 - e1*D(e2)) / (e2*e2)` | Uses `q2b_minus` for subtraction |

**Lesson Material Used:**
- **Lesson 4 (l4.ml)**: Recursive functions on algebraic data types
- **Lesson 8 (l8.ml)**: Expression type and recursive evaluation (lines 348-358)

---

## Summary of Lesson Concepts Applied

| Concept | Lessons | Application |
|---------|---------|-------------|
| Recursive types | L4 | `nat` and `exp` types |
| Pattern matching | L4 | All functions use `match` expressions |
| Tail-recursion with accumulators | L3 | Q1a `nat_of_int`, Q1b `int_of_nat`, Q1c `add` |
| Inner helper functions | L2, L3 | Q1a and Q1b use `let rec helper ... in` |
| Float operators | L1 | Q3 `eval` uses `+.`, `*.`, `/.` |
| Recursive tree traversal | L4, L8 | Q3 `eval` and Q4 `diff` |

---

## Test Case Design

### Q1 Tests
- Base cases: `Z` conversions, `0 + 0`
- Small values: 1, 2, 3, 5
- Commutativity check for `add`

### Q3 Eval Tests
- Each constructor type: `Const`, `Var`, `Plus`, `Times`, `Div`
- Compound expressions: `2x + 10` with `x=3`
- Negative values for `Var`

### Q4 Diff Tests
- Constant derivative: `D(5) = 0`
- Variable derivative: `D(x) = 1`
- Sum rule: `D(x + 3) = 1 + 0`
- Product rule: `D(x * x) = 1*x + x*1`
- Quotient rule: `D(x / 2)`

All tests follow the principle of testing one case at a time with asymmetric values to catch variable swap bugs.
