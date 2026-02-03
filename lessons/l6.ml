(*
RECALL constructors of lists:
  - [] (nil) takes no arguments, constructs a list of type 'a list
  - x :: xs (cons), takes two arguments:
    - x : 'a
    - xs : 'a list
    - so x :: xs : 'a list
*)

let rec append1 (y : 'a) (l : 'a list) =
  match l with
  | [] -> [y] (* alternatively: y :: [] *)
  | x (* elm on the front *) :: xs (* the rest of the list *) ->
      x :: append1 y xs
      (* 1. append y onto the end of xs, then 2. stick x onto the front of that *)

(* tracing: append1 3 [1;2]
  append1 3 (1 :: (2 :: [])) -- rewriting list sugar into cons and nil
  1 :: append1 3 (2 :: [])
  1 :: (2 :: append1 3 [])
  1 :: (2 :: (3 :: []))
  [1;2;3] -- rewriting back into list sugar
*)

(* reversing a list: naive implementation *)
let rec rev (l : 'a list) : 'a list =
  match l with
  | [] -> []
  | x :: xs -> append1 x (rev xs)
  (* 1. reverse the rest of the list, then 2. stick `x` onto the end of that. *)

(* rev: optimized implementation, tail-recursive too. *)
let rev l =
  let rec rev_tr (l : 'a list) (acc : 'a list) : 'a list =
    match l with
    | [] -> acc
    | x :: xs -> rev_tr xs (x :: acc)
  in
  rev_tr l []

(* How does rev_tr work? Let's trace it.
   rev_tr [1;2;3] []
   rev_tr (1 :: 2 :: 3 :: []) []   -- rewrite list sugar into cons and nil
   rev_tr (2 :: 3 :: []) (1 :: [])
   rev_tr (3 :: []) (2 :: 1 :: [])
   rev_tr [] (3 :: 2 :: 1 :: [])
   (3 :: 2 :: 1 :: [])

   An intuition for why this works is to remember a linked list can function like a _stack_.
   We pass one stack holding 3,2,1 (3 is on top, this is the 'input stack') and one empty stack
   (the 'output stack') to `rev_tr`.

   Then, we pop each item off the 'input stack' and push it onto the 'output stack'.
   Visually, the stacks evolve like this:

    3                               1
    2         2           2         2
    1         1 3       1 3         3
    - -  -->  - -  -->  - -  -->  - -
*)

(* THEORY: function applications; partial applications.

   general principle of function application: If `f : A -> B` and `a : A`, then `f a : B`.
   Function application is _left-associative,_ so in the absence of explicit parentheses,
   `f a b` is really `(f a) b`.

   All functions of 'multiple inputs' are in reality functions that return functions.
   To see this, assume `f : A -> B -> C`, `a : A`, and `b : B`.
   Recall that arrow-type is right-associative, so `f : A -> (B -> C)`.
   Next, apply the general principle of function application above to the innermost application
   `f a`. Since `f : A -> (B -> C)` and `a : A`, we have `f a : B -> C`.
   Then, zooming out to `(f a) b`, we are applying the function computed from `f a` to the value
   `b`, so `(f a) b : C`. *)

(* SYNTAX SUGAR: function definitions

   So far we defined functions like `let f x = ...`. This is actually sugar for _binding_ `f` to a
   function-expression: `let f = fun x -> ...`
   In other words, the _primitive_ way of constructing a function is using a fun-expression, and
   the _primitive_ `let`-expression always just binds a name to (the value computed from) an
   expression. The syntax `let f x = ...` is syntax sugar for using both primitive syntaxes
   together.
*)

(* An essential higher-order function: composition *)
let compose f g = fun x -> f (g x)
(* I chose to write this function as `let compose f g = fun x -> ...` to emphasize the main
   use-case for this function: input two functions to obtain one function.
   Although we could call compose as `compose f g x`, providing all three inputs at once, why would
   we? This just does `f (g x)`, which we could have simply done directly, without an unnecessary
   detour through the `compose` function. *)

(* compose : ('b -> 'c) -> ('a -> 'b) -> ('a -> 'c)

    Working out the type of `compose` can take some time, but make sure that you can do it, by
    following the process from last class's lecture notes. *)

(* Of course, nothing is stopping us from equivalently writing the definition like this instead: *)
let compose = fun f -> fun g -> fun x -> f (g x)

(* Also equivalently, we can collapse multiple nested `fun`-expressions: *)
let compose = fun f g x -> f (g x)
(* That's just more syntax sugar. *)

(* Example: composing two arithmetic functions: increment and double *)
let h = compose (fun x -> x + 1) (fun x -> x * 2)
(* ^ also an example of using the fun-syntax to pass (anonymous) functions to another function. *)

(* What should `h` do? `h 3` should double `3`, and then add one, giving `7`.
   Let's work this out step by step starting with a trace of the application of `compose`:
        compose (fun x -> x + 1) (fun x -> x * 2)

   First, let's replace `compose` with its definition:
       `(fun f -> fun g -> fun x -> f (g x)) (fun x -> x + 1) (fun x -> x * 2)`

   We need to substitute:
    - (fun x -> x + 1) for `f` in the body of `compose`; and
    - (fun x -> x * 2) for `g` in the body of `compose`.

   Let's do this step by step. Function application is _left-associative_, so we start with the
   leftmost application.

    (fun f -> fun g -> fun x -> f (g x)) (fun x -> x + 1) (fun x -> x * 2)
    ----------------------------------------------------- subst (fun x -> x + 1) for f
    (fun g -> fun x -> (fun x -> x + 1) (g x)) (fun x -> x * 2)
    ----------------------------------------------------------- subst (fun x -> x * 2) for g
    fun x -> (fun x -> x + 1) ((fun x -> x * 2) x)

This gives:

  fun x -> (fun x' -> x' + 1) ((fun x'' -> x'' * 2) x)
  ^        ^- used to be `f`   ^- used to be `g`
  |- and the outcome is itself a function, of one input
  (And I renamed the bound variables to be unique for readability.)

  AND THAT'S IT. No further evaluation occurs. OCaml does not evaluate _under a `fun`_.
  It would be really strange if the bodies of functions were evaluated before we called those
  functions!!!

  Now, for our own _understanding_ we can simplify inside the function.
  Underlining is used to specify which part I'm evaluating

  fun x -> (fun x' -> x' + 1) ((fun x'' -> x'' * 2) x)
                              ------------------------ subst `x` for `x''` in the body
  fun x -> (fun x' -> x' + 1) (x * 2)
           -------------------------- subst `x * 2` for `x'` in the body
  fun x -> (x * 2) + 1

  No further simplification is possible.
  And does this function, applied to `3`, give seven?

  (fun x -> (x * 2) + 1) 3
  ------------------------ subst 3 for `x` in the body
  (3 * 2) + 1
  -------
  6 + 1
  -----
  7

  Yay :)

  IMPORTANT: function application is always just written with a space.
  You're used to seeing a _named_ function applied to an input, e.g. `rev [1;2;3]`,
  but we can also apply an _anonymous_ function to an input,
  e.g. `(fun x -> x * 2 + 1) 3`.

  BE CAREFUL ABOUT THE SUBSTITUTION. It happens _in the body_ of the fun-expression.

  THIS RESULT IS WRONG: `fun 3 -> 3 * 2 + 1` !
  This would be a function expecting one int as input, pattern-matching on it to check that it's
  exactly `3`, and then returns `7`. That's a very weird function!
*)

(* A few more examples of basic higher-order functions: *)

(* HOF that applies a function twice on an input. *)
let twice f x = f (f x)

let double x = x * 2

let quadruplicate x = twice double x
(* EXERCISE: trace and simplify to prove that this actually computes `x * 4` *)

(* Another, equivalent way of defining quadruplicate as above: *)
let quadruplicate = twice double
(* This time, omitting the parameter `x` entirely.
   This says that 'quadruplicate' is what you get back from 'twice double',
   which is going to be the function `fun x -> double (double x)`.

   To see this, view the definition of `twice` as a function of one input returning a function of
   the next input:
      let twice f x = f (f x)
   rewriting:
      let twice f = fun x -> f (f x)

   then, `twice double` = `fun x -> double (double x)`
   since we substitute `double` for `f` in the body of `twice`.
*)

(* Generalizing `twice` to a HOF that applies a function N times. *)
let rec times n f x =
  if n = 0 then x else f (times (n-1) f x)

(* EXERCISE: trace and simplify `times 2 f` to see that it equals `twice f` for any function `f` *)

(* EXERCISE: implement integer exponentiation (`pow`) using a single call to `times`,
   and a judicious choice of inputs to `times`. *)

let pow (n : int) (k : int) : int =
  failwith "exercise"
(* such that `pow n k` computes `n^k`.

   If you're stuck, think about how you'd define `pow` recursively (or even write it that way to
   start), then see how that program's structure matches the structure of `times` itself.
   From that, recover what to use for the function `f` and the initial input `x`. *)

(* CHALLENGE EXERCISE:
    We haven't covered proofs about programs in the course yet, but can you try to prove, by
    induction on `n`, the following lemma?

    Lemma. For any n:int >= 0, f : 'a -> 'a, and x : 'a, we have
      f (times n f x) = times n f (f x)

    In the base case assume `n = 0` and prove the equality.

    In the step case,
      assume: `forall f: f (times n f x) = times n f (f x)` for some n ---- (induction hypothesis)
      then show: `forall f: f (times (n+1) f x) = times (n+1) f (f x)`

    The proof is mostly straightforward, but does require one ah-ha moment.
    Consider that the induction hypothesis `forall f: f (times n f x) = times n f (f x)`
    says "forall f", meaning that you can consider a _different_ function to be on the outside than
    the `f` of the theorem itself, for the purposes of applying the IH.

    If you can't prove this, that's fine -- we'll cover this material in depth later.
    This is just a preview. *)

(* Tail-recursive variation:
    Idea: use `x` itself as an accumulator. *)
let rec times_tr n f x =
  if n = 0 then x else times_tr (n-1) f (f x)

(* EXAMPLE: revisiting fibonacci *)

(* Early on, we saw the fast, tail-recursive algorithm for computing the nth item in the fibonacci
   sequence. (By the way, that algorithm uses a technique called _dynamic programming,_ covered in
   COMP 251.) *)

let fib n =
  let rec go n a b =
    if n = 0 then a else go (n-1) b (a+b)
  in
  go n 0 1

(* Notice that this algorithm fits the pattern of "do a thing n times to a starting value".
   Specifically, what's repeated `n` times is this action: a, b -> b, a+b
   We can refactor this implementation of `fib` into a single call to `times`, which we will
   instruct to perform that action `n` times by representing it as a function. *)

let fib n = times_tr n (fun (a, b) -> (b, a+b)) (0, 1)

(* The only catch is that we needed to introduce some tuples, since `times` wants a function of the
   form `'a -> 'a`, that is a function of one input that returns something of the same type.

   OBSERVATION: when we call a polymorphic function, we get to decide the _instantiation_ for the
   type variables. By passing `(0, 1)` as the starting value, we _instantiate_ the type variable
   'a = int * int. We can choose any type we like, by passing corresponding values of that type.

   Yes, we could even instantiate 'a to be a function type, provided that we pass in a function as
   an initial value, and a transformation of functions as the function `f`. *)

(*** HIGHER-ORDER FUNCTIONS ON LISTS ***)

(* Higher-order functions and polymorphism, taken together, allow us to express
   _generic algorithms._ An extremely common thing to do to a list is to apply
   some operation to each element and collect the results in another list.
   That operation can be represented as a function, and taken as an input to
   our generic traversal. *)

(* Here is this generic traversal: it applies a given function to each element
   of a given list, collecting the results into a new list. *)
let rec map (f : 'a -> 'b) (l : 'a list) : 'b list =
  match l with
  | [] -> []
  | x :: xs -> f x :: map f xs
  (* The order of operations is:
      1. compute `f x`, say to some `y`
      2. compute `map f xs`, say to some `ys`
      3. form the cons-cell `y :: ys` *)

(* Example trace. First let double x = x * 2

   1. map double [1;2;3]
   2. map double (1 :: (2 :: (3 :: [])))      -- rewriting syntax sugar
   3. double 1 :: map (2 :: (3 :: []))        -- step case of `map`
   4. 2 :: map double (2 :: (3 :: []))        -- evaluate `double`
   5. 2 :: (double 2 :: map double (3 :: [])) -- step case of `map`
   6. 2 :: (4 :: map double (3 :: []))        -- evaluate `double`
   7. 2 :: (4 :: (double 3 :: map double [])) -- step case of `map`
   8. 2 :: (4 :: (6 :: map double []))        -- evaluate `double`
   9. 2 :: (4 :: (6 :: []))                   -- base case of `map`
   10. [2; 4; 6]                              -- rewriting syntax sugar

Of course, there was no need to separately define `double`.
We could have instead written: `map (fun x -> x * 2) [1;2;3]` *)

(* Another extremely common thing we do with lists is find all elements satisfying
   some property. For example, in a business, we might want to find all the clients
   with overdue payments. In school, we might want to find all students with GPAs
   above or below some threshold. In a game, we might want to find all projectiles
   that are currently colliding with a certain target.

   In each of those scenarios, we have a large list we would like to _filter_ down to just those
   values satisfying a particular property:
   1. In the business, the list is "all the clients" and the property is
      "the client's balance is overdue"
   2. In the school, the list is "all the students" and the property is
      "the student's GPA is above/below some cutoff"
   3. In the game, the list is "all the projectiles" and the property is
      "the projectile collides with a certain target"

In each case, the property can be modeled as a function taking as input one element from the list,
and outputting a boolean, saying whether to select or drop that element.
That gives rise to the following generic traversal: *)

let rec filter (p : 'a -> bool) (l : 'a list) : 'a list =
  match l with
  | [] -> []
  | x :: xs -> if p x then x :: filter p xs else filter p xs

(* In the step case, check if the element `x` at the front of the list satisfies the property `p`.
   More concretely, apply the function `p` to `x` and to see if it returns `true`.
   If so, then filter the rest of the list, and then add `x` to the front. (Since x was 'good'.)
   If not, then filter the rest, and simply ignore `x`. (Since x was 'bad'.) *)

(* Example trace:
  let is_even x = (x mod 2 = 0)

  1. filter is_even [1;2;3]
  2. filter is_even (1 :: (2 :: (3 :: [])))     -- rewrite sugar
  3. if is_even 1                               -- step case of filter
     then 1 :: filter is_even (2 :: (3 :: []))
     else filter is_even (2 :: (3 :: []))
  4. if false then ... else ...                 -- evaluate `is_even 1`
  5. filter is_even (2 :: (3 :: []))            -- select `else`-branch of conditional expression
  6. if is_even 2 then ... else ...             -- step case of filter
  7. if true then 2 :: filter (3 :: []) else ... -- evaluate `is_even 2`
  8. 2 :: filter (3 :: [])                      -- select `then`-branch of conditional expression
  9. 2 :: (
      if is_even 3
      then 3 :: filter is_even []
      else filter is_even []
    )                                                 -- step case of `filter`
  10. 2 :: (if false then ... else filter is_even []) -- evaluate `is_even 3`
  11. 2 :: (filter is_even [])                        -- select `else`-branch
  12. 2 :: []                                         -- base case of `filter`
  13. [2]                                             -- rewrite syntax sugar
*)

(* A even more primitive higher-order function on lists. *)
(* ----------------------------------------------------- *)

(* Both map and filter follow a similar pattern, which becomes clear if we rewrite them a bit. *)

let rec filter p l = match l with
  | [] -> []
  | x::xs ->
      let ys = filter p xs in
      if p x then x::ys else ys

let rec map f l = match l with
  | [] -> []
  | x::xs ->
      let ys = map f xs in
      f x :: ys

(* What these equivalent ways of implementing `map` and `filter` have in common is that they
   unconditionally and immediately compute the recursive call before proceeding to do something
   with the result of the recursive call _and_ with the element `x` at the front of the list.

   In `map`, we're applying `f` to `x` and sticking the result onto the front of the result `ys` of
   the recursive call.
   In `filter`, we're checking whether `p x` and if so sticking `x` onto the front of the result
   `ys` of the recursive call.

   We can implement a higher-order function that captures the following pattern of recursion on
   lists:
   - in the base case, return a fixed value
   - in the step case, apply a function to the list's head element `x` and to the result of the
     reucurve call.

   This higher-order function is standard, and is called `fold_right`. *)

let rec fold_right (f : 'a -> 'b -> 'b) (l : 'a list) (e : 'b) : 'b =
  match l with
  | [] -> e
  | x::xs -> f x (fold_right f xs e)

(* We can think of `fold_right` as 'collapsing' the list down into some other type `'b` (of our
   choosing!). In the case of `map` and `filter`, the type `'b` will be some kind of list, but you
   can see from its type that `fold_right` is more general. *)

(* We recover `map` in terms of `fold_right` like this. *)

let map f l = fold_right (fun x ys -> f x :: ys) l []

(* We recover `filter` in terms of `fold_right` like this. *)

let filter p l = fold_right (fun x ys -> if p x then x :: ys else ys) l []

(* To illustrate the generality of `fold_right`, let's also implement `sum : int list -> int`, to
   add up all the elements of a list. *)

let sum l = fold_right (fun x y -> x + y) l 0

(* Of course, `sum` follows the exact same pattern, which we can see by writing it like this: *)

let rec sum l = match l with
  | [] -> 0 (* return a fixed value in the base case *)
  | x::xs ->
      let y = sum xs in
      x + y

(* EXAMPLES: working with lists and options together *)

(* Recall the type of 'optional values' that we use especially to represent failures. *)

(* type 'a option =
    | None
    | Some of 'a

In a comment, because it's already defined in the OCaml standard library and imported by default.*)

(* Now we can implement all kinds of searching procedures on lists. *)

(* Finds the first element of `l` satisfying `p` *)
let rec find (p : 'a -> bool) (l : 'a list) : 'a option =
  match l with
  | [] -> None
  | x::xs -> if p x then Some x else find p xs

(* CHALLENGE: How about finding the last element satisfying `p`?
   This is harder. Can you find both a tail-recursive and a non-tail-recursive way to do it? *)

(* In general, we can think of the function type `'a -> 'b option` as being a 'transformation from
   'a to 'b that might fail.' In light of this understanding, we can implement a variation on
   `find`, which, rather than find the first item in the list _satisfying_ `p`, finds the first
   item in the list that can be successfully transformed into something of type `'b`. *)

let rec first_transformable (f : 'a -> 'b option) (l : 'a list): 'b option =
  match l with
  | [] -> None
  | x::xs -> match f x with (* check if `f x` by pattern matching on its output *)
    | None -> first_transformation f xs
    | Some y -> Some y
