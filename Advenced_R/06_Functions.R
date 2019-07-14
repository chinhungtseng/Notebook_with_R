set.seed(1014)

# 6 Functions

# 6.1 Introduction

# If you're reading this book, you've probably already created many R functions and know how to use them to reduce duplication in your code.
# In this chapter, you'll learn how to turn that informal, working knowledge into more rigorous, theoretical understanding.
# And while you'll see some interesting tricks and techniques along the way, 
# keep in mind that waht you'll learn here will be important for understanding th more advanced topics discussed later in the book.

# Quiz

# Answer the following questions to see if you can safely skip this chapter.
# You can find the answers in Seciton 6.9.

# 1. What are the three components of a function?

# 2. What does the following code return?
x <- 10
f1 <- function(x) {
  function() {
    x + 10
  }
}
f1(1)()

# 3. How would you ususally write this code?
`+`(1, `*`(2, 3))

# 4. How could you make this call easier to read?
mean(, TRUE, x = c(1:10, NA))

# 5. Does the following code throw an error when executed? Why or why not?
f2 <- function(a, b) {
  a * 10
}
f2(10, stop("This is an error!"))

# 6. What is an infix function? How do you write it?
#    What's a replacement function? How do you write it?

# 7. How do you ensure that cleanup action occurs regardless of how a function exits?

# 6.2 Function fundamentals

# To understand funcitons in R, you need to internalise two important ideas:

# - Functions can be broken down into three components:
#   arguments, body, and environment.

# There are exceptions to every rule, and in this case, there is a samll selecion of "primitive" base functions that are implemented purely in C.

# - Functions are objects, just as vectors are objects.

# 6.2.1 Function components

# A function has three parts:

# - The `fomals()`, the list of arguments that control how you call the function.
# - The `body()`, the code inside the funciton.
# - The `environment()`, the data structure that determines how the funciton finds the values associated with names.

# While the formals and body are specified explicitly when you create a function, the environment is specified implicitly,
# based on where you defuned the function.
# The function envionment always exists, but it is only printed when the function isn't defined in the global envionment.

f02 <- function(x, y) {
  # A comment
  x + y
}

formals(f02)
#> $x
#> 
#> 
#> $y

body(f02)
#> {
#>     x + y
#> }

environment(f02)
#> <environment: R_GlobalEnv>

# I'll draw funcitons as in the floolwing diagram.
# The black dot on the left is the environment.
# The two blocks to the right are the function arguments.
# I won't draw the body, because it's usually large, and doesn't help you understand the shape of the function.

# Like all objects in R, functions can also possess any numberof additional `attributes()`.
# One attribute used by base R is `srcref`, short for souce reference.
# It points to the source code used to create the function.
# The `srcref` is used for printing because, unlike `body()`, it contains code comments and other formatting.
attr(f02, "srcref")
#> function(x, y) {
#>   # A comment
#>   x + y
#> }

# 6.2.2 Primitive functions

# There is one exctopition to the rule that a function has three components.
# Primitive functions, like `sum()` and `[`, call C code directly.
sum
#> function (..., na.rm = FALSE)  .Primitive("sum")
`[`
#> .Primitive("[")

# They have either type `builtin` or type `special`.
typeof(sum)
#> [1] "builtin"
typeof(`[`)
#> [1] "special"

# These function exist primarily in C, not R, so their `formals()`, `body()`, and `envioinment()` are all `NULL`:
formals(sum)
#> NULL
body(sum)
#> NULL
environment(sum)
#> NULL

# Primitive functions are only found in the base package.
# While they have certain performance advantages, this benefit comes at a price: they are harder to write.
# For this reason, R-core generally avoids creating them unless there is no other option.

# 6.2.3 First-class functions

# It's very important to understand that R functions are objects in their own right, a language property often called "first-class functions".
# Unlike in many other languages, there is no specail syntax for defining and naming a function: 
# you simply create a function object (with `function`) and bind it to a name with `<-`:
f01 <- function(x) {
  sin(1 / x ^ 2)
}

# while you almost always create a function and then bind it to a name, the binding step is not compulsory.
# If you choose not to give a function a name, you get an __anonymous function__.
# This is useful when it's not worth the effort to figure out a name:
lapply(mtcars, function(x) length(unique(x)))
Filter(function(x) !is.numeric(x), mtcars)
integrate(function(x) sin(x) ^ 2, 0, pi)

