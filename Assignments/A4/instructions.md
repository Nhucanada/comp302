All functions in this homework must be implemented with the Continuation Passing Style. If not, you will lose some points even when you pass all test cases.

Additionally, please note that tests should be written for int trees, but your code should be suitably polymorphic such that it can be tested on other types.

Trees, especially binary trees, are frequently used data structures. An example of a binary tree is shown in the following figure.

Binary Trees

Let’s define binary trees like this.

type 'a tree = Empty | Tree of 'a tree * 'a * 'a tree
Each node is in itself a tree and carries an item of type 'a. Additionally, each node has a left and right subtree. Leaf nodes are marked with an Empty left and right subtree. This definition is very similar to that of list, with the difference being that each node (item) has two sub-nodes, as opposed to lists which only contain one sub-list.

As usual, the autograder is limited in what it can check in your solution. If you want extra assurance that your solution meets all the criteria required from the question, book an appointment with a TA, or visit a study session after class, to discuss your solution with a TA.

Finding Depth of a Tree
Our first goal is to find the depth of trees, given as follows:

The depth of an empty tree (Empty) is zero.
The depth of a non-empty tree (Tree) is one plus the maximum depth of the two subtrees.
A recursive tree_depth implementation has been provided. Our job is to write a Continuation Passing Style (CPS) implementation of the same function.

Note that the signature of the function is:

tree_depth_cps : 'a tree -> (int -> 'r) -> 'r

Meaning that the function takes two parameters. These are first a tree, and second a continuation function consistent with the Continuation Passing Style. Be aware that the entire function has return type 'r, just as the continuation does, so please ensure that your function returns is suitably polymorphic, and returns this type on all branches.

To give you some additional practice with continuations, you are not permitted to use the max function on this question. Instead, the prelude contains a CPS-style version of the same function called maxk. This function has the signature:

maxk : 'a -> 'a -> ('a -> 'r) -> 'r

The function takes in two values and a continuation, and returns the result of calling the continuation on the larger of the two. The prelude contains the implementation of the function if you would like additional information on how it works.

The autograder doesn't check that you only use maxk, but human graders on a test would. Make sure that you can solve the problem using maxk instead of max.

Preorder Tree Traversal
Oftentimes we want to traverse an entire tree in a certain order. One common way of traversing a tree is preorder traversal. (You may be familiar with preorder traversal from COMP 250!)

In preorder traversal, we first visit the node, then traverse the left subtree, then traverse the right subtree.

Our job is to create a function that returns a list of the values of the tree visited in preorder traversal. This function should be implemented with the Continuation Passing Style. We have provided a recursive non-CPS implementation of a preorder tree traversal function for reference.

Example 1: For the tree in the image above, traverse should return the list [1; 7; 2; 6; 5; 11; 9; 9; 5].

Example 2:

Input: Tree (Tree (Empty, 2, Empty), 1, Tree (Empty, 3, Empty))
Output: [1; 2; 3]
Example 3:

Input: Tree (Tree (Tree (Empty, 4, Empty), 2, Tree (Empty, 5, Empty)), 1, Tree (Empty, 3, Empty))
Output: [1; 2; 4; 5; 3]
Your CPS translation is allowed to use the regular @ function to join lists.