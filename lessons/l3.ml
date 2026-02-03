(* Rewriting sum to be tail-recursive. *)
(* First, the straightforward, non-tail-recursive implementation. *)
let rec sum n =
  if n = 0 then 0 else n + sum (n-1)

let sum n =
  (* Concept: inner helper function
     Write the tail-recursive implementation as a _helper function_ defined
     locally (with let-in), so as not to expose to the user the extra
     parameter `partial_sum`. *)
  let rec sum_tr n partial_sum =
    if n = 0 then partial_sum else
      sum_tr (n-1) (partial_sum + n)
  in
  sum_tr n 0

    (* Definition: a function is _tail-recursive_ when _all_ its recursive
   calls are _tail-calls_. *)
    (* Definition: a function call is a _tail-call_ when it is the last operation
   performed before returning. *)


(* time: exponential
   space: linear *)
let rec fib n =
  if n = 0 then 0 else
  if n = 1 then 1 else
    fib (n-1) + fib (n-2)

      (* time: linear
   space: constant! (due to tail-call optimization) *)
let rec fib n a b =
  if n = 0 then a else
    fib (n-1) b (a + b)
