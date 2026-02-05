Introduction:
In the last assignment, you worked with unary numbers represented with the following recursive type.

type nat = Z | S of nat

This defines a type nat according to the ways in which we construct values of this type: either we build a nat using the constant Z or we can build a new nat given an existing one by applying S.

It is actually possible to define the natural numbers in the opposite way! Rather than defining nat according to how to build it, we can define it according to how we use it. Such a definition ends up taking the form of a higher-order function.

To see the connection between these two ways of thinking, let's look at a general recursive function that operates on nats. This function uses the input natural number by matching and recursing on it, and is supposed to compute something as output. Since we don't know what that output will be, we will leave placeholders ???.

let rec process_nat (n : nat) =
    match n with
    | Z -> ???
    | S n' ->
        let r = process_nat n'
        in ???
We will add one additional parameter for each placeholder; these extra parameters will be used to fill in the placeholders. But what types should these additional inputs have?

Observation 1: The expressions we replace the placeholders with must have the same type. That's because they are both branches of the match-expression, and each branch must return the same type.
Observation 2: The second placeholder needs to be able to access the result of the recursive call, r.
For the first placeholder, we will add a parameter z : 'b. We will simply return it verbatim in the Z case. So 'b will be the return type of process_nat. For the second placeholder, we will add a parameter called s. Given observation 2, we reckon that s must have a function type, so that we can pass the result of the recursive call to it. Therefore, the type of s must have the form 'b -> ???.

Now from observation 1, we deduce that the return type of s must also be 'b since it must compute a value that process_nat itself is going to return. This leads to the general function for processing a nat.

let rec process_nat (n : nat) (s : 'b -> 'b) (z : 'b) : 'b =
    match n with
    | Z -> z
    | S n' -> s (process_nat n' s z)
What this function does is that it applies its input function s n times to its input value z. The overall type of process_nat is nat -> ('b -> 'b) -> 'b -> 'b. Understood as a function of one input, given that arrows associate to the right, we can rewrite that type as nat -> (('b -> 'b) -> 'b -> 'b). In other words, process_nat takes a nat as input, and computes a function of type ('b -> 'b) -> 'b -> 'b as output. (Note however that no meaningful computation takes place until every input is provided.)

That polymorphic function type is precisely a way of representing a natural number as a higher-order function: the natural number N is a function taking as inputs an initial value z : 'b and a function s : 'b -> 'b; it applies the function s N times to that initial z. We can define a type synonym for this polymorphic function type (provided in the prelude code):

type 'b church = ('b -> 'b) -> 'b -> 'b

This type is called church because this notion of representing data as functions is attributed to the mathematician Alonzo Church. He was Alan Turing's PhD advisor in the 1930s and also invented an abstract, mathematical model of computing called the Lambda Calculus. Similarly to how mathematicians believe that sets can represent anything in mathematics, Church believed that functions can represent anything in mathematics.[^1] He encoded various mathematical structures while solely using functions, one of them being the natural numbers. The core of Lambda Calculus is what underlies functional programming. Here is, for example, the number five represented as a church numeral:

let five : 'b church = fun s z -> s (s (s (s (s z))))

This function represents the number five because it applies the input function s five times.

A counting argument also might help to see why the polymorphic type ('b -> 'b) -> 'b -> 'b represents a natural number. How many different values of the polymorphic type ('b -> 'b) -> 'b -> 'b are there?

Since this is the type of a function, all the values of that type will have to look like fun s z -> ???. What remains to see is how many different function bodies we could write. We must return something of the abstract type 'b, so a candidate would be z, which has type 'b. That gives us our first value, fun s z -> z. Alternatively, we could try to use s to build the body of another value, fun s z -> s ???. Since s is a function of type 'b -> 'b, we need to give it an argument. We could use z, giving fun s z -> s z, or we could use s again, giving fun s z -> s (s ???). You might be able to see how, by induction, we'll have one value of type ('b -> 'b) -> 'b -> 'b for each natural number, determined by how many times we apply s in the body.

There are five functions you are required to implement in this homework, as usual, you should also provide test cases for each function. There are also some type checking quirks of OCaml that cause the type signatures to lose some elegance in the toplevel. Please ask if you encounter type errors that do not seem to make sense.

The autograder is limited in what it can check, so it is possible that you pass all the tests without actually finding the correct solution.

None of the solutions to the problems in this homework use recursion or pattern-matching!

If your solution uses recursion or pattern matching, then you did not find the correct solution.

Question 1:
Implement the functions:

to_int : int church -> int : to convert a church numeral into an integer. This function will be especially helpful to you in debugging your solutions to the next problems. Note the input is of type int church and not 'b church. This is sadly due to technical reasons and a design choice in the OCAML type checker. You should, however, not be too confused by this type.
is_zero : 'b church -> bool : to check if a church numeral is the zero representation in church numeral. You cannot use the to_int function. (Sadly, the autograder cannot verify this!) Think about how you implemented the previous function and how you can adapt for this case. Hint: choose wisely the values to use for s and z to the church numeral to get the result in one line.
add : 'b church -> 'b church -> 'b church: to add two church numerals together. Your solution must use only the inputs of add -- it cannot make any recursive calls, or call any other functions. Hint 1: your solution will fit on one line. Hint 2: the idea of the algorithm is the same as adding the unary nats from HW2, i.e. we want to replace the "zero" of the first number with the other number.
Question 2:
Implement the functions:

mult : 'b church -> 'b church -> 'b church: to multiply two church numerals together. Your solution must use only the inputs of mult -- it cannot make any recursive calls, or call any other functions. Again as a hint, your solution will fit on one line.
int_pow_church (x : int) (n : 'b church) : int: this will be a function that takes an int and a 'b church and outputs an int which value is x raised to the power of n. For instance, int_pow_church 2 two should evaluate to 4.