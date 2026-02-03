Welcome to the LearnOCaml platform! All homework assignments will be distributed for you to work on through this website and we encourage you to program and debug with all the fantastic tools integrated for you (eg. Compile, Grade and Eval buttons). Homework submission, on the other hand, is via MyCourses only, at the end of the term. Further instructions will come at that time.

The questions you will be given in the assignments will generally consist of two parts: writing tests and writing code. For each problem to solve, you will first be asked to write up tests, written as a list of (input, output) pairs. That is, each element of the list has to be a pair, with the first element being a tuple of arguments for the function you want to test, and the second element the answer you expect the function to return on those arguments. You can see some examples of this in the code we have provided for you.

It is important that you design these tests before writing your code: the goal of these exercises is for you to think about the problem and design test cases that represent a sufficient range of possible inputs to thoroughly eliminate any bugs in your implementation. The grader will also tell you whether or not your test cases are correct, so you can use this to make sure that you understand what kind of values your function should return. Until you have written a sufficient set of test cases, we will not show you our own test cases that we are running on your code.

We will evaluate the test cases you create by running your inputs on slightly incorrect versions of the function in question: we then expect that at least one of the (input, output) pairs you provide will not be matched by the buggy code. If the buggy version passes all of your tests (that is, given those inputs, the buggy version produces outputs identical to the ones given), your test list will be deemed insufficient to expose the bug. This is known in the software development industry as mutation testing.

Following the writing of tests, you will need to implement the function or behaviour in question. This is very straightforward coding. However, remember that you should not rely on your knowledge of other programming languages or paradigms, but instead use what you are taught in this course. For example, you should never be solving the question in a different language and then translating it to OCaml, and you should not be using programming constructs that have not been discussed in class.

The Learn-OCaml platform provides you with the following tools to help you out:

The Compile button runs syntax- and type-checking. If this returns errors, most other functionalities will not work for you. Use the red highlights of the line numbers to see where your errors are.
The Grade button evaluates your code against our tests and solutions, and returns a grade. Remember to run this at least once to get a grade! The Report tab then explains where you received — or failed to receive — your points. This is just for feedback - you still have to submit your code via MyCourses.
The Toplevel tab allows you to interact with OCaml, providing you with a read-eval-print loop (REPL) system. Entering an expression in the bottom text box and pressing Enter will evaluate it. You may do line breaks by pressing Ctrl-Enter (Cmd-Enter on a Mac).
The Eval code button loads your code into the Toplevel, without you copying and pasting it into the text box. Convenience!
The Reset button will delete all your implementations in the editor and will present you with the original starter code. Always make sure you have backed up your work locally before clicking this button!
However, Learn-OCaml platform has some potential problems that worth noticing throughout the whole semester:

In large homeworks, LearnOCaml may produce the following error when grading: Error in the exercise while testing your solution. This is due to LearnOCaml performing compilation steps in the browser, and it is likely that those steps ran out of stack memory. Switching to Google Chrome is advised in such cases because it allows for more stack memory. Since LearnOCaml isn't working in Chrome at the moment, please let us know if you run into this error.
Hardcoded lists should not exceed 92 in length, otherwise the browser compilation steps raise Stack overflow. So, you do not have to write more than 92 unit test cases per problem. In fact, you should always be able to catch all of the buggy implementations with 10 or fewer test cases. However, you can and should write more, to help you understand the problem domain.
Test-Writing Tips
You'll have to write a lot of test cases throughout the semester. Here are some tips for writing effective test cases. Remember that the goal is to improve your understanding of the problem and its edge cases, not just to write some basic tests!

Test with Purpose. When writing a test case, first think about a potential bug that you would like to be able to detect. Then write a test case that will fail on a mutation with that bug. Some bugs that are "obvious" when testing this way can be nearly impossible to hit by just writing random test cases!
One Case at a Time. The vast majority of code we will write in 302 starts by splitting a difficult problem into smaller, individually managable cases. It is very rare that a bug can only be caught by an input that uses multiple cases. Therefore, focus on testing one case at a time. If your test cases take more than a line to write, chances are they are more complex than necessary.
Write Assymetric Tests One of the most common types of bugs in programming is simply using the wrong variable name. For example, a function like let add x y = x + x has an x where there should be a y. A test case like add 2 2 = 4 will not catch this bug, because this test is "symmetric" - it passes the same value for x and y! You very rarely need a test to be symmetric, but you very often need a test to be assymetric. So, a good rule of thumb is to write one symmetric test, and then only write assymetric tests after that.
Question 1 : Fix Me
The following function has been implemented incorrectly in the provided template.

distance : (int * int) -> (int * int) -> int which calculates the Manhattan distance between two points represented as tuples of integers. This is the distance one would travel by walking on a grid such as the streets of Manhattan, not the straight-line, Euclidean distance.
Before proceeding to fix the implementation, it is a good idea to understand what the algorithm should do. This algorithm calculates a distance. Distances have the following properties:

distance a a = 0 the distance from a point to itself is always zero
distance a b >= 0 distances are always non-negative
distance a b = distance b a distances are symmetric
First figure out which of these properties the current implementation violates by writing up some tests. Write tests for the function distance in the list named distance_tests, the ones for binomial in binomial_tests, and the ones for lucas in lucas_tests respectively. An example test case is provided for the binomial function, but it is incorrect; you should fix it.

Then, correct the logical errors in the implementation of distance. You may find the function abs : int -> int helpful.

Question 2 : Binomial
The binomial coefficient B(n, k) is the coefficient that appears on the x^k term in the expansion of the binomial power (1 + x)^n. It can be calculated using the factorial function: B(n, k) = n! / (k! (n - k)!).

Implement the function binomial : int -> int -> int such that binomial n k computes B(n, k) using factorials.

Implement the helper function factorial : int -> int yourself as an inner helper function. You do not need to make the implementation of factorial tail-recursive.

As above, first write tests (for n >= 1) in the corresponding list, then implement the function. Note that n=k=0 is a valid input, but this test case was already given to you.


Note: you should only write test cases for valid inputs, i.e. you should not write tests for negative numbers for this question.

Question 3 : Lucas Numbers
The Lucas numbers form an integer sequence similar to the Fibonacci sequence. They are defined by the following (recursive) equations:

L(0) = 2
L(1) = 1
L(n) = L(n-1) + L(n-2)
Implement the function lucas : int -> int such that lucas n calculates L(n). Your implementation must be tail-recursive. Hint: use an inner helper function with additional parameters to carry forward the values for L(n-1) and L(n-2).