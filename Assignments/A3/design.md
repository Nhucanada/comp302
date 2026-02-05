# Assignment 3 - Design Documentation

## Overview
This document details the design choices and lesson material used for each problem in Assignment 3, which covers Church numerals — a representation of natural numbers as higher-order functions.

---

## Background: Church Numerals

Church numerals represent natural numbers using the following type:
```ocaml
type 'b church = ('b -> 'b) -> 'b -> 'b
```

A Church numeral N is a function that takes:
- A function `s : 'b -> 'b` (the "successor" operation)
- A value `z : 'b` (the "zero" value)

And returns the result of applying `s` exactly N times to `z`.

Examples:
- `zero = fun s z -> z` (applies s 0 times)
- `one = fun s z -> s z` (applies s 1 time)
- `five = fun s z -> s (s (s (s (s z))))` (applies s 5 times)

**Critical Constraint**: None of the solutions use recursion or pattern-matching. All implementations are one-liners that exploit the higher-order nature of Church numerals.

---

## Question 1: Basic Church Numeral Operations

### Q1a: to_int (int church → int)

**Implementation:**
```ocaml
let to_int (n : int church) : int = n (fun x -> x + 1) 0
```

**Design Choices:**
1. **Instantiate with integers**: Use `s = (fun x -> x + 1)` as the successor function and `z = 0` as the starting value
2. **Counting via increment**: The Church numeral applies increment N times to 0, yielding N
3. **Type specialization**: The input type is `int church` rather than `'b church` due to OCaml type inference requirements

**Algorithm Trace:**
```
to_int five
= five (fun x -> x + 1) 0
= (fun x -> x + 1) ((fun x -> x + 1) ((fun x -> x + 1) ((fun x -> x + 1) ((fun x -> x + 1) 0))))
= (fun x -> x + 1) ((fun x -> x + 1) ((fun x -> x + 1) ((fun x -> x + 1) 1)))
= ... = 5
```

### Q1b: is_zero ('b church → bool)

**Implementation:**
```ocaml
let is_zero (n : 'b church) : bool = n (fun _ -> false) true
```

**Design Choices:**
1. **Boolean instantiation**: Instantiate with `z = true` and `s = (fun _ -> false)`
2. **Zero returns z directly**: Zero applies s zero times, so it just returns `true`
3. **Non-zero applies s at least once**: Any application of s returns `false`

**Algorithm Trace:**
```
is_zero zero = zero (fun _ -> false) true = true
is_zero one = one (fun _ -> false) true = (fun _ -> false) true = false
```

### Q1c: add ('b church → 'b church → 'b church)

**Implementation:**
```ocaml
let add (n1 : 'b church) (n2 : 'b church) : 'b church = fun s z -> n1 s (n2 s z)
```

**Design Choices:**
1. **Sequential application**: First apply s n2 times to z, then apply s n1 more times
2. **Composing applications**: `n2 s z` gives "s applied n2 times to z", then `n1 s (...)` applies s n1 more times
3. **Same idea as unary addition from HW2**: Replace the "zero" of n1 with the result of n2

**Algorithm Explanation:**
- `n2 s z` computes s^n2(z) — applying s n2 times to z
- `n1 s (n2 s z)` computes s^n1(s^n2(z)) = s^(n1+n2)(z)
- Result: a function that applies s (n1 + n2) times

**Lesson Material Used:**
- **Lesson 6 (l6.ml)**: Higher-order functions and function composition (lines 86-108)
- **Lesson 6 (l6.ml)**: The `times` function pattern (lines 201-206) — applying a function n times

---

## Question 2: Advanced Church Numeral Operations

### Q2a: mult ('b church → 'b church → 'b church)

**Implementation:**
```ocaml
let mult (n1 : 'b church) (n2 : 'b church) : 'b church = fun s z -> n1 (n2 s) z
```

**Design Choices:**
1. **Function composition as multiplication**: `n2 s` is a function that applies s n2 times
2. **Repeated composition**: `n1 (n2 s) z` applies the "apply s n2 times" function n1 times
3. **Total applications**: s is applied n1 × n2 times

