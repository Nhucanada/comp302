# Assignment 4 - Design Documentation

## Overview
This document details the design choices and lesson material used for each problem in Assignment 4, which covers Continuation Passing Style (CPS) transformations of recursive tree functions.

---

## Background: Continuation Passing Style (CPS)

CPS is a technique for making any function tail-recursive by:
1. Introducing a continuation parameter (often called `return` or `k`)
2. Calling the continuation instead of returning values directly
3. Moving any work that happens after recursive calls into expanded continuations

The key insight is that the continuation represents "what to do next" with the result.

### Tree Type Definition
```ocaml
type 'a tree = Empty | Tree of 'a tree * 'a * 'a tree
```
- `Empty` represents an empty tree (leaf marker)
- `Tree (l, x, r)` represents a node with value `x`, left subtree `l`, and right subtree `r`

---

## Question 1: Tree Depth (CPS)

### Problem
Convert the recursive tree depth function to CPS, using `maxk` instead of `max`.

### Original Non-CPS Implementation
```ocaml
let rec tree_depth (t : 'a tree) =
  match t with
  | Empty -> 0
  | Tree (l, _, r) -> 1 + max (tree_depth l) (tree_depth r)
```

### CPS Implementation
```ocaml
let rec tree_depth_cps (t : 'a tree) (return : int -> 'r) : 'r =
  match t with
  | Empty -> return 0
  | Tree (l, _, r) ->
      tree_depth_cps l (fun dl ->
        tree_depth_cps r (fun dr ->
          maxk dl dr (fun m -> return (1 + m))))
```

### Design Choices
1. **Base case**: For `Empty`, call `return 0` instead of returning `0` directly
2. **Nested continuations**: Each recursive call builds a continuation that:
   - First computes left subtree depth (`dl`)
   - Then computes right subtree depth (`dr`)
   - Uses `maxk` to find the maximum in CPS style
   - Adds 1 and calls the outer continuation
3. **Using `maxk`**: The `maxk` function has signature `int -> int -> (int -> 'r) -> 'r`, taking two values and a continuation, returning the result of calling the continuation on the larger value

### Algorithm Trace
For `Tree (Tree (Empty, 2, Empty), 1, Empty)`:
```
tree_depth_cps (Tree (Tree (Empty, 2, Empty), 1, Empty)) id
→ tree_depth_cps (Tree (Empty, 2, Empty)) (fun dl -> ...)
  → tree_depth_cps Empty (fun dl' -> ...)  -- dl' = 0
    → tree_depth_cps Empty (fun dr' -> ...)  -- dr' = 0
      → maxk 0 0 (fun m -> return (1 + m))  -- m = 0
        → return 1  -- depth of inner tree
  → dl = 1
→ tree_depth_cps Empty (fun dr -> ...)  -- dr = 0
  → return 0
→ maxk 1 0 (fun m -> return (1 + m))  -- m = 1
  → return 2  -- final depth
```

### Lesson Material Used
- **Lesson 8 (l8.ml)**: CPS translation pattern (lines 24-68)
  - Step 1: Introduce continuation parameter
  - Step 2: Call continuation where original returned
  - Step 3: Move post-recursive work into expanded continuation
- **Lesson 8 (l8.ml)**: Nested CPS for tree structures (similar to `eval` on expression trees, lines 354-358)

---

## Question 2: Preorder Tree Traversal (CPS)

### Problem
Convert the preorder traversal function to CPS. Preorder visits: node first, then left subtree, then right subtree.

### Original Non-CPS Implementation
```ocaml
let rec tree_traverse (t : 'a tree) = 
  match t with
  | Empty -> []
  | Tree (l, x, r) -> x :: tree_traverse l @ tree_traverse r
```

### CPS Implementation
```ocaml
let rec traverse_cps (t : 'a tree) (return : 'a list -> 'r) : 'r =
  match t with
  | Empty -> return []
  | Tree (l, x, r) ->
      traverse_cps l (fun ll ->
        traverse_cps r (fun rl ->
          return (x :: ll @ rl)))
```

