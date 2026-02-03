(* CONTINUATION-PASSING STYLE (CPS): rewriting any function to be tail-recursive. *)

(* Key idea: introduce a _higher-order_ accumulator, to store pending _operations_ to be done after
   the recursive call. *)

(* We saw this function which is not TR. *)
let rec append l1 l2 = match l1 with
  | [] -> l2
  | x :: xs -> x :: append xs l2

(* Aside: we _could_ make it TR by cleverly using `rev`, but then we pay a time penalty by
   traversing the list `l1` twice. *)
let rec rev l acc = (* tail-recursive rev *)
  match l with
  | [] -> acc
  | x :: xs -> rev xs (x::acc)

let append l1 l2 = (* clever TR append using rev, but with penalty of 2x traversal *)
  rev (rev l1 []) l2
(* ^ This append exploits the fact that `rev` is more general than just 'reverse a list'.
   It's actually 'prepend elements of a list in reverse onto another list' -- that other list
   is the initial accumulator. *)

(* Instead, let's rewrite `append` to be TR by using _continuation-passing style_ (CPS).
   This will bring back being able to do append in a single pass through the list,
   and avoid any trickery involving reverse. *)
let rec append_cps l1 l2 return = (* 1. Introduce the accumulator, called `return` ... *)
  match l1 with
  | [] -> return l2
    (* 2. ^ Call the `return` function in any position where the original function returned smth *)
  | x :: xs -> append_cps xs l2 (fun ys -> return (x::ys))
    (* 3. ^ When making a rec call, any work that happened _after_ the rec call is moved into a
       'new' accumulator, constructed with `fun`.
       Specifically, two things happened after the rec call:
            a. cons `x` onto the result of the rec call
                -- the result of the rec call is represented as the input, `ys`, of the new
                accumulator
            b. return the result of consing. *)

