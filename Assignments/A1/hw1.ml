(* The code here will be added to the top of your code automatically.
   You do NOT need to copy it into your code if you use LearnOCaml.
   You MUST NOT copy it into the code you submit to MyCourses. This
   might break the grader, resulting in you getting a 0.
*)

exception NotImplemented
let domain () =
    failwith "REMINDER: You should not be writing tests for undefined values."

(* Question 1: Manhattan Distance *)
(* TODO: Write a good set of tests for distance. *)
let distance_tests = [
  (
    ((0, 0), (0, 0)), (* input: two inputs, each a pair, so we have a pair of pairs *)
    0                 (* output: the distance between (0,0) and (0,0) is 0 *)
  );                    (* end each case with a semicolon *)
    (* Your test cases go here *)
  (* Test: distance from point to itself is 0 *)
  (((3, 4), (3, 4)), 0);
  (* Test: symmetry - distance a b = distance b a *)
  (((1, 2), (4, 6)), 7);
  (((4, 6), (1, 2)), 7);
  (* Test: distances are non-negative *)
  (((0, 0), (3, 4)), 7);
  (((5, 5), (2, 1)), 7);
  (* Test: asymmetric inputs to catch variable mix-ups *)
  (((0, 0), (1, 0)), 1);
  (((0, 0), (0, 1)), 1);
  (((1, 0), (0, 0)), 1);
  (((0, 1), (0, 0)), 1);
]
;;

(* TODO: Correct this implementation so that it compiles and returns
         the correct answers.
*)
let distance (x1, y1) (x2, y2) = 
  abs (x1 - x2) + abs (y1 - y2) 



(* Question 2: Binomial *)
(* TODO: Write your own tests for the binomial function.
         See the provided test for how to write test cases.
         Remember that we assume that  n >= k >= 0; you should not write test cases where this assumption is violated.
*)
let binomial_tests = [
  (* Your test cases go here. Correct this incorrect test case for the function. *)
  (* B(0,0) = 1 (the empty product is 1) *)
  ((0, 0), 1);
  (* B(n, 0) = 1 for any n >= 0 *)
  ((5, 0), 1);
  ((1, 0), 1);
  (* B(n, n) = 1 for any n >= 0 *)
  ((5, 5), 1);
  ((3, 3), 1);
  (* B(n, 1) = n *)
  ((5, 1), 5);
  ((4, 1), 4);
  (* Standard binomial coefficient values *)
  ((4, 2), 6);
  ((5, 2), 10);
  ((6, 3), 20);
  (* Asymmetric test to catch variable swaps *)
  ((5, 3), 10);
  ((5, 4), 5);
]

(* TODO: Correct this implementation so that it compiles and returns
         the correct answers.
*)
let binomial n k =
  let rec factorial m =
    if m = 0 then 1
    else m * factorial (m - 1)
  in
  factorial n / (factorial k * factorial (n - k))



(* Question 3: Lucas Numbers *)

(* TODO: Write a good set of tests for lucas_tests. *)
let lucas_tests = [
  (* Base cases *)
  (0, 2);  (* L(0) = 2 *)
  (1, 1);  (* L(1) = 1 *)
  (* Recursive cases: L(n) = L(n-1) + L(n-2) *)
  (2, 3);  (* L(2) = L(1) + L(0) = 1 + 2 = 3 *)
  (3, 4);  (* L(3) = L(2) + L(1) = 3 + 1 = 4 *)
  (4, 7);  (* L(4) = L(3) + L(2) = 4 + 3 = 7 *)
  (5, 11); (* L(5) = L(4) + L(3) = 7 + 4 = 11 *)
  (6, 18); (* L(6) = L(5) + L(4) = 11 + 7 = 18 *)
  (7, 29); (* L(7) = L(6) + L(5) = 18 + 11 = 29 *)
  (10, 123); (* L(10) = 123 *)
]

(* TODO: Implement a tail-recursive helper lucas_helper. *)
let rec lucas_helper n a b =
  if n = 0 then a
  else lucas_helper (n - 1) b (a + b)


(* TODO: Implement lucas by calling lucas_helper. *)
let lucas n =
  lucas_helper n 2 1
