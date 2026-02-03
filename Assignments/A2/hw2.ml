exception Not_implemented

(** The exception raised when a test case has an input outside the domain of
    the tested function. *)
exception Invalid_test_case

type nat =
  | Z
  | S of nat

type exp =
  | Const of float
  | Var
  | Plus of exp * exp
  | Times of exp * exp
  | Div of exp * exp



(* Question 1 *)

(* TODO: Write a good set of tests for {!q1a_nat_of_int}. *)
let q1a_nat_of_int_tests : (int * nat) list = [
  (0, Z);                          (* Base case: 0 -> Z *)
  (1, S Z);                        (* 1 -> S Z *)
  (2, S (S Z));                    (* 2 -> S (S Z) *)
  (3, S (S (S Z)));                (* 3 -> S (S (S Z)) *)
  (5, S (S (S (S (S Z)))));        (* 5 -> five S constructors *)
]

(* TODO:  Implement {!q1a_nat_of_int} using a tail-recursive helper. *)
let q1a_nat_of_int (n : int) : nat =
  let rec helper n acc =
    if n = 0 then acc
    else helper (n - 1) (S acc)
  in
  helper n Z

(* TODO: Write a good set of tests for {!q1b_int_of_nat}. *)
let q1b_int_of_nat_tests : (nat * int) list = [
  (Z, 0);                          (* Z -> 0 *)
  (S Z, 1);                        (* S Z -> 1 *)
  (S (S Z), 2);                    (* S (S Z) -> 2 *)
  (S (S (S Z)), 3);                (* S (S (S Z)) -> 3 *)
  (S (S (S (S (S Z)))), 5);        (* Five S -> 5 *)
]

(* TODO:  Implement {!q1b_int_of_nat} using a tail-recursive helper. *)
let q1b_int_of_nat (n : nat) : int =
  let rec helper n acc =
    match n with
    | Z -> acc
    | S n' -> helper n' (acc + 1)
  in
  helper n 0

(* TODO: Write a good set of tests for {!q1c_add}. *)
let q1c_add_tests : ((nat * nat) * nat) list = [
  ((Z, Z), Z);                                      (* 0 + 0 = 0 *)
  ((Z, S Z), S Z);                                  (* 0 + 1 = 1 *)
  ((S Z, Z), S Z);                                  (* 1 + 0 = 1 *)
  ((S Z, S Z), S (S Z));                            (* 1 + 1 = 2 *)
  ((S (S Z), S (S (S Z))), S (S (S (S (S Z)))));    (* 2 + 3 = 5 *)
  ((S (S (S Z)), S (S Z)), S (S (S (S (S Z)))));    (* 3 + 2 = 5, test commutativity *)
]

(* TODO: Implement {!q1c_add}. *)
(* Tail-recursive solution: peel off S from n and add to m *)
let rec q1c_add (n : nat) (m : nat) : nat =
  match n with
  | Z -> m
  | S n' -> q1c_add n' (S m)


(* Question 2 *)

(* TODO: Implement {!q2a_neg}. *)
(* Negate an expression by multiplying by -1.0 *)
let q2a_neg (e : exp) : exp = Times (Const (-1.0), e)

(* TODO: Implement {!q2b_minus}. *)
(* Subtract e2 from e1 using Plus and neg *)
let q2b_minus (e1 : exp) (e2 : exp) : exp = Plus (e1, q2a_neg e2)

(* TODO: Implement {!q2c_pow}. *)
(* Raise e1 to power p, right-associated: e^3 = e * (e * (e * 1)) *)
let rec q2c_pow (e1 : exp) (p : nat) : exp =
  match p with
  | Z -> Const 1.0
  | S p' -> Times (e1, q2c_pow e1 p')


(* Question 3 *)

(* TODO: Write a good set of tests for {!eval}. *)
let eval_tests : ((float * exp) * float) list = [
  (* Constant evaluation *)
  ((0.0, Const 5.0), 5.0);
  ((3.0, Const 2.0), 2.0);
  (* Variable evaluation *)
  ((3.0, Var), 3.0);
  ((0.0, Var), 0.0);
  ((-2.0, Var), -2.0);
  (* Addition *)
  ((2.0, Plus (Const 1.0, Const 2.0)), 3.0);
  ((3.0, Plus (Var, Const 1.0)), 4.0);
  (* Multiplication *)
  ((2.0, Times (Const 3.0, Const 4.0)), 12.0);
  ((5.0, Times (Var, Const 2.0)), 10.0);
  (* Division *)
  ((6.0, Div (Const 10.0, Const 2.0)), 5.0);
  ((4.0, Div (Var, Const 2.0)), 2.0);
  (* Complex expression: 2x + 10 with x=3 should give 16 *)
  ((3.0, Plus (Times (Const 2.0, Var), Const 10.0)), 16.0);
]

(* TODO: Implement {!eval}. *)
let rec eval (a : float) (e : exp) : float =
  match e with
  | Const c -> c
  | Var -> a
  | Plus (e1, e2) -> eval a e1 +. eval a e2
  | Times (e1, e2) -> eval a e1 *. eval a e2
  | Div (e1, e2) -> eval a e1 /. eval a e2


(* Question 4 *)

(* TODO: Write a good set of tests for {!diff_tests}. *)
let diff_tests : (exp * exp) list = [
  (* D(constant) = 0 *)
  (Const 5.0, Const 0.0);
  (Const 0.0, Const 0.0);
  (* D(x) = 1 *)
  (Var, Const 1.0);
  (* D(e1 + e2) = D(e1) + D(e2) *)
  (Plus (Var, Const 3.0), Plus (Const 1.0, Const 0.0));
  (Plus (Var, Var), Plus (Const 1.0, Const 1.0));
  (* D(x * x) using product rule: D(x)*x + x*D(x) = 1*x + x*1 *)
  (Times (Var, Var), Plus (Times (Const 1.0, Var), Times (Var, Const 1.0)));
  (* D(c * x) = D(c)*x + c*D(x) = 0*x + c*1 *)
  (Times (Const 2.0, Var), Plus (Times (Const 0.0, Var), Times (Const 2.0, Const 1.0)));
  (* D(x / c) = (D(x)*c - x*D(c)) / (c*c) = (1*c - x*0) / (c*c) *)
  (Div (Var, Const 2.0), 
   Div (q2b_minus (Times (Const 1.0, Const 2.0)) (Times (Var, Const 0.0)),
        Times (Const 2.0, Const 2.0)));
]

(* TODO: Implement {!diff}. *)
(* Symbolic differentiation following the rules:
   D(e1 + e2) = D(e1) + D(e2)
   D(e1 * e2) = D(e1) * e2 + e1 * D(e2)  (product rule)
   D(x) = 1
   D(a) = 0  (a is a constant)
   D(e1 / e2) = (D(e1) * e2 - e1 * D(e2)) / (e2 * e2)  (quotient rule)
*)
let rec diff (e : exp) : exp =
  match e with
  | Const _ -> Const 0.0
  | Var -> Const 1.0
  | Plus (e1, e2) -> Plus (diff e1, diff e2)
  | Times (e1, e2) -> Plus (Times (diff e1, e2), Times (e1, diff e2))
  | Div (e1, e2) -> Div (q2b_minus (Times (diff e1, e2)) (Times (e1, diff e2)),
                         Times (e2, e2))