(* Confirm that `append_cps` is TR:
    - The only recursive call appears on the line above '3.'
    - It's a tail-call: the result of the rec call itself is immediately returned. *)

(* TERMINOLOGY: this higher-order accumulator, named 'return', is called a _continuation._

   The name 'return' is not special, and in OCaml 'return' is NOT a keyword.

   I chose to call the continuation 'return' because conceptually, it performs the action of
   returning from the function. As we study how 'append_cps' works, I hope that you will see the
   connection between calling the continuation and returning.
*)

(* Translation into continuation-passing style (CPS) is _completely mechanical:_ one could
   write a _program_ that rewrites any OCaml program into CPS.
   This way of programming is called CPS because in this style, we equip _every_ function we write
   with a continuation parameter, so we are passing a continuation in every function call.

   This is a laborious way of actually writing code as a human!
   But compilers for functional programming languages use CPS as an intermediate representation of
   the program being compiled.
   The reason for this is that in the CPS form, **control flow is completely explicit,**
   including control operations such as returning. *)

(* RECAP OF THE CPS TRANSLATION:
    To translate _any function_ into CPS:
        1. Introduce a new parameter, the continuation.
        2. In every position where the original program returned, call the continuation.
        3. Any work that happens after a recursive call is moved into an expanded continuation. *)

(* EXERCISE: translate the following programs to be TR using CPS. *)

let rec map f l = match l with
  | [] -> []
  | x :: xs -> f x :: map f xs
    (* ^ On this line you have a choice: does `f x` happen before, or after, `map f xs`?
       (The OCaml specification does not fix a particular evaluation order on the arguments to
       constructors.)
       When you translate to CPS you have to decide exactly what order these happen in.
       Do the translation twice, once for each possible order. *)

let rec filter p l = match l with
  | [] -> []
  | x :: xs -> if p x then x :: filter p xs else filter p xs

    (* ^ Here, there is no choice: `filter p xs` definitely happens _after_ `p x`, due to the
       semantics of `if-then-else.
       However, we can consider this alternative implementation of `filter`, which does things in a
       different order, but is equivalent: *)

let rec filter p l = match l with
  | [] -> []
  | x :: xs ->
      let ys = filter p xs in
      if p x then x :: ys else ys

(* You should translate both such implementations of `filter` to see the difference. *)

(* #1. OPERATIONAL ANALYSIS OF `append_cps` -- how does it execute? *)

(* Trace: append_cps [1;2] ls ???
   ---- oh wait, we need to choose an initial value for the continuation!
   For now, let's let the initial continuation be an unknown `k`.
   We'll decide what to use as a value for `k` at the end of the trace.

   (We use a symbolic `ls` for for the second input of `append_cps` because the function only
   examines the first input.)

   Trace: append_cps [1;2] ls k

   1. append_cps (1::2::[]) ls k                    -- desugaring the list notation
   2. append_cps (2::[]) ls (fun ys -> k (1 :: ys)) -- rewrite following x::xs case of append_cps
   3. append_cps [] ls (fun ys -> (fun ys' -> k (1::ys')) (2::ys)) -- again
   4. (fun ys -> (fun ys' -> k (1::ys')) (2::ys)) ls -- base case: apply continuation to `ls`
   5. (fun ys' -> k (1::ys')) (2::ls)    -- apply: subst `ls` for `ys`
   6. k (1::2::ls)                       -- apply: subst `2::ls` for `ys'`.

   And now, further evaluation would depend on the choice of `k`.
   Since we want this to evaluate to the same output as `append [1;2] ls` (the ordinary
   implementation), i.e. 1::2::ls, we should choose k = (fun x -> x), the identity function.

   With this choice, we get:
   7. (fun x -> x) (1::2::ls) -- rewriting k into (fun x -> x)
   8. 1::2::ls                -- apply: subst 1::2::ls for x
*)

(* #1.1 ANALYSIS OF THE TRACE

    1. the initial continuation `k` is the LAST thing that happens in the trace.
    2. a _stack_ of pending operations is built up in the continuation. On lines 3&4 of the trace,
       when the stack is at its biggest, it consists of the following operations, in this order:
        a. cons 2 onto the front of ___
        b. cons 1 onto the front of ___
        c. apply k onto ___

    This stack of pending operations is _represented_ as the function
        fun ys -> (fun ys' -> k (1::ys')) (2::ys)

    In the base case of `append_cps`, when we actually _call_ the continuation, we "unwind" this
    stack by filling in a value for the topmost blank `___` and cascading the result downwards.
    Conceptually, what's happening is this:

        a. cons 2 onto the front of: ls
        b. cons 1 onto the front of ___
        c. apply k onto ___

        --->

        b. cons 1 onto the front of: 2::ls
        c. apply k onto ___

        --->

        c. apply k onto: 1::2::ls

        --->

        k (1::2::ls)

    What is this stack exactly? It's the call stack!

    In some sense, what we have accomplished with the CPS translation is that we've _taken control
    of the call stack,_ by representing it as a function.

    To see this connection with the call stack, we can look at the same trace, but for the ordinary
    `append` function.

    Trace: append [1;2] ls

    1. append (1::2::[]) ls
    2. 1 :: append (2::[]) ls
    3. 1 :: (2 :: append [] ls)

    At this point, just after step 3, `append [] ls` will return `ls` and all the pending
    operations in the call stack will occur. What are those operations?

    a. cons 2 onto the front of: ____
    b. cons 1 onto the front of: ____
    c. go do whatever the person who called `append [1;2] ls` in the first place wanted

    This analysis is exactly why I mentioned much earlier that 'calling the continuation' and
    'returning' do the same thing: in both cases, we're "unwinding" the call stack. The difference
    is in whether we use our artisanal, handmade, 100% organic call stack in the form of a
    function, or whether we use the built-in, OCaml-managed, industrially produced call stack.
*)

