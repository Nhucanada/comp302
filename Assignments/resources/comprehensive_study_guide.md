# COMP 302 Comprehensive Study Guide

## Table of Contents
1. [Lesson 1: Evaluation and Typing](#lesson-1-evaluation-and-typing)
2. [Lesson 2: Functions and Recursion](#lesson-2-functions-and-recursion)
3. [Lesson 3: Tail Recursion](#lesson-3-tail-recursion)
4. [Lesson 4: Types, Tuples, and Pattern Matching](#lesson-4-types-tuples-and-pattern-matching)
5. [Lesson 5: Polymorphism and Generics](#lesson-5-polymorphism-and-generics)
6. [Lesson 6: Higher-Order Functions](#lesson-6-higher-order-functions)
7. [Lesson 8: Continuation-Passing Style (CPS)](#lesson-8-continuation-passing-style-cps)
8. [Assignment Summaries](#assignment-summaries)

---

## Lesson 1: Evaluation and Typing

### Basic Types and Operators

| Type | Examples | Operators |
|------|----------|-----------|
| `int` | `-1`, `4`, `42` | `+`, `-`, `*`, `/`, `mod` |
| `float` | `3.14`, `2.0` | `+.`, `-.`, `*.`, `/.` |
| `string` | `"hello"` | `^` (concatenation) |
| `char` | `'c'`, `'3'` | - |
| `bool` | `true`, `false` | `&&`, `||`, `not` |

### Key Concepts

**Type Safety**: OCaml is statically typed - you cannot mix types without explicit conversion.
```ocaml
(* WRONG: 5 / 3.0 - mixing int and float *)
(* CORRECT: 5.0 /. 3.0 *)
```

**If-Then-Else is an Expression**:
```ocaml
let result = if condition then value1 else value2
(* Both branches MUST have the same type *)
```

**Structural Equality**: Use `=` to test equality (not `==`).

### Common Pitfalls
- Integer division truncates: `5/2 = 2`
- Float operators have a dot: `+.`, `-.`, `*.`, `/.`
- Division by zero compiles but throws runtime exception

---

## Lesson 2: Functions and Recursion

### Function Definition

```ocaml
(* Simple function *)
let greet name = "Hello, " ^ name

(* Multiple parameters *)
let add x y = x + y

(* With type annotations *)
let add (x : int) (y : int) : int = x + y
```

### Local Definitions with `let-in`

```ocaml
let compute x =
  let squared = x * x in
  let doubled = x * 2 in
  squared + doubled
```

**Scope**: Variables defined with `let-in` are only visible after the `in` keyword.

### Recursive Functions

OCaml requires explicit `rec` keyword for recursion:
```ocaml
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)
```

**Why `rec`?** Without it, the function name isn't in scope on the right-hand side.

### Inner Helper Functions

```ocaml
let outer_function x =
  let rec helper n acc =
    if n = 0 then acc
    else helper (n-1) (acc + n)
  in
  helper x 0
```

---

## Lesson 3: Tail Recursion

### Definition
A function is **tail-recursive** when ALL recursive calls are **tail calls**.

A **tail call** is when the recursive call is the LAST operation before returning.

### Non-Tail-Recursive vs Tail-Recursive

```ocaml
(* NON-tail-recursive: work happens AFTER recursive call *)
let rec sum n =
  if n = 0 then 0 
  else n + sum (n-1)  (* Addition happens after recursive call returns *)

(* Tail-recursive: recursive call IS the return value *)
let rec sum_tr n acc =
  if n = 0 then acc 
  else sum_tr (n-1) (acc + n)  (* Recursive call is the last thing *)
```

### The Accumulator Pattern

Convert non-TR to TR by:
1. Add an accumulator parameter
2. Do the work BEFORE the recursive call (update accumulator)
3. Return accumulator in base case

```ocaml
(* Pattern for converting to tail-recursive *)
let function_tr input =
  let rec helper input acc =
    match input with
    | base_case -> acc
    | recursive_case -> helper (smaller_input) (updated_acc)
  in
  helper input initial_acc
```

### Fibonacci: Classic Example

```ocaml
(* Non-TR: O(2^n) time, O(n) space *)
let rec fib n =
  if n = 0 then 0 else
  if n = 1 then 1 else
    fib (n-1) + fib (n-2)

(* TR: O(n) time, O(1) space *)
let rec fib_tr n a b =
  if n = 0 then a 
  else fib_tr (n-1) b (a + b)
```

### Why Tail Recursion Matters
- Non-TR uses O(n) stack space (can overflow)
- TR uses O(1) stack space (tail-call optimization)
- OCaml optimizes tail calls into loops

---

## Lesson 4: Types, Tuples, and Pattern Matching

### Type Synonyms

```ocaml
type name = string
type height_cm = int
type person = name * height_cm
```

### Tuples

```ocaml
(* Creating tuples *)
let point = (3, 4)           (* int * int *)
let person = ("Alice", 25)   (* string * int *)

(* Accessing elements *)
let x = fst point   (* First element *)
let y = snd point   (* Second element - only for pairs! *)
```

### Enumerated Types (Variants)

```ocaml
type hand = Rock | Paper | Scissors
type outcome = Win | Lose | Draw
```

**Convention**: Constructors start with UPPERCASE, variables with lowercase.

### Pattern Matching with `match`

```ocaml
let beats h1 h2 =
  match h1 with
  | Rock -> h2 = Scissors
  | Paper -> h2 = Rock
  | Scissors -> h2 = Paper
```

### Constructors with Fields

```ocaml
type symbol =
  | Number of int    (* Carries an int *)
  | Skip
  | Reverse
  | Plus2

(* Pattern matching extracts the field *)
match symbol with
| Number n -> n      (* n is bound to the int value *)
| _ -> 0
```

### Recursive Types

```ocaml
type 'a mylist =
  | Empty
  | Cons of 'a * 'a mylist

(* Binary tree *)
type 'a tree = 
  | Empty 
  | Node of 'a tree * 'a * 'a tree
```

### Pattern Matching Rules

1. **Patterns introduce NEW names** - you can't check equality by repeating a name
2. **Wildcard `_`** matches anything (useful for "else" cases)
3. **Guard clauses** with `when`:
   ```ocaml
   match x with
   | (a, b) when a = b -> "equal"
   | _ -> "different"
   ```

### Nested Pattern Matching

```ocaml
(* Matching tuples of tuples *)
match (card1, card2) with
| ((color1, sym1), (color2, sym2)) -> color1 = color2
```

**IMPORTANT**: Use parentheses or `begin`/`end` around nested match expressions!

---

## Lesson 5: Polymorphism and Generics

### Polymorphic Types

Type variables are written with a leading apostrophe: `'a`, `'b`, etc.

```ocaml
(* Identity function: works for ANY type *)
let id x = x                  (* 'a -> 'a *)

(* Constant function *)
let const x y = x             (* 'a -> 'b -> 'a *)
```

### Type Inference Process

1. Assign distinct type variables to each parameter
2. Analyze the body for constraints
3. Refine type variables based on operations

```ocaml
let f x y =
  let _ = x + 1 in   (* x must be int *)
  y                  (* y is unconstrained *)
(* Type: int -> 'a -> 'a *)
```

### The Option Type

```ocaml
type 'a option =
  | None           (* Represents absence/failure *)
  | Some of 'a     (* Represents presence/success *)

(* Safer than null! *)
let safe_div x y =
  if y = 0 then None
  else Some (x / y)
```

### Built-in List Type

```ocaml
(* Conceptually defined as: *)
type 'a list =
  | []                      (* Empty list *)
  | (::) of 'a * 'a list    (* Cons: element and rest *)

(* Examples *)
let nums = [1; 2; 3]              (* Syntax sugar *)
let nums = 1 :: 2 :: 3 :: []      (* Explicit cons *)

(* IMPORTANT: Separator is semicolon, not comma! *)
```

### List Pattern Matching

```ocaml
let rec length l =
  match l with
  | [] -> 0
  | x :: xs -> 1 + length xs    (* x is head, xs is tail *)
```

---

## Lesson 6: Higher-Order Functions

### Functions as Values

```ocaml
(* Functions can be passed as arguments *)
let apply_twice f x = f (f x)

(* Anonymous functions with fun *)
let double = fun x -> x * 2
apply_twice double 3    (* Result: 12 *)
```

### Function Application Rules

- **Left-associative**: `f a b` = `(f a) b`
- **Arrow types are right-associative**: `a -> b -> c` = `a -> (b -> c)`
- All multi-argument functions are actually curried (return functions)

### Composition

```ocaml
let compose f g = fun x -> f (g x)
(* Type: ('b -> 'c) -> ('a -> 'b) -> ('a -> 'c) *)

let h = compose (fun x -> x + 1) (fun x -> x * 2)
(* h 3 = (3 * 2) + 1 = 7 *)
```

### The `times` Function

```ocaml
(* Apply function f, n times to x *)
let rec times n f x =
  if n = 0 then x 
  else f (times (n-1) f x)

(* Tail-recursive version *)
let rec times_tr n f x =
  if n = 0 then x 
  else times_tr (n-1) f (f x)
```

### Essential List HOFs

#### Map
```ocaml
let rec map f l = match l with
  | [] -> []
  | x :: xs -> f x :: map f xs
(* Type: ('a -> 'b) -> 'a list -> 'b list *)

map (fun x -> x * 2) [1;2;3]  (* [2;4;6] *)
```

#### Filter
```ocaml
let rec filter p l = match l with
  | [] -> []
  | x :: xs -> 
      if p x then x :: filter p xs 
      else filter p xs
(* Type: ('a -> bool) -> 'a list -> 'a list *)

filter (fun x -> x > 0) [-1;2;-3;4]  (* [2;4] *)
```

#### Fold Right
```ocaml
let rec fold_right f l e = match l with
  | [] -> e
  | x :: xs -> f x (fold_right f xs e)
(* Type: ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b *)

(* Sum using fold_right *)
fold_right (fun x acc -> x + acc) [1;2;3] 0  (* 6 *)

(* Map using fold_right *)
let map f l = fold_right (fun x ys -> f x :: ys) l []

(* Filter using fold_right *)
let filter p l = fold_right (fun x ys -> if p x then x::ys else ys) l []
```

---

## Lesson 8: Continuation-Passing Style (CPS)

### What is CPS?

CPS is a technique to make ANY function tail-recursive by:
1. Adding a **continuation** parameter (a function representing "what to do next")
2. Instead of returning values, call the continuation with the result
3. Move post-recursive work into expanded continuations

### Common Exam CPS Questions
- **Tree flattening** (very frequent)
- **Tree operations** with nested recursive calls
- **Type signature transformations**
- **Initial continuation** is always identity `(fun x -> x)`

### The CPS Translation Recipe

```
ORIGINAL:                          CPS VERSION:
let rec f x =                      let rec f_cps x return =
  match x with                       match x with
  | base -> value                    | base -> return value
  | step ->                          | step ->
      ... (f smaller) ...                f_cps smaller (fun result ->
                                           return (... result ...))
```

### Example: Append

```ocaml
(* Original (not tail-recursive) *)
let rec append l1 l2 = match l1 with
  | [] -> l2
  | x :: xs -> x :: append xs l2

(* CPS version (tail-recursive) *)
let rec append_cps l1 l2 return = match l1 with
  | [] -> return l2
  | x :: xs -> append_cps xs l2 (fun ys -> return (x :: ys))

(* Usage: call with identity continuation *)
append_cps [1;2] [3;4] (fun x -> x)  (* [1;2;3;4] *)
```

### CPS Type Signatures

If original function has type: `input -> output`  
CPS version has type: `input -> (output -> 'r) -> 'r`

The continuation type is always: `original_output_type -> 'r`

```ocaml
(* Original *)
val append : 'a list -> 'a list -> 'a list

(* CPS *)
val append_cps : 'a list -> 'a list -> ('a list -> 'r) -> 'r
```

### CPS with Multiple Recursive Calls (Trees)

```ocaml
(* Original tree depth *)
let rec tree_depth t = match t with
  | Empty -> 0
  | Node (l, _, r) -> 1 + max (tree_depth l) (tree_depth r)

(* CPS version - nest the continuations *)
let rec tree_depth_cps t return = match t with
  | Empty -> return 0
  | Node (l, _, r) ->
      tree_depth_cps l (fun dl ->          (* First recursive call *)
        tree_depth_cps r (fun dr ->        (* Second recursive call *)
          return (1 + max dl dr)))         (* Combine and return *)
```

### Why CPS Works

The continuation represents the **call stack** as a function:
- Building continuations = pushing onto stack
- Calling continuation = popping from stack

**Memory trade-off**:
- Original: Uses O(n) **stack** memory (limited, ~8MB)
- CPS: Uses O(n) **heap** memory (dynamic, can be GBs)

### Tree Flattening (Most Common Exam Question!)

```ocaml
type 'a tree = Leaf of 'a | Node of 'a tree * 'a tree

(* Original - not tail recursive *)
let rec flatten t = match t with
  | Leaf x -> [x]
  | Node(l,r) -> flatten l @ flatten r

(* CPS version - exam solution pattern *)
let rec flatten_cps t cont = match t with
  | Leaf x -> cont [x]
  | Node(l,r) ->
      flatten_cps l (fun left_result ->
        flatten_cps r (fun right_result ->
          cont (left_result @ right_result)))

(* Usage: flatten_cps tree (fun x -> x) *)
```

### Early Exit with CPS

CPS allows "jumping" out of nested computations:

```ocaml
(* Product with early exit on zero *)
let product l return_outside =
  let rec go l return = match l with
    | [] -> return 1
    | x :: xs ->
        if x = 0 then return_outside 0  (* Skip pending multiplications! *)
        else go xs (fun y -> return (y * x))
  in
  go l return_outside
```

---

## Exam-Specific Patterns & Traps

### Type Inference Step-by-Step
1. **Assign variables**: Each parameter gets `'a`, `'b`, etc.
2. **Gather constraints**: `x + 1` → `x:int`, `f x` → `f:'a -> 'b`
3. **Unify**: Solve constraints to find most general type
4. **Common traps**:
   - Function application: `app (app double)` requires careful type tracing
   - Polymorphic vs concrete: Don't assume `int` when `'a` works

### Pattern Matching Bug Hunting
**Classic bugs from exams:**
```ocaml
let func f lst1 lst2 = (* Missing 'rec'! *)
  match (lst1, lst2) with
  | (x::xs, Some y) -> (* WRONG: Some y expects option, not list element *)
  | _ -> ["Error"]     (* WRONG: String list, not polymorphic *)
```

### Scoping & Evaluation Tracing
**Key principle**: Inner bindings shadow outer ones
```ocaml
let x = 6 in (let x = 9 in x) * x
(* Step 1: Evaluate inner (let x = 9 in x) → 9 *)
(* Step 2: Outer x is still 6 → 9 * 6 = 54 *)
```

### Higher-Order Function Composition
**Exam pattern**: Combine filter/map efficiently
```ocaml
(* Inefficient: map f (filter p l) *)
(* Efficient: filter_map (trans_pred f p) l *)

let trans_pred f p x = if p x then Some (f x) else None
let rec filter_map tp l = match l with
  | [] -> []
  | x::xs -> match tp x with Some y -> y::filter_map tp xs | None -> filter_map tp xs
```

### Physics/Real-World Modeling
**Exam loves**: Variant types with realistic scenarios
```ocaml
type object = Static of pos | Dynamic of pos * vel * acc

(* Pattern: Transform each object *)
let simulate_all delta objs = map (simulate delta) objs

(* Pattern: Check any condition *)
let any_collides delta point objs = exists (collides delta point) objs
```

---

## Assignment Summaries

### Assignment 1: Basics
- **Manhattan Distance**: Tuple pattern matching, `abs` function
- **Binomial Coefficient**: Inner helper functions, factorial
- **Lucas Numbers**: Tail recursion with accumulators (like Fibonacci)

### Assignment 2: Unary Numbers & Expressions
- **nat type**: `Z | S of nat` (unary representation)
- **Conversions**: `nat_of_int`, `int_of_nat` with accumulators
- **Addition**: Tail-recursive by "transferring" S constructors
- **Expressions**: Recursive `exp` type with `eval` and `diff`
- **Differentiation**: Pattern matching for derivative rules

### Assignment 3: Church Numerals
Church numerals represent N as a function that applies `s` N times to `z`:
```ocaml
type 'b church = ('b -> 'b) -> 'b -> 'b
let zero = fun s z -> z
let one = fun s z -> s z
let five = fun s z -> s (s (s (s (s z))))
```

**Key implementations** (all one-liners, no recursion!):
```ocaml
let to_int n = n (fun x -> x + 1) 0
let is_zero n = n (fun _ -> false) true
let add n1 n2 = fun s z -> n1 s (n2 s z)
let mult n1 n2 = fun s z -> n1 (n2 s) z
let int_pow_church x n = n (fun a -> a * x) 1
```

### Assignment 4: CPS Tree Operations
```ocaml
type 'a tree = Empty | Tree of 'a tree * 'a * 'a tree

(* Tree depth with CPS and maxk *)
let rec tree_depth_cps t return = match t with
  | Empty -> return 0
  | Tree (l, _, r) ->
      tree_depth_cps l (fun dl ->
        tree_depth_cps r (fun dr ->
          maxk dl dr (fun m -> return (1 + m))))

(* Preorder traversal with CPS *)
let rec traverse_cps t return = match t with
  | Empty -> return []
  | Tree (l, x, r) ->
      traverse_cps l (fun ll ->
        traverse_cps r (fun rl ->
          return (x :: ll @ rl)))
```

---

## Quick Reference: Common Patterns

### Tail-Recursive with Accumulator
```ocaml
let f input =
  let rec helper input acc =
    match input with
    | base_case -> acc
    | recursive_case -> helper (smaller) (combine current acc)
  in
  helper input initial_value
```

### CPS Translation
```ocaml
let rec f_cps input return =
  match input with
  | base_case -> return base_value
  | recursive_case ->
      f_cps smaller_input (fun result ->
        return (combine current result))
```

### CPS with Two Recursive Calls
```ocaml
let rec f_cps input return =
  match input with
  | base_case -> return base_value
  | recursive_case ->
      f_cps first_recursive (fun r1 ->
        f_cps second_recursive (fun r2 ->
          return (combine r1 r2)))
```

---

## Study Tips

1. **Practice tracing**: Step through function calls by hand
2. **Understand types**: If you know the type, you often know the implementation
3. **Master pattern matching**: It's the core of OCaml programming
4. **Accumulator intuition**: Think "what partial result am I building up?"
5. **CPS intuition**: Think "what do I do with the result once I have it?"

## Exam Success Strategies

### For Type Questions
- Always start with most general type (`'a`, `'b`)
- Trace function applications step-by-step
- Watch for polymorphism opportunities
- Common answer: `('a -> 'b) -> 'a list -> 'b list` patterns

### For Implementation Questions
- **Tail recursion**: Use accumulator pattern (90% of cases)
- **CPS**: Nested continuations for multiple recursive calls
- **Pattern matching**: Exhaust all cases, use `_` carefully
- **filter_map**: Very common, memorize the pattern

### For Debugging Questions
- Look for: missing `rec`, wrong constructors, type conflicts
- Remember: Pattern variables bind, they don't check equality
- Check: Are all cases handled? Are types consistent?

### Time Management
- **CPS questions**: Often worth most points, budget time accordingly
- **Type inference**: Work systematically, don't guess
- **Tail recursion**: Follow the accumulator recipe mechanically