**Algorithm Explanation:**
- `n2 s` returns a function f where f(x) = s^n2(x)
- `n1 (n2 s) z` applies f n1 times to z
- Each application of f applies s n2 times
- Total: n1 × n2 applications of s

**Algorithm Trace (for 2 × 3):**
```
mult two three
= fun s z -> two (three s) z
= fun s z -> two (fun x -> s (s (s x))) z
= fun s z -> (fun x -> s (s (s x))) ((fun x -> s (s (s x))) z)
= fun s z -> (fun x -> s (s (s x))) (s (s (s z)))
= fun s z -> s (s (s (s (s (s z)))))  -- six applications of s
```

### Q2b: int_pow_church (int → 'b church → int)

**Implementation:**
```ocaml
let int_pow_church (x : int) (n : 'b church) : int = n (fun a -> a * x) 1
```

**Design Choices:**
1. **Exponentiation as repeated multiplication**: x^n means multiplying by x, n times
2. **Starting value**: Begin with 1 (x^0 = 1)
3. **Successor operation**: Each step multiplies the accumulator by x

**Algorithm Explanation:**
- Start with 1
- Apply "multiply by x" n times
- After n applications: 1 × x × x × ... × x = x^n

**Algorithm Trace (for 2^3):**
```
int_pow_church 2 three
= three (fun a -> a * 2) 1
= (fun a -> a * 2) ((fun a -> a * 2) ((fun a -> a * 2) 1))
= (fun a -> a * 2) ((fun a -> a * 2) 2)
= (fun a -> a * 2) 4
= 8
```

**Lesson Material Used:**
- **Lesson 6 (l6.ml)**: The `times` function (lines 201-206) — this is the exact pattern:
  ```ocaml
  let rec times n f x = if n = 0 then x else f (times (n-1) f x)
  ```
  Church numerals ARE this pattern, but represented as data!
- **Lesson 6 (l6.ml)**: Exercise on implementing `pow` using `times` (lines 210-216) — directly applicable concept

---

## Summary of Lesson Concepts Applied

| Concept | Lessons | Application |
|---------|---------|-------------|
| Higher-order functions | L6 | All functions use Church numerals as HOFs |
| Function composition | L6 | `mult` composes applications |
| Polymorphism | L5, L6 | Church type uses type variable 'b |
| `times` pattern | L6 | Direct correspondence to Church numerals |
| Instantiation of polymorphic types | L6 | Each function instantiates 'b differently |

---

## Key Insight: Connection to `times`

The instructions reference `process_nat` which is equivalent to the `times` function from Lesson 6:

```ocaml
let rec times n f x = if n = 0 then x else f (times (n-1) f x)
```

A Church numeral IS this computation, but encoded as data (a function). When we call a Church numeral with `s` and `z`, we're essentially running `times n s z` where n is the number the Church numeral represents.

This explains why:
- `to_int n = n (fun x -> x + 1) 0` — same as `times n (fun x -> x + 1) 0`
- `int_pow_church x n = n (fun a -> a * x) 1` — same as `times n (fun a -> a * x) 1`

---

## Test Case Design

### Q1a to_int Tests
- Zero case: `zero → 0`
- One case: `one → 1`
- Larger value: `five → 5`
- Inline definition: `(fun s z -> s (s z)) → 2`

### Q1b is_zero Tests
- Zero returns true: `zero → true`
- One returns false: `one → false`
- Larger returns false: `five → false`

### Q1c add Tests
- Identity cases: `0 + 0 = 0`, `0 + 1 = 1`, `1 + 0 = 1`
- Standard addition: `1 + 1 = 2`, `2 + 3 = 5`

### Q2a mult Tests
- Zero property: `0 × 1 = 0`, `1 × 0 = 0`
- Identity: `1 × 1 = 1`, `1 × 5 = 5`
- Standard multiplication: `2 × 3 = 6`, `2 × 2 = 4`

### Q2b int_pow_church Tests
- Zero exponent: `2^0 = 1`, `10^0 = 1`
- Powers of 2: `2^1 = 2`, `2^2 = 4`, `2^3 = 8`
- Other bases: `3^2 = 9`, `5^2 = 25`

All tests use asymmetric values where applicable to catch argument order bugs.
