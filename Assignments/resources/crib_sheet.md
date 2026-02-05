# COMP 302 Crib Sheet (One Page)

## CPS Translation (Most Important!)

**Recipe**: Add continuation `return`, call it instead of returning, nest recursive calls

```ocaml
(* ORIGINAL *)                    (* CPS *)
let rec f x = match x with        let rec f_cps x return = match x with
| base -> v                       | base -> return v
| step -> op (f smaller)          | step -> f_cps smaller (fun r -> return (op r))
```

**Two recursive calls** (trees): Nest continuations
```ocaml
f_cps left (fun l_result ->
  f_cps right (fun r_result ->
    return (combine l_result r_result)))
```

**Types**: `input -> output` becomes `input -> (output -> 'r) -> 'r`

**Initial call**: Use identity `(fun x -> x)` as continuation

---

## Church Numerals

`type 'b church = ('b -> 'b) -> 'b -> 'b` — N applies `s` N times to `z`

| Function | Implementation | Idea |
|----------|---------------|------|
| `to_int n` | `n (fun x -> x+1) 0` | Count increments |
| `is_zero n` | `n (fun _ -> false) true` | Any application → false |
| `add n1 n2` | `fun s z -> n1 s (n2 s z)` | Apply n2, then n1 more |
| `mult n1 n2` | `fun s z -> n1 (n2 s) z` | Compose: (apply s n2 times) n1 times |
| `pow x n` | `n (fun a -> a*x) 1` | Multiply by x, n times |

**Key**: No recursion! Use the numeral's built-in iteration.

---

## Higher-Order Functions

```ocaml
(* Map: transform each element *)
let rec map f l = match l with [] -> [] | x::xs -> f x :: map f xs

(* Filter: keep elements satisfying predicate *)
let rec filter p l = match l with [] -> []
  | x::xs -> if p x then x :: filter p xs else filter p xs

(* Fold right: collapse list with function *)
let rec fold_right f l e = match l with [] -> e | x::xs -> f x (fold_right f xs e)

(* Express map/filter via fold_right *)
let map f l = fold_right (fun x ys -> f x :: ys) l []
let filter p l = fold_right (fun x ys -> if p x then x::ys else ys) l []
```

---

## Tail Recursion

**Tail call** = recursive call is the LAST operation (no work after)

**Accumulator pattern**:
```ocaml
let f x = 
  let rec helper x acc = match x with
    | base -> acc                        (* Return accumulator *)
    | step -> helper smaller (update acc) (* Update BEFORE recursing *)
  in helper x initial
```

**Fibonacci TR**: `fib_tr n a b = if n=0 then a else fib_tr (n-1) b (a+b)`

---

## Types & Pattern Matching

```ocaml
type 'a option = None | Some of 'a        (* Success/failure *)
type 'a list = [] | (::) of 'a * 'a list  (* Recursive list *)
type 'a tree = Empty | Node of 'a tree * 'a * 'a tree
```

**Pattern rules**:
- `_` = wildcard (matches anything)
- Variables in patterns create NEW bindings (don't check equality)
- Use `when` guards for conditions: `| (a,b) when a=b -> ...`
- Wrap nested `match` in parentheses!

---

## Type Inference

1. Assign type vars to params: `x:'a`, `y:'b`
2. Constraints from operations: `x+1` means `x:int`
3. Return type = type of body

**Polymorphic**: `'a -> 'a` (identity), `'a -> 'b -> 'a` (const)

---

## Key Operators

| Int | Float | String | List |
|-----|-------|--------|------|
| `+ - * / mod` | `+. -. *. /.` | `^` (concat) | `::` (cons), `@` (append) |

**List syntax**: `[1;2;3]` = `1::2::3::[]` (semicolons, not commas!)

---

## CPS Examples

```ocaml
(* Tree depth with maxk *)
let rec depth_cps t k = match t with
  | Empty -> k 0
  | Node(l,_,r) -> depth_cps l (fun dl ->
                     depth_cps r (fun dr ->
                       maxk dl dr (fun m -> k (1+m))))

(* Preorder traversal *)
let rec traverse_cps t k = match t with
  | Empty -> k []
  | Node(l,x,r) -> traverse_cps l (fun ll ->
                     traverse_cps r (fun rl ->
                       k (x :: ll @ rl)))
```

---

## Quick Formulas

- **Tail-rec fib**: `fib n a b` where `a=F(i)`, `b=F(i+1)`, init `(n,0,1)`
- **Church add**: First apply n2, then n1 more: `n1 s (n2 s z)`
- **Church mult**: Compose applications: `n1 (n2 s) z`
- **CPS type**: Add `(original_return -> 'r) -> 'r` to signature
- **fold_right**: `f` takes element + recursive result, `e` is base case