# A final option is to put function in a list:
funs <- list(
  half = function(x) x / 2,
  double = function(x) x * 2
)
funs$double(10)

# In R, you'll often see funcitons called __closures__.
# This name reflects the fact that R functions capture, or enclose, their envionments, which you'll learn more about in Section 7.4.2.

# 6.2.4 Invoking a function

# You normally call a function by placing its arguments, wrapped in parentheses, after its name: `mean(1:10, na.rm = TRUE)`.
# But what happens if you have the arguments already in a data structure?
args <- list(1:10, na.rm = TRUE)

# You can instead use `do.call()`: it has two arguments. The function to call, and a list containing the function arguments:
do.call(mean, args)
#> [1] 5.5

# We'll come back to this idea in Section 19.6.

# 6.2.5 Exercises

# 1. Given a name, like `"mean"`, `match.fun()` lets you find a funcion.
#    Given a function, can you find its name? Why doesn't that sense in R?

# A name can only point to a single object, but an object can be pointed to by 0, 1, or many names.

# 2. It's possible (although typically not useful) to call an anonymous funcion.
#    Which of the two approaches below is correct? Why?
#function(x) 3()
#> function(x) 3()
(function(x) 3)()
#> [1] 3

# The second approach is correct.

# The ananymous function `function9x) 3` is surrounded by a pair of parenthese before it is called by `()`.
# These extra parentheses separate the function call from the anonymous fucntions body.
# Without these a function with the invalid body `3()` is returned, which throws an error when we call it.
# This is easier to see if we name the function:
#f <- function(x) 3()
f
f()
#> Error in f() : attempt to apply non-function

# 3. A good rule of thumb is that an anonymous function should fit on one line and shouldn't need to use `{}`.
#    Review your code. Where could you have used an anonymous function instead fo a named function? 
#    Where should you have used a named function instead of an anonymous function?

# The use of anonymous functions allows concise and elegant code in certain situations.
# However, they miss a descriptive name and when re-reading the code it can take a  while to figure out what they do(even it it's future you reading).
# That's why it's helpful to give long and complex functions a descriptive name.
# It amy be worthwhile to take a look at your own projects or other peoples code to reflect on this part of your coding style.

# 4. What function allow you to tell if an object is a function?
#    What function allows you to tell if a function is a primitive function?

# Use `is.function()` to test, if an object is a function.
# You may also consider `is.primitive()` to test specifically for primitive functions.

# 5. This code makes a list of all functions in the base package.
objs <- mget(ls("package:base", all = TRUE), inherits = TRUE)
funs <- Filter(is.function, objs)

# Use it to answer the following questions:

# a. Which base function has the most arguments?
# b. How many base function have no arguments?
#    What' special about those functions?
# c. How could you adapt the code to find all primitive function?

# To find the function with the most arguments, we first compute the length of `formals()`
library(purrr)

# a
n_args <- funs %>% 
  map(formals) %>% 
  map_int(length)

# Then use `table()` to see the distribution, and `[` to find the largest:
table(n_args)
# n_args
#   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  16  22 
# 246 222 361 194 114  85  34  14  11   3   2   1   1   1   1   2   1 
names(n_args)[n_args == 22]
#> [1] "scan"

# b
# We can also use `n_args` to find the number functions with no arguments:
sum(n_args == 0)
#> [1] 246

# However, this over counts because `formals()` returns `NULL` for primitive functions, 
# and `length(NULL)` is 0. To fix that we can first remove the primitive functions
n_args2 <- funs %>% 
  discard(is.primitive) %>% 
  map(formals) %>% 
  map_int(length)

sum(n_args2 == 0)
#> [1] 46

# c
# To find all primitive functions, we can change the predicate in `Filter()` from `is.function()` to `is.primitive()`:
funs <- Filter(is.primitive, objs)
length(funs)

# 6. What are the three important components of a function?

# These components are the function's `formals()`, `body()`, and `environment()`.

# 7. When does printing a function not show the envionment it was created in?

# Primitive function and functions created in the global environment do no print their enviroment.


















