### Design Choices
1. **Base case**: For `Empty`, call `return []` instead of returning `[]` directly
2. **Preorder order preserved**: The node value `x` is placed first in the result list
3. **Nested continuations**: Build continuations that:
   - First traverse left subtree, getting `ll`
   - Then traverse right subtree, getting `rl`
   - Combine as `x :: ll @ rl` (node, then left results, then right results)
   - Call continuation with combined result
4. **List concatenation**: Uses `@` to join lists (allowed per instructions)

### Algorithm Trace
For `Tree (Tree (Empty, 2, Empty), 1, Tree (Empty, 3, Empty))`:
```
traverse_cps (Tree (..., 1, ...)) id
→ traverse_cps (Tree (Empty, 2, Empty)) (fun ll -> ...)
  → traverse_cps Empty (fun ll' -> ...)  -- ll' = []
    → traverse_cps Empty (fun rl' -> ...)  -- rl' = []
      → return (2 :: [] @ [])  -- returns [2]
  → ll = [2]
→ traverse_cps (Tree (Empty, 3, Empty)) (fun rl -> ...)
  → (similarly) returns [3]
  → rl = [3]
→ return (1 :: [2] @ [3])  -- returns [1; 2; 3]
```

### Lesson Material Used
- **Lesson 8 (l8.ml)**: CPS translation for recursive functions (lines 70-96)
- **Lesson 8 (l8.ml)**: `map_cps` and `filter_cps` patterns showing how to handle list-returning functions in CPS
- **Lesson 6 (l6.ml)**: List operations and `@` (append) function

---

## Summary of Lesson Concepts Applied

| Concept | Lessons | Application |
|---------|---------|-------------|
| CPS Translation | L8 | Both functions converted to CPS |
| Continuation as HOF | L6, L8 | Continuations are higher-order functions |
| Nested Continuations | L8 | Tree structure requires nested CPS calls |
| Tail Recursion via CPS | L8 | All recursive calls are in tail position |
| Tree Recursion | L4 | Pattern matching on tree type |

---

## CPS Translation Pattern Summary

The general CPS translation follows these steps:

1. **Add continuation parameter**: `f x` becomes `f_cps x return`

2. **Base case**: Replace `return value` with `return value`
   ```ocaml
   (* Before *) | Empty -> 0
   (* After *)  | Empty -> return 0
   ```

3. **Recursive case**: Nest recursive calls in continuations
   ```ocaml
   (* Before *) 
   | Tree (l, x, r) -> 1 + max (f l) (f r)
   
   (* After *)
   | Tree (l, x, r) ->
       f_cps l (fun result_l ->
         f_cps r (fun result_r ->
           return (1 + max result_l result_r)))
   ```

4. **Using CPS helper functions**: Replace `max` with `maxk`
   ```ocaml
   maxk result_l result_r (fun m -> return (1 + m))
   ```

---

## Test Case Design

### tree_depth_cps Tests
| Test Case | Expected | Description |
|-----------|----------|-------------|
| `Empty` | 0 | Empty tree |
| `Tree (Empty, 1, Empty)` | 1 | Single node |
| Left child only | 2 | Tests left recursion |
| Right child only | 2 | Tests right recursion |
| Balanced tree | 2 | Both subtrees |
| Left-heavy tree | 3 | Deeper left path |
| Asymmetric tree | 3 | Tests max selection |

### traverse_cps Tests
| Test Case | Expected | Description |
|-----------|----------|-------------|
| `Empty` | `[]` | Empty tree |
| Single node | `[1]` | Base case with value |
| Example 2 | `[1; 2; 3]` | From instructions |
| Example 3 | `[1; 2; 4; 5; 3]` | From instructions |
| Left child only | `[1; 2]` | Preorder with left |
| Right child only | `[1; 3]` | Preorder with right |

All tests use the identity continuation `id` (added via `insert_test_continuations`).
