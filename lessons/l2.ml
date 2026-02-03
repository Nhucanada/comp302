(* We make top-level definitions using `let`.
   Definitions can define simple values as we saw in lesson 1, but also functions. *)
let greet name = "Hello, " ^ name

(* The _scope_ of the variable `name` is the right-hand side of the equals.
   That is, that's where we're allowed to refer to that variable.

   This is what you would expect, coming from other programming languages such as Python:

   def greet(name):
       return "Hello " + name

   In that Python example, the scope of the variable 'name' is the body of the function. *)

(* Some variations on `greet`. We're in Quebec here, so we must also be able to greet in French. *)

let greet lang name =
  if lang = "fr" then "Bonjour, " ^ name else "Hello, " ^ name

(* Notice that both branches of the if-then-else end with `^ name`, so how about a little
   refactoring? *)
let greet lang name =
  (if lang = "fr" then "Bonjour, " else "Hello, ") ^ name

(* That example takes advantage of the fact that if-then-else is an _expression_. This is unusual.
   In languages like Python, C, Java, etc. we more often use an if _statement_, which can't
   participate in an expression.

   Those languages also have an if-expression, but it is more rarely seen.
   For example, we could do this in Python, using its if-expression:

    def greet(lang, name):
        return ("Bonjour, " if lang == "fr" else "Hello, ") + name *)

(* Another common pattern we see in imperative languages looks like this:

    def greet(lang, name):
        if lang == "fr":
            greeting = "Bonjour, "
        else:
            greeting = "Hello, "

        return greeting + name

    In OCaml, we need to turn our thinking around. Rather that _assign_ to a variable depending on
    the outcome of the condition, we make a local definition equal to the outcome of the condition.
*)

let greet lang name =
  let greeting =
    if lang = "fr" then "Bonjour, " else "Hello, "
  in
  greeting ^ name

(* The let-in syntax is used to make a _local_ definition. The variable `greeting` is visible
   in the expression after the `in` keyword. *)

(* How about a recursive function? This one adds up the first n natural numbers.

   let sum n = if n = 0 then 0 else n + sum (n-1)

   It won't compile though! The variable `sum` is not in scope on the RHS of the equals.

   OCaml requires is to mark recursive functions as such. This brings the name we're in the middle
   of defining into scope, allowing us to refer to the function we're in the middle of defining. *)

let rec sum n =
  if n = 0 then 0 else n + sum (n-1)

    (* Solutions to the exercises from the slides: *)

    (* `sqrt 0 n` finds the (integer) square root of `n`, i.e. the greatest
   integer `i` such that i^2 <= n. *)
let rec sqrt i n =
  if i*i > n then i-1 else sqrt (i+1) n

      (* QUESTION: is this algorithm tail-recursive? Why / why not? *)

      (* `is_prime 2 n` decides whether `n` is a prime number. *)
let rec is_prime i n =
  if i = n then true else
  if n mod i = 0 then false else
    is_prime (i+1) n

      (* Follow-up questions:
   1. Find a way to implement `sqrt` using a conversion to `float`, the built-in
   floating-point `sqrt` function, and a conversion back to `int`.
   2. Find a way to implement `is_prime` without using if-then-else, by using
     the logical operators || and &&.
     3. Exploit the symmetry in the is_prime problem:
        We don't need to test all the numbers up to `n`,
        but actually only those up to `sqrt n`.
        a) First rewrite `is_prime` to use an inner helper function, hiding the
           implementation detail that is the parameter `i`.
        b) Use `let-in` appropriately to calculate `sqrt n` only once.
        c) Adjust the stopping condition of `is_prime`.
*)
