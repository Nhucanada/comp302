(* POLYMORPHISM aka generics *)

(* Here is maybe the simplest polymorphic function. *)
let f x = x

(* It returns its input unchanged. In math we call such a function an 'identity' function. *)
(* Since it doesn't care about the exact nature of `x` -- it performs no operations on it --
   OCaml infers the type of `f` as 'a -> 'a, read as "alpha goes to alpha", which is a
   _polymorphic_ / generic type. We can call `f` on strings, ints, tuples, even other functions,
   and that's fine. *)

let ex1 = f "hello"
let ex2 = f 5

(* Think for a second. Could you define any function _other than_ an identity function with type
   'a -> 'a ?

   No! Therefore, these generic types actually hint at what the function must do.
   In other words, polymorphic types _constrain_ the set of possible implementations.

   Contrast with `int -> int`, for which there are a LOT of potential functions.
   In fact, in OCaml there are around (2^31)^(2^31) potential functions of that type.
   (Those of you who took MATH 240, which in principle is all of you, might know why!)
   This is a number so big my computer can't even calculate it.

   However, for 'a -> 'a, there is exactly ONE reasonable implementation.
   I say 'reasonable' because as we'll see later, we can be naughty and find one other kind of
   implementation. *)

(* Another one. This one is used for generating _constant functions_ *)
let g y x = y

(* How does OCaml infer the type of this function?
   It follows essentially this process:
   1. observe that g is defined 'as an application', i.e. as `g y x`, with two explicit parameters.
      Therefore, the type of g must look like ??? -> ??? -> ???.
      Two explicit parameters means 2 arrows in the type of the function.
   2. Assign _distinct_ generic types to the inputs: say y : 'a and x : 'b
      These are _guesses_. We might _refine_ them later to be less generic / more concrete.
   3. Look at the body of the function to figure out the return type
   4. Body is just `y`; that's what's returned. Return type of `g` must be the type of `y`.
   5. state the type of g : 'a -> 'b -> 'a
*)

(* How about this function? *)
let h x y =
  let _ = x + 1 in
  y

(* Following the same procedure, we initially guess
   x : 'a and y : 'b
   Then we see `x + 1` in the body, so we refine 'a to int.
   Then we return `y`. The return type of the function is thus 'b.
   State the type, h : int -> 'b -> 'b

   What's a little strange at first about this one is that even though the result of `x+1` didn't
   participate in the final result, it still influenced the type inference.
   (Recall that the _type_ of a let-in expression is the type of whatever comes after the `in`.) *)

(* Note: just like the functions `let f x = x` and `let f y = y` are considered IDENTICAL
   (they differ only in the names of their variables)
   we consider identical the types `int -> 'b -> 'b` and `int -> 'a -> 'a`. *)

(* How about this function? This time it's recursive! *)
let rec oops x = oops x
(* Following the same procedure, guess x : 'a, and guess that `oops` itself has type 'a -> 'b.
   Then the body consists of `oops x`, which is well typed, and has type 'b!
   In other words, since `oops x` is defined to just return whatever `oops x` returns, we learn
   nothing new from the body.

   Therefore, oops : 'a -> 'b.

   This type is very suspicious. `oops` claims to take in whatever you want, and _return whatever
   you want!_ The only way it can do this is by never actually delivering on its promise:
   it never returns! *)

(* Tuples can be polymorphic, and sometimes just partially, too.
   Here's an example of a function that takes a tuple as input, and adds 1 to the first component.
   Since it's adding 1, the first component must be an int, but no constraint is placed on the
   second component. *)
let j p = (fst p + 1, snd p)

(* The type inferred for this function is:
    int * 'a -> int * 'a
*)

let fst (x, y) = x
(* Here, no constraint is placed on either component, so we get
   'a * 'b -> 'a
*)

(* GENERIC DATATYPES *)

(* Let's go back to our UNO cards from last class. *)
type color = Yellow | Blue | Green | Red
type symbol = Number of int | Skip | Reverse | Plus2
type card = color * symbol

(* We made an engineering compromise in the way we defined `symbol`:
   To represent the number cards, rather than have ten separate constructors
    (Zero, One, Two, etc.)
   we defined `Number of int` to hold in that `int` the specific number.
   This is too broad as it allows cards such as `Number 13` to be represented, even though such
   cards don't exist in UNO.

   We want confidence in our code, however, so how can we try to prevent such 'impossible' values
   from being constructed?
   One idea is to use a form of encapsulation. We don't expose to the users of our card module the
   specific constructors, such as Number, but instead force them to use a function called
   `make_number_card`. This function takes an int as input, validates it, and returns a `card` if
   the number is valid. If it's invalid, however, what should it return?
   We can define a datatype to represent this "success or failure" pattern. *)

type number_card_result =
  | InvalidNumber (* returned when the `int` was not in the bounds 0 to 9 *)
  | HereIsTheCard of card (* returned when the `int` was in bounds. *)


let make_number_card color n : number_card_result =
  if 0 <= n && n <= 9 (* bounds-check `n` *)
  then HereIsTheCard (color, Number n)
  (* ^ construct the `card` with (color, Number n), then return it via HereIsTheCard signalling
       success *)
  else InvalidNumber
  (* ^ signal failure by returning InvalidNumber. *)

(* You can imagine this kind of pattern cropping up all over the place when we are doing input
   validation.
   What if we want to return a `string` in case of success in some other situation? Or an int? *)

type string_result =
  | FailedString
  | HereIsTheString of string

type int_result =
  | FailedInt
  | HereIsTheInt of int

(* It would be ridiculous to define a brand new type for every kind of successful return!
   This is where _polymorphic datatypes_ come in.
   We can capture the overall pattern here by abstracting away the _type_ of the successful result,
   using a type variable 'a. *)

(* This type captures all three of the above. *)
type 'a option =
  | None (* Return this in case of failure *)
  | Some of 'a (* Return this is case of success, together with the 'successful result'. *)

(* SYNTAX REMARK:
    In Java, and pretty much any other langauge with generics, the generic type goes on the
    _right._ OCaml has it backwards.

    For instance, in a Java-esque syntax, we would have Option<T>, but in OCaml we have 'a option.
*)

(* Now we can use this generic option type to implement `make_number_card` instead of using our
   specialized `number_card_result` type. *)
let make_number_card color n : card option (* <- returning a 'card option' *) =
  if 0 <= n && n <= 9 (* bounds-check `n` *)
  then Some (color, Number n)
  (* ^ The constructor `Some` holds the successful result, i.e. of type `card` here. *)
  else None
  (* ^ The constructor `None` holds nothing, and signals failure. *)

(* In languages like Java, we often use the special value `null` as a way to signal failure,
   because `null` is a value of _every type_.
   In practice, the use of `null` is the source of innumerable bugs, because the type system does
   not tell us whether we have "null-checked" the value yet!
   In inventor of the null pointer in the 1960s, Tony Hoare, later said that it was his
   'billion-dollar mistake' due to the sheer aggregate cost of null pointer errors.
   (By the way, Tony Hoare invented some good things too, like the Quicksort algorithm.)

   In contrast to using null pointers, when we have a value of type `A option`, it might be there,
   it might not. When we have a value of some type A however, we know for sure it isn't null, as
   there is no null in OCaml at all.

   Nowadays, many popular languages like Java and C++ include an option-type similar to OCaml's. *)

(* OCaml has a built-in list type that's generic. Its definition is baked into the compiler, so I
   can't actually repeat it here like I did for `option` (which is simply defined in the OCaml
   standard library, rather than being built-in.)

type 'a list =
    | [] (* constructor for the empty list is written as a pair of brackets *)
    | (::) of 'a * 'a list
    (* the constructor for a node, containing a value of type 'a and (a pointer to) another 'a
       list, is written as the operator ::, with the value on the left and the other list on the
       right. *)
*)

let ex = 1 :: 2 :: 3 :: [] (* the list 1, 2, 3 *)

(* The operator :: is right-associative, meaning that in the absence of explicit parentheses, there
   are implied parentheses nested on the right. *)

let ex = 1 :: (2 :: (3 :: [])) (* same as before. *)

(* For writing out a complete list, there is syntax sugar: *)

let ex = [1;2;3] (* same as before! *)

(* IMPORTANT: the separator for list items is the semicolon, not the comma! *)

(* Be careful: (::) is a constructor, *not a function.* We can't use :: to add an item to the
   _end_ of a list. We use :: to build a _new_ list from an existing one and a value compatible
   with the list. *)

(* We can implement a generic length function to compute the length of a list, regardless of the
   type of element inside the list. *)

let rec len (l : 'a list) : int =
  match l with
  | [] -> 0
  | x :: xs -> (* since :: is an operator, the variables in the pattern go around it *)
      1 + len xs

(* Here's a function that returns the first `n` items of a list, as another list.
   In case the list has fewer than `n` elements, we stop the process early.
   In other words, the output list will have _at most_ `n` elements in it. *)
let rec take n l = match n, l with
  | _, [] -> []
  | 0, _ -> []
  | n, x::xs -> x :: take (n-1) xs

(* One way you can intuitively try to grasp this function is that it's "racing" the number `n`
   against the list `l` to see which one runs out first. That's why we have two base cases: one
   where `n` reaches zero and one where `l` reaches `[]`.
   In the step case, we know that n>0 and `l` is formed from `x::xs`.
   We compute the recursive call `take (n-1) xs` to select the first n-1 items from the rest of the
   list, and when we're done with that, we stick `x` onto the front of that output list using `::`.
*)

(* CHALLENGE: Can you write a recursive function that selects the _last_ `n` elements of a list?
   HINT: use a helper function to do the bulk of the work and have it return a tuple of a list and
   an int. Ask for more hints on Discord if you're stuck :) *)

(* EXERICSE: Write the function `zip : 'a list -> 'b list -> ('a * 'b) list` to 'zip' two lists
   together into a list of tuples.
   The output list's length should be the minimum of the input lists' lengths
   e.g. zip [A;A;A] [B;B] = [(A, B); (A, B)] *)
