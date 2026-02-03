(* Fall 2018 *)
(* Brigitte Pientka *)
(* Code for Lecture 1: Evaluation and Typing *)



(* Integers *)
let n1 = -1
let n2 = 4
let n3 = -3+2
let n4 = 5/2 (* result: 2 *)

(* floats *)
let pi = 3.14

let a1 = ((5.0 /. 2.0) : float);; (* NOT 5 / 2 and NOT 5.0 / 2.0 *)

let a2 = 0.05 +. 0.1
(* You might get seemingly strange results ...
- : float = 0.150000000000000022 *)

(* Floating-point representations have a base (which is always assumed to be even)
   and a precision p. If b = 10 and p = 3, then the number 0.1 is represented as
   1.00 × 10^-1. If b = 2 and p = 24, then the decimal number 0.1 cannot be
   represented exactly, but is approximately 1.10011001100110011001101 × 2^-4.

SEE
 http://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html
   What every computer scientist should know about floating point numbers
*)

(* Type errors
# 5 / 3.0;;
Characters 4-7:
  5 / 3.0;;
      ^^^
Error: This expression has type float but an expression was expected of type
         int

# 5.0 / 3;;
Characters 0-3:
  5.0 / 3;;
  ^^^
Error: This expression has type float but an expression was expected of type
         int

# 5 /. 3;;
Characters 0-1:
  5 /. 3;;
  ^
Error: This expression has type int but an expression was expected of type
         float
#
*)

(* Strings *)
let s1 = "comp 302 is going to be fun"

let s2 = "comp " ^ "302" ^ " = " ^ " FUN!"

(* Char *)
let c1 = 'c'
let c2 = 'o'
let c3 = '3'

(* Booleans *)
let b1 = true
let b2 = false

let q1 = if 0 = 0 then 1.0 else 2.0 ;;
(* = tests structural equality *)

let q2 = if true then 4.0 else 1.0 /. 0.0 ;;
(* NOTE: division by 0.0 is not caught statically during type checking *)

(* Type error
# if 0 = 1 then 1 else 2.0;;
Characters 21-24:
  if 0 = 1 then 1 else 2.0;;
                       ^^^
Error: This expression has type float but an expression was expected of type
         int
*)

(* In other words, the _branches_ of an if-then-else expression must _agree._
   (Have the same type.) *)


(* Typing and Evaluation *)
(* Some ill-typed expressions *)
(*
# 2.0 + 1;;
Characters 0-3:
  2.0 + 1;;
  ^^^
Error: This expression has type float but an expression was expected of type
         int
*)

(* Some well-typed expressions without a value *)
(*
# 1 / 0;;
Exception: Division_by_zero.

# if 1 / 0 = 0 then true else false ;;
Exception: Division_by_zero.

# if false then 4 else 1 / 0 ;;
Exception: Division_by_zero.

*)
