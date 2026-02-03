# Assignment 1 - Design Documentation

## Overview
This document details the design choices and lesson material used for each problem in Assignment 1.

---

## Question 1: Manhattan Distance

### Problem
Fix the buggy implementation of `distance` that calculates the Manhattan distance between two points.

### Original Bug Analysis
The original implementation was:
```ocaml
let distance (x1, y1) (x2, y2) = 
  (x1 - y1) + (x2 - y2) 
```

**Issues identified:**
1. The formula incorrectly subtracts coordinates within the same point (`x1 - y1`) instead of between corresponding coordinates of different points (`x1 - x2`).
2. Missing absolute value - Manhattan distance requires non-negative values.

### Corrected Implementation
```ocaml
let distance (x1, y1) (x2, y2) = 
  abs (x1 - x2) + abs (y1 - y2) 
```

### Design Choices
- Used tuple pattern matching to destructure the input pairs directly in the function parameters
- Applied the `abs` function to ensure distances are always non-negative

### Test Design Strategy
Tests were designed to catch the following bug categories:
1. **Identity property**: `distance a a = 0` (distance from a point to itself is zero)
2. **Symmetry property**: `distance a b = distance b a` 
3. **Non-negativity**: distances should never be negative
4. **Asymmetric inputs**: using different values for x and y coordinates to catch variable mix-ups

### Lesson Material Used
- **Lesson 1 (l1.ml)**: Basic integer operations, the `abs` function for absolute values
- **Lesson 4 (l4.ml)**: Tuple pattern matching in function parameters (lines 36-44 demonstrate destructuring tuples in function definitions)

---

## Question 2: Binomial Coefficient

### Problem
Implement `binomial n k` to compute B(n, k) = n! / (k! × (n-k)!) using factorials.

### Implementation
```ocaml
let binomial n k =
  let rec factorial m =
    if m = 0 then 1
    else m * factorial (m - 1)
  in
  factorial n / (factorial k * factorial (n - k))
```

### Design Choices
1. **Inner helper function**: The `factorial` function is defined as an inner helper using `let ... in` syntax, keeping it encapsulated and not exposed to external code.
2. **Simple recursion for factorial**: The factorial is implemented using straightforward recursion. While not tail-recursive, this is acceptable as factorials are typically computed for small values.
3. **Direct formula application**: The binomial formula is applied directly after computing the three required factorials.

### Test Design Strategy
Tests cover:
1. **Base cases**: B(0,0) = 1, B(n,0) = 1, B(n,n) = 1
2. **Identity B(n,1) = n**: Easy to verify correctness
3. **Known values**: Pascal's triangle values like B(4,2) = 6, B(5,2) = 10, B(6,3) = 20
4. **Asymmetric tests**: Different n and k values to catch parameter swaps

### Lesson Material Used
- **Lesson 2 (l2.ml)**: Recursive functions with `let rec` (lines 67-68 show recursive `sum`)
- **Lesson 2 (l2.ml)**: Inner helper functions using `let ... in` syntax (lines 49-53 demonstrate local definitions)
- **Lesson 3 (l3.ml)**: Inner helper function pattern (lines 6-15 show `sum_tr` as an inner helper)

---

## Question 3: Lucas Numbers

### Problem
Implement `lucas n` to compute the nth Lucas number using a tail-recursive helper function.

Lucas numbers are defined as:
- L(0) = 2
- L(1) = 1  
- L(n) = L(n-1) + L(n-2)

### Implementation
```ocaml
let rec lucas_helper n a b =
  if n = 0 then a
  else lucas_helper (n - 1) b (a + b)

let lucas n =
  lucas_helper n 2 1
```

### Design Choices
1. **Tail-recursive helper with accumulators**: The helper carries forward L(n-1) and L(n-2) as accumulator parameters `a` and `b`, avoiding stack buildup.
2. **Parameter semantics**: 
   - `n` is the countdown counter
   - `a` represents L(current index)
   - `b` represents L(current index + 1)
3. **Initial values**: `lucas n` calls the helper with `a = 2` (L(0)) and `b = 1` (L(1))
4. **Tail-call optimization**: Each recursive call to `lucas_helper` is in tail position, meaning the OCaml compiler can optimize this to use constant stack space.

### Algorithm Trace (for understanding)
```
lucas 4
= lucas_helper 4 2 1          -- a=L(0)=2, b=L(1)=1
= lucas_helper 3 1 3          -- a=L(1)=1, b=L(2)=3
= lucas_helper 2 3 4          -- a=L(2)=3, b=L(3)=4
= lucas_helper 1 4 7          -- a=L(3)=4, b=L(4)=7
= lucas_helper 0 7 11         -- a=L(4)=7, return a
= 7
```

### Test Design Strategy
Tests systematically verify:
1. **Base cases**: L(0) = 2, L(1) = 1
2. **Early recursive values**: L(2) through L(7) computed by hand
3. **Larger value**: L(10) = 123 to ensure the recursion works correctly for larger inputs

### Lesson Material Used
- **Lesson 3 (l3.ml)**: Tail-recursive Fibonacci implementation (lines 32-34) - this is the **primary reference** as the Lucas sequence uses the exact same algorithmic pattern:
  ```ocaml
  let rec fib n a b =
    if n = 0 then a else
      fib (n-1) b (a + b)
  ```
  Lucas numbers differ only in the initial values (2, 1 instead of 0, 1).
  
- **Lesson 3 (l3.ml)**: Concept of tail-recursion and accumulator parameters (lines 11-14 show the pattern)
- **Lesson 2 (l2.ml)**: Recursive function definitions with `let rec`

---

## Summary of Lesson Concepts Applied

| Concept | Lessons | Application |
|---------|---------|-------------|
| Tuple pattern matching | L4 | Q1: Destructuring point coordinates |
| `abs` function | L1 | Q1: Ensuring non-negative distances |
| Recursive functions (`let rec`) | L2, L3 | Q2, Q3: Factorial and Lucas helper |
| Inner helper functions (`let ... in`) | L2, L3 | Q2: Encapsulated factorial function |
| Tail-recursion with accumulators | L3 | Q3: Efficient Lucas number computation |
| Fibonacci pattern | L3 | Q3: Direct adaptation for Lucas sequence |
