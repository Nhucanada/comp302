title: Homework 2
Unary numbers
You are very familiar with numbers in base 10, but also perhaps with numbers in bases 2 (binary), 8 (octal), and 16 (hexadecimal). But how about numbers in... base 1?

This base is called unary and essentially corresponds to "tally marks". For example, the number ten is represented as 1111111111, i.e. ten marks. This base is not particularly practically useful, but it is theoretically interesting as it is easy to define and manipulate numbers in this base.

We can represent unary numbers in OCaml by defining a recursive type.

type nat = Z | S of nat
We call the type nat as this is only a representation of the natural numbers. These are the nonnegative integers. Examples:

The number zero is represented as Z
The number five is represented as S (S (S (S (S Z))))
The number three is represented as S (S (S Z))
The number represented by a value of type nat corresponds to the count of S constructors appearing in that value. These are precisely the tally marks.

This type definition looks a lot like a linked list: Recall the definition of lists:

type 'a mylist = Nil | Cons of 'a * 'a mylist
The difference, (besides renaming the constructors,) is that the Cons constructor takes an element together with the rest of the list. In other words, a value of type nat is like a list with no elements, whose length is used to represent a number.

Question 1 (20 points) {#question-1-20-points-}
Implement the functions:

q1a_nat_of_int : int -> nat, to convert a native OCaml integer into its representation in unary, i.e. into a nat. (5 points) Your implementation must be tail-recursive, using an inner helper function with an additional parameter. The auto-grader does not verify whether your implementation is tail-recursive.
q1b_int_of_nat : nat -> int, to convert a nat into a native OCaml integer. Again, your implementation must be tail-recursive. (5 points) The auto-grader does not verify whether your implementation is tail-recursive.
q1c_add : nat -> nat -> nat, to add two nat values together. (10 points) Your implementation cannot convert the nats into ints, add the ints, and convert back! In fact, your implementation is forbidden from making any function calls whatsoever that are not recursive calls to q1c_add. Can you find both a tail-recursive and a non-tail-recursive solution?
By the way, what list functions seen in class do these nat functions look like?

Manipulating mathematical expressions
Using a recursive type, we can represent mathematical expressions very easily. In the prelude, the type exp is defined, and represents expressions having at most one variable. Look at the definition, then take a look at the example below.

We represent the expression 2x - x/3 + 10 as

Plus (
  Plus (
    Times (
      Const 2.0,
      Var
    ),
    Times (Const -1.0, Div (Var, Const 3.0))
  ),
  Const 10.0
)
The constructor Var represents the variable x of the expression.
The constructor Const represents a constant value (a float).
The constructors Plus, Times, and Div represent addition, multiplication, and division, respectively.
Question 2 -- warm-up (3 points) {#question-2-warm-up-3-points-}
Our representation of expressions is extremely simple. It does not have any "superfluous notation" such as subtraction, which can be represented instead using addition with negation.

Implement the functions:

q2a_neg : exp -> exp which forms an expression representing the negation of the given expression. To do this, use multiplication (Times) with -1.0 as in the example above.
q2b_minus : exp -> exp -> exp which takes two expressions and forms an expression representing the subtraction of the first expression by the second expression. To do this, use the Plus and constructor and the helper q2a_neg you defined.
q2c_pow : exp -> nat -> exp which takes an expression and a nat, and forms an expression representating the expression raised to the power of the nat. To do this, use the Times constructor. Note that the multiplication operation has to be associated to the right. E.g. the grader accepts Times(e, Times(e, Const 1.)), but not Times(Times(Const 1., e), e).
Question 3 (12 points) {#question-3-12-points-}
Now that we have a way to represent expressions, we would like to evaluate them.

Implement the function:

eval : float -> exp -> float, to evaluate an expression with a given value for the variable x. In other words, eval 3.0 e evaluates the expression e using the value 3.0 for the variable that appears in the expression.
The idea is to recursively evaluate subexpressions, which will produce floats, and to then perform the corresponding arithmetical operation in OCaml. For example, to evaluate a Plus expression, evaluate the two subexpressions, giving two floats, and then add them together.

Question 4 (15 points) {#question-4-15-points-}
The type exp we have defined represents functions of a single variable. This means that we can apply what we know from calculus to compute the derivative of the function in a fully automatic way.

You might have found yourself in a calculus class at some point, being asked to compute a derivate of some disgusting product of quotients of polynomials, and thought to yourself, "Gosh, this is so tedious! All I'm doing is executing a bunch of rules manually, and hoping to not make any mistakes along the way!"

Well now you will have a computer program that executes those rules for you, and fortunately cannot make any mistakes along the way!

Implement the function:

q4_diff : exp -> exp, to symbolically compute the derivative of the given expression representing a single-variable function.
For those of you who might not remember much from calculus class (and I don't blame you) here is a summary of the derivative rules you will need. I will write D(e) to mean "the derivative of the expression e with respect to its variable x".

D(e1 + e2) = D(e1) + D(e2)
D(e1 * e2) = D(e1) * e2 + e1 * D(e2) (product rule)
D(x) = 1
D(a) = 0 (a is a constant)
D(e1 / e2) = (D(e1) * e2 - e1 * D(e2)) / (e2 * e2)
Your implementation of q4_diff must follow these rules exactly and without doing any simplifications. That also means that when you write test cases for your implementation, you should not simplify anything.

That means that the derivative of x^2 isn't simply 2x like you learned in calculus. Instead, x^2 is represented as Times (Var, Var), and we use the product rule to compute its derivative as Plus (Times (Const 1.0, Var), Times (Var, Const 1.0)).