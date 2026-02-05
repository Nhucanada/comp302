(* The code here will be added to the top of your code automatically.
   You do NOT need to copy it into your code if you use LearnOCaml.
*)

exception NotImplemented

let domain () =
  failwith "REMINDER: You should not be writing tests for undefined values."

type 'b church = ('b -> 'b) -> 'b -> 'b

let zero : 'b church = fun s z -> z
let one : 'b church = fun s z -> s z

(* Hi everyone. All of these problems are generally "one-liners" and have slick solutions. They're quite cute to think
   about but are certainly confusing without the appropriate time and experience that you devote towards reasoning about
   this style. Good luck! :-) *)

(* For example, if you wanted to use the encoding of five in your test cases, you could define: *)
let five : 'b church = fun s z -> s (s (s (s (s z))))
(* and use 'five' like a constant. You could also just use
   'fun z s -> s (s (s (s (s z))))' directly in the test cases too. *)

(* If you define a personal helper function like int_to_church, use it for your test cases, and see things break, you should
   suspect it and consider hard coding the input cases instead *)

(*---------------------------------------------------------------*)
(* QUESTION 1 *)

(* Question 1a: Church numeral to integer *)
(* Test cases: verify conversion for zero, one, and larger values *)
let to_int_tests : (int church * int) list = [
  (zero, 0);
  (one, 1);
  (five, 5);
  ((fun s z -> s (s z)), 2);  (* two *)
]

(* Implementation:
   A church numeral applies function s exactly n times to z.
   To get the integer, use increment as s and 0 as z.
   The numeral will increment 0 exactly n times, yielding n. *)
let to_int (n : int church) : int = n (fun x -> x + 1) 0

(* Question 1b: Determine if a church numeral is zero *)
(* Test cases: zero should be true, any positive number should be false *)
let is_zero_tests : ('b church * bool) list = [
  (zero, true);
  (one, false);
  (five, false);
  ((fun s z -> s (s z)), false);  (* two *)
]

(* Implementation:
   Zero applies s zero times, so it just returns z.
   Use z = true and s = (fun _ -> false).
   - Zero: returns true (just returns z)
   - Non-zero: applies s at least once, returning false *)
let is_zero (n : 'b church) : bool = n (fun _ -> false) true

(* Question 1c: Add two church numerals *)
(* Test cases: verify addition with various combinations *)
let two : 'b church = fun s z -> s (s z)
let three : 'b church = fun s z -> s (s (s z))

let add_tests : (('b church * 'b church) * 'b church) list = [
  ((zero, zero), zero);
  ((zero, one), one);
  ((one, zero), one);
  ((one, one), two);
  ((two, three), five);
]

(* Implementation:
   n1 applies s n1 times, n2 applies s n2 times.
   To add: first apply s n2 times to z, then apply s n1 more times.
   Result: s applied (n1 + n2) times to z. *)
let add (n1 : 'b church) (n2 : 'b church) : 'b church = fun s z -> n1 s (n2 s z)

(*---------------------------------------------------------------*)
(* QUESTION 2 *)

(* Question 2a: Multiply two church numerals *)
(* Test cases: verify multiplication with various combinations *)
let four : 'b church = fun s z -> s (s (s (s z)))
let six : 'b church = fun s z -> s (s (s (s (s (s z)))))

let mult_tests : (('b church * 'b church) * 'b church) list = [
  ((zero, one), zero);
  ((one, zero), zero);
  ((one, one), one);
  ((one, five), five);
  ((two, three), six);
  ((two, two), four);
]

(* Implementation:
   n2 s is a function that applies s n2 times.
   n1 (n2 s) z applies that "apply s n2 times" function n1 times.
   Result: s applied (n1 * n2) times to z. *)
let mult (n1 : 'b church) (n2 : 'b church) : 'b church = fun s z -> n1 (n2 s) z

(* Question 2b: Compute the power of a church numeral given an int as the power *)
(* Test cases: verify x^n for various combinations *)
let int_pow_church_tests : ((int * int church) * int) list = [
  ((2, zero), 1);     (* 2^0 = 1 *)
  ((2, one), 2);      (* 2^1 = 2 *)
  ((2, two), 4);      (* 2^2 = 4 *)
  ((2, three), 8);    (* 2^3 = 8 *)
  ((3, two), 9);      (* 3^2 = 9 *)
  ((5, two), 25);     (* 5^2 = 25 *)
  ((10, zero), 1);    (* 10^0 = 1 *)
]

(* Implementation:
   To compute x^n, start with 1 and multiply by x, n times.
   Use the church numeral n to apply "multiply by x" n times to 1. *)
let int_pow_church (x : int) (n : int church) : int = n (fun a -> a * x) 1