(* #2 PERFORMANCE ANALYSIS OF THE CPS PROGRAM *)

(* - CPS programs are necessarily tail-recursive, and hence operate in O(1) _stack_ space.
   - However, they do need to allocate memory to store these function-objects that _represent_ a
     call stack. It's not enough to just store a pointer to the _code_ of the function, because the
     function also refers to variables that are not its parameters.

    DEFINITION. A bundle consisting of a code pointer together with the values of the variables at
    the time a function is defined is called a _closure._

   It's extremely useful to be able to bundle code together with some values that that code
   operates on. In fact, that's a central idea in object-oriented programming. In OOP, there are
   closures too, but we call them _objects._

   Therefore, the memory usage of a CPS program, in a big-O sense, is equal to the
   memory usage of the original program.
   The difference is in the _kind_ of memory!

   - The original program uses _stack memory_ which is fixed and generally small, ~8 MiB.
   - The CPS program uses _heap memory_ which is dynamic and can grow to entirely fill your
     computer's RAM, ~16~32~64 GiB.
   - The CPS translation does not affect time complexity either, in a big-O sense.
   - Practically speaking, there is constant-factor time penalty for using CPS, because of the heap
     memory allocations that are required for storing the function-objects. *)

(* #3 STATIC ANALYSIS OF THE CPS PROGRAM: what are the types? *)

(* Consider `append_cps` from before. The types of the (original) inputs stay the same. *)

let rec append_cps (l1 : 'a list) (l2 : 'a list) return = match l1 with
  | [] -> return l2 (* (1) *)
  | x :: xs -> append_cps xs (fun ys -> return (x :: ys)) (* (2) *)

(* But what is the type of `return`, and what is the return type of `append_cps`?

   Look at how return is used: we are passing lists to it, namely `l2` (1) and `x :: ys` (2).
   Therefore, its type must look something like: 'a list -> ????

   Next, we can observe that `append_cps` returns whatever `append_cps` returns (2)
   -- this give us no new information.

   Finally, we can observe that `append_cps` returns whatever `return` returns (1)
   -- this establishes that the return type of `return` must equal the return type of `append_cps`
   itself.

   No additional constraints are present. This gives the following type annotations. *)

let rec append_cps (l1 : 'a list) (l2 : 'a list) (return : 'a list -> 'r) : 'r = match l1 with
  | [] -> return l2 (* (1) *)
  | x :: xs -> append_cps xs (fun ys -> return (x :: ys)) (* (2) *)

(* I could have used 'b instead of 'r, but it is common to use 'r for the return type of a CPS
   program, standing for "return" or "result", and to distinguish it from generic type variables
   used for genuine data. *)

(* #3.1 GENERALIZING THE STATIC ANALYSIS

   - The input type of the continuation will always equal the original program's output type.
   - The output type of the continuation will always equal the output type of the generated CPS
     program, and it will always be a type variable, e.g. 'r. *)

(* CPS is a very complicated topic. If you're confused, that's OK.
   Take some time to digest this and ideally talk to one of your peers about it, either in person
   or via Discord.

   The main thing that you will be tested on in regards to CPS is your ability to translate a given
   program into CPS so that it becomes TR. *)

(* #4. SPECIAL USES OF CPS. *)

(* With the ability to explicitly manipulate control flow using continuations, we can express
   certain forms of control flow that were previously _impossible!_

   For example, consider this function to multiply all elements of a list together. *)
let rec product l = match l with
  | [] -> 1
  | x :: xs -> if x = 0 then 0 else x * product xs

(* This function is somewhat optimized. When it encounters a zero, we know that the whole product
   is going to be zero, so we immediately return zero. Unfortunately, this optimization is
   half-assed. Consider the following trace. *)

(* product [1;2;0;3;4]
   = 1 * product [2;0;3;4]
   = 1 * (2 * product [0;3;4])
   = 1 * (2 * 0)
   = 1 * 0
   = 0 *)

(* The optimization saved us from the multiplications of `3` and `4`, but not from the ones for `1`
   and `2` which were already stored in the call stack.

   By rewriting this function into CPS, we can implement a kind of "jump" to bypass those
   multiplications stored on the call stack. *)

(* To begin, we simply translate into CPS: *)
let rec product l return =
  match l with
  | [] -> return 1
  | x :: xs -> if x = 0 then return 0 else product xs (fun y -> return (y * x))

(* This CPS program suffers from the same issue as the initial one.
   If you don't believe me, trace `product [1;2;0;3;4] (fun x -> x)` *)

(* There are two ways `product` is called:
    1. recursive calls, coming from inside the definitino of `product` itself
    2. calls from 'outside'. Someone else gives us a list to multiply, together with an initial
       continuation.

    What we'd like is to remember the initial continuation, so that when we encounter zero, we can
    call _that continuation_ instead of our `return` that we augment with pending operations during
    the loop. To achieve that, we'll wrap the whole thing as an inner helper function, and name it
    `go` this time. *)

let product l return_outside = (* give a distinct name to the outer continuation *)
  let rec go l return =
    match l with
    | [] -> return 1
    | x :: xs ->
        if x = 0 (* when we see a zero... *)
        then return_outside 0 (* directly call the outer continuation! *)
        else go xs (fun y -> return (y * x))
  in
  go l return_outside (* initial continuation of our loop is the outer continuation *)

(* By directly calling the outer continuation `return_outside`, we bypass the pending
   multiplications that are stored in `return`, avoiding ever doing them at all. *)

(* #5. EXERCSIES *)

(* EXERCISE 1: translate the recursive algorithms below into CPS to make them TR. *)

type 'a tree =
  | Empty
  | Node of 'a tree * 'a * 'a tree

(* 1.1 *)

(** Finds all the elements in the tree satisfying a given predicate, collecting them into a list.
    This is like `filter`, but generalized to a tree. *)
let rec find_all (p : 'a -> bool) (t : 'a tree) : 'a list =
  match t with
  | Empty -> []
  | Node (l, x, r) ->
      let ls = find_all p l in
      let rs = find_all p r in
      if p x then ls @ [x] @ rs else ls @ rs
        (* Built-in function (@) which is exactly `append` above, but in operator form. *)

(* 1.2 *)

(* Same idea, but it uses an accumulator to avoid an asymptotic time penalty arising from the
   repeated use of (@). *)
let rec find_all (p : 'a -> bool) (t : 'a tree) (acc : 'a list) : 'a list =
  match t with
  | Empty -> acc
  | Node (l, x, r) ->
      find_all p l x (if p x then x :: find_all p r acc else find_all p r acc)
(* Notice that despite the use of an accumulator, this algorithm is not TR! *)

(* EXERCISE 2: translate the recursive algorithm below into CPS to make it tail-recursive. *)

type exp =
  | Var
  | Lit of float
  | Add of exp * exp
  | Mul of exp * exp

let rec eval (v : float) (e : exp) : float = match e with
  | Var -> v
  | Lit a -> a
  | Add (e1, e2) -> eval v e1 +. eval v e2
  | Mul (e1, e2) -> eval v e1 *. eval v e2

(* CHALLENGE / food for thought: find a _first-order_ way of implementing `eval` tail-recursively
   In other words, the CPS strategy above, which uses higher-order would not be allowed.
   The required technique is related to these:
       - https://en.wikipedia.org/wiki/Reverse_Polish_notation
       - https://en.wikipedia.org/wiki/Stack_machine
*)

(* DM me on Discord for a hint. I'll show you the general technique at the end of the course ;) *)

(* EXERCISE 3: translate this recursive function to CPS to make it TR *)

let rec even (n : int) = (n = 0) || (n > 0) && not (even (n-1))

(* HINT: first rewrite the function to use if-then-else and let-in to make the control flow
   explicit. *)

(* EXERCISE 3.5 *)

(* Can you find a way to rewrite `even` to be TR, using the same idea, without using
   CPS? *)

(* EXERCISE 4: translate these recursive functions to CPS *)

let rec sum n = if n = 0 then 0 else n + sum (n-1) (* remember the first class? *)

let rec sum_tr n acc = if n = 0 then acc else sum_tr (n-1) acc (* remember the second class? *)
(* ^ This algorithm is _already_ TR!
   Yes, we can still translate it to CPS. Something interesting happens (or rather, doesn't happen)
   to the continuation in this case. *)
