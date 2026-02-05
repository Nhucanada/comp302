(* The code here will be added to the top of your code automatically.
   You do NOT need to copy it into your code if you use LearnOCaml.
*)

exception NotImplemented

let domain () =
  failwith "REMINDER: You should not be writing tests for undefined values."

type 'a tree = Empty | Tree of 'a tree * 'a * 'a tree

let maxk (x : int) (y : int) (k : int -> 'r) : 'r =
  if x > y then k x else k y

(* These are to make it easier for you to write tests.
   Remember that you only need to write tests for the
   "trivial" continuations: `id` and `some_k`/`none_k`. *)
let insert_test_continuations (tests : ('a * 'b) list)
  : (('a * ('b -> 'b)) * 'b) list =
  let id x = x in
  List.map (fun (a,b) -> ((a, id), b)) tests


(* Tree Depth *)
(* Test cases for tree_depth_cps *)
(* Tests cover: empty tree, single node, left-heavy, right-heavy, balanced trees *)
let tree_depth_cps_test_cases : (int tree * int) list = [
  (Empty, 0);                                                (* Empty tree has depth 0 *)
  (Tree (Empty, 1, Empty), 1);                               (* Single node has depth 1 *)
  (Tree (Tree (Empty, 2, Empty), 1, Empty), 2);              (* Left child only *)
  (Tree (Empty, 1, Tree (Empty, 3, Empty)), 2);              (* Right child only *)
  (Tree (Tree (Empty, 2, Empty), 1, Tree (Empty, 3, Empty)), 2);  (* Balanced depth 2 *)
  (Tree (Tree (Tree (Empty, 4, Empty), 2, Empty), 1, Empty), 3);  (* Left-heavy depth 3 *)
  (Tree (Tree (Empty, 2, Empty), 1, Tree (Tree (Empty, 4, Empty), 3, Empty)), 3);  (* Asymmetric *)
]

(* These are the test cases that will actually be graded, but
   you don't have to modify this. Remember that you only need
   to test with the `id` continuation. `insert_test_continuations`
   (defined in the prelude) adds the `id` continuation to each of
   your test cases. *)
let tree_depth_cps_tests : ((int tree * (int -> int)) * int) list =
  insert_test_continuations tree_depth_cps_test_cases

(* An example of Non-CPS function to find depth of a tree: *)
let rec tree_depth (t : 'a tree) =
  match t with
  | Empty -> 0
  | Tree (l, _, r) -> 1 + max (tree_depth l) (tree_depth r)

(* CPS tree depth implementation using maxk instead of max.
   For each recursive call, the continuation captures what to do next:
   1. First compute left subtree depth
   2. Then compute right subtree depth  
   3. Use maxk to find the maximum
   4. Add 1 and return the result *)
let rec tree_depth_cps (t : 'a tree) (return : int -> 'r) : 'r =
  match t with
  | Empty -> return 0
  | Tree (l, _, r) ->
      tree_depth_cps l (fun dl ->
        tree_depth_cps r (fun dr ->
          maxk dl dr (fun m -> return (1 + m))))

(* Question 2: Tree Traversal *)
(* Test cases for traverse_cps - preorder traversal *)
(* Preorder: visit node, then left subtree, then right subtree *)
let traverse_cps_test_cases : (int tree * int list) list = [
  (Empty, []);                                                     (* Empty tree *)
  (Tree (Empty, 1, Empty), [1]);                                   (* Single node *)
  (Tree (Tree (Empty, 2, Empty), 1, Tree (Empty, 3, Empty)), [1; 2; 3]);  (* Example 2 from instructions *)
  (Tree (Tree (Tree (Empty, 4, Empty), 2, Tree (Empty, 5, Empty)), 1, Tree (Empty, 3, Empty)), 
   [1; 2; 4; 5; 3]);                                               (* Example 3 from instructions *)
  (Tree (Tree (Empty, 2, Empty), 1, Empty), [1; 2]);               (* Left child only *)
  (Tree (Empty, 1, Tree (Empty, 3, Empty)), [1; 3]);               (* Right child only *)
];;
let traverse_cps_tests : ((int tree * (int list -> int list)) * int list) list =
  insert_test_continuations traverse_cps_test_cases

(* An example of non-CPS function to preorder traverse a tree *)
let rec tree_traverse (t : 'a tree) = 
  match t with
  | Empty -> []
  | Tree (l, x, r) -> x :: tree_traverse l @ tree_traverse r

(* CPS preorder traversal: visit node first, then left, then right.
   For each recursive call, the continuation captures what to do next:
   1. First traverse left subtree
   2. Then traverse right subtree
   3. Combine: current node :: left_result @ right_result
   4. Return the combined list *)
let rec traverse_cps (t : 'a tree) (return : 'a list -> 'r) : 'r =
  match t with
  | Empty -> return []
  | Tree (l, x, r) ->
      traverse_cps l (fun ll ->
        traverse_cps r (fun rl ->
          return (x :: ll @ rl)))
