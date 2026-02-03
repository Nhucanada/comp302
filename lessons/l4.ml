type name = string
(* ^ Define a type synonym. Now `string` and `name` are the same type. *)
let my_name : name = "jake"
(* ^ we can define a variable of type `name` with a value of type `string`. *)
type height_cm = int
(* ^ One use: specifying units in types. *)
let my_height : height_cm = 182
let my_height : int = 182
(* ^ These two declarations are pretty much the same, although the first is more informative to a
   reader, who doesn't need to guess the units. *)

(* TUPLES *)
let jake : name * height_cm = (my_name, my_height)
(* Form a tuple _type_ using the `*`:
       name * height_cm
   is the type of tuples with a `name` aka string in the first component and a `height_cm` aka int
   in the second component. *)

(* Construct a _value_ of a tuple type using the syntax `(___,___)` i.e. parens with a comma. *)

type person = name * height_cm
(* We can of course define type synonyms for tuples.
   Here we're modelling a person as a tuple of a name and a height. *)

(* Using tuples: *)
let is_tall (p : person) : bool = snd p > 178
(* The function `snd` extracts the second component of a 2-tuple. It does not work on larger
   tuples. THe function `fst` in contrast extracts the first component. *)

(* To extract from larger tuples we can use _pattern matching_.
   Anywhere we have written a variable in a _binding_ position so far, we have actually been
   writing a _pattern_. Patterns _look like_ values, but they are used to extract (possibly nested)
   components of those values.
   Here, the pattern (n, h) matches the shape of the tuple that would be given as input to this
   function, so the variable `n` will refer to the first component, the name; and the variable `h`
   will refer to the second component, the height. *)
let is_tall ( (n, h) : person) : bool = h > 178
                                        (* to refer to the height, we just use `h` now. *)

(* Or alternatively using let-in rather than directly pattern-matching in the parameter of the
   function. *)
let is_tall (p : person) : bool =
  let (n, h) = p in
  h > 178


(* ENUMERATED TYPES: modelling rock paper scissors *)
type hand = Rock | Paper | Scissors
    (* Defines a _new_ type, named `hand`, having exactly three values belonging to it:
        Rock, Paper, and Scissors.
       These are called _constructors_, since they construct values of the type being defined.
       These bear some similarity to constructors in object-oriented programming, but are different
       for the most part.
       (See the bottom of this file for a brief note on how to simulate constructors and
       pattern-matching in OOP. This is for your personal enrichment / to help you to relate your
       understanding of FP to your existing understanding of OOP.)

       IMPORTANT: OCaml distinguishes constructors from variables by a case convention.
        - Constructors must begin with an uppercase letter.
        - Variables must begin with a lowercase letter. *)

(* We use the constructors to create values of type hand, e.g.: *)
let my_hand = Rock
let your_hand = Paper

(* We use _pattern matching_ to examine the different possibilities for a value of type `hand`.
   Here, `beats` takes as input two hands, and proceeds by considering the three possible values
   that `h1` might have. *)
let beats (h1 : hand) (h2 : hand) : bool =
  match h1 with
  | Rock -> h2 = Scissors
    (* ^ In this case, h1 (i.e. Rock) beats h2 when h2 is Scissors. We can use an equality check
       for this. *)
  | Paper -> h2 = Rock
  | Scissors -> h2 = Paper

(* But by returning a `bool`, the function `beats` only captures two of the three possible outcomes
   in Rock-Paper-Scissors, namely winning and losing. What if we have `Rock` played against `Rock`?
   This should be a draw. *)

(* To accommodate this, define another enumerated type "outcome" that represents the outcome of a
   game of RPS. *)
type outcome = Win | Lose | Draw

(* Now we implement `play` using pattern matching and accounting for the three different outcomes.
*)
let play h1 h2 : outcome =
  match h1 with
  (* In each case for `h1`, we have to consider all three possibilities for `h2` to determine the
     outcome of the came. *)
  | Rock ->
      (match h2 with
       | Rock -> Draw
       | Paper -> Lose
       | Scissors -> Win)
    (* ^ Notice the parens around this inner match-expression. Without them, the branch
       `| Paper -> ...` below would be considered as belonging to the _inner_ match.
       The parens here are really are necessary. *)
  | Paper ->
          (* An alternative to parens is to use the begin-end syntax. These keywords are equivalent
             to parentheses in OCaml. *)
      begin match h2 with
        | Rock -> Win
        | Paper -> Draw
        | Scissors -> Lose
      end
  | Scissors ->
      (* Here the parens would be unnecessary since there aren't more branches below: *)
      match h2 with
      | Rock -> Lose
      | Paper -> Win
      | Scissors -> Draw

(* We can define `play` more succinctly by using an equality check to check for a draw before
   proceeding to use matching. This rules out the `Draw` cases from the matching. *)
let play h1 h2 =
  if h1 = h2 then Draw else
      (* We can intermingle if-then-else with match because match is an _expression_.
         The syntax is becomes very flexible when everything is an expression! *)

      (* Here we match simultaneously on the values of h1 and h2 by forming a tuple with them
         first, and matching on that tuple: *)
    match (h1, h2) with
    | (Scissors, Paper) -> Win
    | (Rock, Scissors) -> Win
    | (Paper, Rock) -> Win
    (* After considering all the Win cases, and recalling that Draw cases were handled by the
       `if`-expression above, we deduce that all the remaining cases must be losses.
       We can use the wildcard pattern `_` to essentially say "else" but in the context of `match`.
       This wildcard pattern matches with _any_ value. *)
    | _ -> Lose

(* The match-expression also allows embedding _side-conditions_ on patterns.
   These are boolean expressions that may refer to variables bound by the pattern,
   or to any other variables, too.
   To illustrate, let's also see an alternative implementation of `play` that
   takes the two input hands together in a tuple rather than separately. *)
let play (hs : hand * hand) : outcome =
  match hs with
  | (h1, h2) when h1 = h2 -> Draw
  | (Scissors, Paper) -> Win
  | (Rock, Scissors) -> Win
  | (Paper, Rock) -> Win
  | _ -> Lose

(* IMPORTANT: when we mention variables inside patterns, we are introducing _new names_.
   - We can't use these names to refer to existing variables, to check for equality.
   - We can't use the same name multiple times in a pattern to check for equality.
   For example, this DOESN'T WORK: *)
let play (hs : hand * hand) : outcome =
  match hs with
  | (h, h) (* Same name twice! Forbidden. *) -> Draw
    ...

                                                  let play (h1 : hand) (h2 : hand) : outcome =
                                                    match h1, h2 with
                                                    | _, h1 -> Draw
    (*   ^ trying to refer to outer `h1` variable to check equality with h2.
         This 'works' (the compiler will not reject the program) but it does the wrong thing.
         Instead of checking equality, this introducing a new `h1` variable, bound to the value of
         `h2`, and _shadowing_ the outer `h1`. *)

(* CONSTRUCTORS WITH FIELDS: modelling Uno cards. *)

(* UNO cards have a color and a symbol printed on them. We model these as separate types, to then
    define the card itself as a tuple of those two types. *)

    (* The color of the card: *)
type color = Yellow | Blue | Green | Red

    (* Symbol on the card: *)
type symbol =
  | Number of int (* <- this is a field. The constructor `Number` carries with it an `int`. *)
  | Skip
  | Reverse
  | Plus2
    (* btw we can lay out constructor definitions on one line, or on multiple lines. *)

type card = color * symbol

(* Example card, the green 3:
    - the color (first tuple component) is Green
    - the symbol (second tuple component) is the Number 3.
        We could not just write `3` here; that's an `int`, not a `symbol`!
        The constructor `Number` was defined above as carrying an `int`, so we must provide the int
        to it when we say `Number`. *)
let green3 : card = (Green, Number 3)

(* A central concept in UNO is that one card can be played following another card if it shares the
   same color or symbol as that card. We encode this relation as a function returning bool. *)
let can_follow (c1 : card) (c2 : card) : bool =
  match (c1, c2) with (* simultaneous matching again *)
  | ( (color1, symbol1), (color2, symbol2) ) -> (* nested pattern matching: a tuple of tuples! *)
      color1 = color2 || symbol1 = symbol2

(* Let's define a function to extract the number from a card, if that card is a Number card.
   But what should we return in case that card isn't a Number card? We can't make the return type
   `int` -- what `int` would we return in case the card isn't a Number card?
   -1, perhaps? But then a caller of this function must always remember to check for this special
   value. Forgetting to do so might have disastrous consequences.

   This is exactly the problem with _null,_ used in programming languages such as Java.

   A more robust solution makes it impossible to forget to check whether the operation succeeded or
   failed. Such a solution is to define a new type for representing the result of this extraction
   operation:*)
type number_of_result =
  | NotANumberCard (* Return this if the card isn't a Number card. *)
  | HereIsTheNumber of int (* Return this with the number if it is a Number card. *)

  (* Define `number_of` so that it returns a `number_of_result` rather than an `int`. *)
let number_of (c : card) : number_of_result =
  match c with
  (* Use pattern matching to extract the number `n` from the Number card *)
  | (_, Number n) -> HereIsTheNumber n
    (* ^ Put that number into a `number_of_result` using the constructor HereIsTheNumber. *)
  | _ -> NotANumberCard
    (* ^ return NotANumberCard otherwise. *)

(* RECURSIVE TYPES *)

(* In UNO, we don't just hold a single card, but a varying amount of them.
   We can represent this in OCaml using a fairly common data structure: the linked list.
   Linked lists are especially easy to manipulate in OCaml because they are a recursive structure:
   - either the list is empty; or
   - it contains a piece of data _together with another linked list._

   We can easily model this in OCaml as a type with two constructors. *)

type pile =
  | Empty
  | Extend of card * pile (* Recursive as it refers to itself in its definition *)

(* Contrast this with how we'd define a linked list like this in Java. It's remarkably similar.

   public class PileNode {
       Card card; // the card held in this node
       PileNode next; // the pointer to the next node in the list -- null stands for the empty list

       public PileNode(Card card, PileNode next) {
           this.card = card;
           this.next = next;
        }
    }

    The difference is that OCaml lacks a universal 'null' value that belongs to all types, so we
    have to introduce a 'specialized null' (Empty) to represent the empty list.
*)

let my_hand = (* example hand with three cards in it. *)
  Extend (green3, Extend (green3, Extend ((Blue, Skip), Empty )))

(* Recursive functions are well-suited to deal with recursive types.
   Let's write a function to calculate the length of a pile of cards. *)

let rec len (p : pile) : int =
  match p with
  | Empty -> 0
  | Extend (_, p) -> (* Shadowing the outer `p` *)
      1 + len p

(* EXERCISE:
   This function is not tail-recursive. Translate it to be TR by introducing an accumulator.
   (For guidance, see previous classwork where we translated `sum : int -> int` to be
   tail-recursive using the same strategy.) *)

(* EXERCISE:
   Compute the sum of all the Number cards in a pile. *)
let rec sum_numbers (p : pile) : int = failwith "todo"

(* NOTE: ON SIMULATING CONSTRUCTORS AND PATTERN MATCHING IN OOP.

   This section is optional, and might just help you to ground your understanding of OCaml's
   datatypes in terms of object-oriented programming. If OOP is mysterious to you, then this
   probably won't help.

The big idea is to leverage inheritance. Here is some Java-esque pseudocode.

// this simulates the type definition of `hand` from above:
abstract class Hand {}
class Rock extends Hand {}
class Paper extends Hand {}
class Scissors extends Hand {}

// this simulates construction of a value:
Hand h = Rock();

// use `instanceof` to simulate pattern matching
boolean beats(Hand h1, Hand h2) {
    if (h1 instanceof Rock) return h2 instanceof Scissors;
    if (h1 instanceof Paper) return h2 instanceof Rock;
    if (h1 instanceof Scissors) return h2 instanceof Paper;

    throw new RuntimeException("this should be impossible");
}

Important differences with the OCaml definition:

    - The Java version defines _four_ types whereas the OCaml version defines _one_.
        - In the OCaml version, the constructors Rock, Paper, and Scissors _are not types._

    - The Java version is "open", meaning that new subclasses can be added anywhere to Hand, and
        criticially this will break our code! Notice that we could add a new subclass
        `class VulcanSalute extends Hand` pretty much anywhere, and then it becomes possible to
        reach the previously unreachable exception line in `beats`.

    - The OCaml version is "closed". All definitions of constructors for `hand` must appear at the
        point of definition of `hand` itself.

This is just _one_ way you could do the simulation. Other approaches using Java's `enum` feature
would be possible. But crucially, `enum`s in Java can't carry addition information, unlike OCaml
constructors, which can have fields.

To simulate fields using subclassing as above, here's how we would do UNO in this way in Java:

abstract class Symbol {}
class Number extends Symbol {
    int value;

    public Number(int value) {
        this.value = value;
    }
}

// Then for pattern matching:

int numberOf(Symbol s) {
    if (s instanceof Number) {
        final Number n = (Number)s; // Downcast into a Number
        return n.value; // extract the number.
    }
}
*)
