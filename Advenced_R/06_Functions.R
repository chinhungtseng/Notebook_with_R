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

# The three components of a function are its body, arguments, and environment.

# 2. What does the following code return?
x <- 10
f1 <- function(x) {
  function() {
    x + 10
  }
}
f1(1)()

# returns 11.

# 3. How would you ususally write this code?
`+`(1, `*`(2, 3))

# You'd normally write it in infix style: 1 + (2 * 3)

# 4. How could you make this call easier to read?
mean(, TRUE, x = c(1:10, NA))

# Rewritign the call to `mean(c(1:10, NA), na.rm = TRUE)` is easier to understand.

# 5. Does the following code throw an error when executed? Why or why not?
f2 <- function(a, b) {
  a * 10
}
f2(10, stop("This is an error!"))

# No, it does not throw an error because the second argument is never used so it's neverevaluated.

# 6. What is an infix function? How do you write it?
#    What's a replacement function? How do you write it?

# See Sections 6.8.3 and 6.8.4.

# 7. How do you ensure that cleanup action occurs regardless of how a function exits?

# You use `on.exit()`; see Section 6.7.4 for details.

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

# 6.3 Function composition

# Base R provides two ways to compose multiple function calls.
# For exmaple, imagine you want to compute the population standard deviation using `sqrt()` and `mean()` as building blocks:
square <- function(x) x^2
deviation <- function(x) x - mean(x)

# You either nest the function calls:
x <- runif(100)
sqrt(mean(square(deviation(x))))
#> [1] 0.2744786

# Or you save the intermediate results as variables:
out <- deviation(x)
out <- square(out)
out <- mean(out)
out <- sqrt(out)
out
#> [1] 0.2744786

# The magrittr package (Bache and Wickham 2014) provides a thrid option: 
# the binary operator ` %>% `, which is called the pipe and is pronounced as "and then".
library(magrittr)

x %>% 
  deviation() %>% 
  square() %>% 
  mean() %>% 
  sqrt()
#> [1] 0.2744786

# `x %>% f()` is equivalent to `f(x)`; `x %>% f(y)` is equivalent to `f(x, y)`.
# The pipe allows you to focus on the high-level composition of functions rather than the low-level flow of data;
# the focus is on what's being done(the verbs), rather than on what's being modified (the nouns).
# This style is common in Haskell and F#, the main inspiration for magrittr, and is the default style in stack absed programming languages like Forth and Factor.

# Each of the three options has it's own strnegths and weaknesses:

# - Nesting, `f(g(x))`, is concise, and well suited for short sequences.
#   But longer sequences are hard to read because they are read inside out and right to left.
#   As a result, auguments can get spread out over long distances creating the Dagwood sandwich problem.

# - Intermediate objects, `y <- f(x); g(y)`, requires you to name intermediate objects.
#   This is a strength when objects are important, but a wwakness when values are truly intermediate.

# Piping, `x %>% f() %>% g()`, allows you to read code in straightforward left-to-right fashion and doesn't require you to name intermediate objects.
# But you can only it with linear sequences of transformations of a single object.
# It also requires an additional third party package and assumes that the readre understands piping.

# Most code will use a combination of all three styles.
# Piping is more common in data analysis code, as much of an analysis consists of a sequence of transformations of an object (like a data frame or plot).
# I tend to use in frequently in packages; not because it is a bad idea, but because it's often a less natural fit.

# 6.4 Lexical scoping 

# In Chapter 2, we discussed assignment, the act of binding a name to a value.
# Here we'll discuss __scoping__, the act of finding the value associated with a name.

# The besic rules of scoping are quite intuite, and you've probably already internalised them, even if you never explicitly studied them.
# For exmaple, what will the following code return, 10 or 20?

x <- 10
g01 <- function() {
  x <- 20
  x
}
g01()

# In this section, you'll learn the formal rules of scoping as well as some of its more subtle details.
# A deeper understanding of scoping will help you to use more advanced functional programming tools, and eventyally, even to write tools that translate R code into other languages.

# R uses __lexical scoping__: it looks up the values of names based on how a function is defined, not now it is call.
# "Lexical" here is not the English adjective that means relating to words or a vocabulary.
# It's a technical CS term that tells us that the scoping rules use a parse-time, rather than a run-time structure.

# R's lexical scoping follows four primary rules:

# - Name masking 
# - Funcitons versus variables
# - A fresh start
# - Dynamic lookup

# 6.4.1 name masking

# The basic principle of lexical scoping is that naems defined inside a function mask names defined outside a funciton.
# This is ullustrated in the following example.
x <- 10
y <- 20 
g02 <- function() {
  x <- 1
  y <- 2
  c(x, y)
}
g02()
#> [1] 1 2

# If a name isn't defined inside a funciton, R looks one level up.
x <- 2
g03 <- function() {
  y <- 1
  c(x, y)
}
g03()
#> [1] 2 1

# And this doesn't change hte previous value of y
y 
#> [1] 20

# The same rules apply if a funciton is defined inside another function. First, R looks inside the current function.
# Then, it looks where that function was defined (and so on, all the wya up to the global envionment).
# Finally, it looks in otehr loaded packages.

# Run the following code in your head, then comfirm the result by running the code.
x <- 1
g04 <- function() {
  y <- 2
  i <- function() {
    z <- 3
    c(x, y, z)
  }
  i()
}
g04()
#> [1] 1 2 3

# The same rules also apply to functions crated by other functions, which I call manufactured functions, the topic of Chapter 10.

# 6.4.2 Fucntions versus variables

# In R, functions are ordinary objects. This means the scoping rules described above also apply to functions:
g07 <- function(x) x + 1
g08 <- function() {
  g07 <- function(x) x + 100
  g07(10)
}
g08()
#> [1] 110

# However, when a function and a non-function share the smae name (they must, of course, reside in different environments), applying these rules gets a little more complicated.
# When you use a name in a functin call, R ignores non-functin objects when looking ofr that value.
# For example, in the code below, `g09` takes on two different values:
g09 <- function(x) x + 100
g10 <- function() {
  g09 <- 10
  g09(g09)
}
g10()
#> [1] 110

# For the record, using the same name for different things is confusing and best avoided!

# 6.4.3 A fresh start

# What happens to values between invocations of a function? Consider the example below.
# What will happen the first time you run this function? What will happen the second time?
# (If you haven't seen `exists()` before, it returns `TRUE` if there's a varialbe with that name and returns `FALSE` if not.)
g11 <- function() {
  if (!exists("a")) {
    a <- 1
  } else {
    a <- a +1
  }
  a
}
g11()
g11()

# You might be surprised that g11() always returns the smae value.
# This happens because eveery tiem a function is called a new envionment is created to host its execution.
# this means that a fucntion has no way to tell what happened the last time it was run; each invocation is completely independent.
# We'll see some ways to get around this in Seciton 10.2.4.

# 6.4.4 Dynamic lookup 

# Lexical scoping determines where, but not when to look for values.
# R looks for values when the function is run, not when the function is created.
# Together, thess two properites tell us that the outpu tof a function can differ depending on the objects ouside the funtion's envionment:

g12 <- function() x + 1
x <- 15
g12()
#> [1] 16

x <- 20
g12()
#> [1] 21

# This behaviour can be quite annoying. If you make a spelling mistake in your code,
# you won't get an error message when you create the function.
# And depending on the variables defined in the global envionment, you might not even get an error message when you run the function.

# To detect this problem, use `codetools::findGlobals()`.
# This fujnction lists all the external dependences (unbound symbols) within a function:
codetools::findGlobals(g12)
#> [1] "+" "x"

# To solve this problem, you can manually change the function's envrionment to the `emptyenv()`, an envionment which contains nothing:
environment(g12) <- emptyenv()
g12()
#> Error in x + 1 : could not find function "+"

# The problem and its solution reveal why this seemingly undesirable exists:
# R relies on lexical scoping to find everything, from the obvous, like `mean()`, to the less obvious, like `+` or even `{`.
# This gives R's scoping reles a rather beautiful simplicity.

# 6.4.5 Exercises

# 1. What does the following code return? Why? Describe how each of the three `c`'s is interpreted.
c <- 10
c(c = c)

# This code returns a names numeric vector of length one - with one element of the value `10` and the name `"c"`.
# The first `c` represents the `c()` function, the second `c` interpreted as a (quoted) name and the third `x` as a value.

# 2. What are the four principles that govern how R looks for values?

# R's lexical scoping rules are based on these four principles:

# - Name masking
# - Function versus variable
# - A new fresh start
# - Dynamic lookup

# 3. What does the following function return?
#    Make a prediction before running the code yourself.
f <- function(x) {
  f <- function(x) {
    f <- function() {
      x ^ 2
    }
    f() + 1
  }
  f(x) * 2
}
f(10)

# Within this function tow more functions also named `f()` are defined and called.
# Because the functions are each executed in their own evrionment R will look up and use the functions defined in these envionments.
# The innermost `f()` is called last, though it is the first function to return a value.
# Because of this the order of the calculation passes "from the inside to the outside" and the function returns `((10 ^) + 1) * 2`,i.e. 202.

# 6.5 Lazy evaluation

# In R, function arguments are __lazily evaluated__: they're only evaluated if accessed.
# For exmaple, this code doesn't generate an error because `x` is never used:
h01 <- function(x) {
  10
}
h01(stop("This is an error!"))
#> 10

# This is an important feature because it allow you to do thing like include potentially expensive computations in function arguments that will only evaluated if needed.

# 6.5.1 Promises

# Lazy evaluation is powered by a data structure a __promise__, or (less commonly) a thunk.
# It's one of the features that makes R such an interesting programming language (we'll return to pormises again in Section 20.3).

# A promise has three components:

# - An expression, like `x + y`, which gives rise to the delayed computation.

# - An envionment where the expression should be evaluated, i.e. the envionment where the function is called.
#   This makes sure that the following function returns 11, not 101:
y <- 10 
h02 <- function(x) {
  y <- 100
  x + 1
}
h02(y)
#> [1] 11

# This also means that when you do assignment inside a call to a function, the variable is bound outside of the funciton, not inside of it.
h02(y <- 1000)
#> [1] 1001
y
#> [1] 1000

# - A value, which is computed and cached the first time a promise is accessed when the expression is evaluated in the specified envionment.
#   This ensures that the promise is evaluated at most once, and is why you only see "Calculating..." printed once in the following example.
double <- function(x) {
  message("Calculating...")
  x * 2
}
h03 <- function(x) {
  c(x, x)
}
h03(double(x))
#> Calculating...
#> [1] 40 40

# You cannot manipulate promises with R code. Promises are like a quantum state:
# any attempt to inspect them with R code will force an immediate evaluation, making the promise disappear.
# Later, in Section 20.3, you'll learn about quosures, which convert promises into an R object where you can easily inspect the expression an the evrionment.

# 6.5.2 Default arguments

# Thanks to lazy evaluation, default values can be defined in terms of other arguments,
# or event in terms of variables defined later in the function:
h04 <- function(x = 1, y = x * 2, z = a + b) {
  a <- 10
  b <- 100
  
  c(x, y, z)
}
h04()
#> [1]   1   2 110

# Many base R functions use this technique, but I don't recommend it.
# It makes the code harder to understand: to predict what will be returned, 
# you need to know the exact order in which default arguments are evaluated.

# The evaluation envionments is slightly different for default and user supplied argumnet, 
# as default arguments are evaluated inside the function.
# This means that seemingly identical calls can yield different results.
# It's easiest to see this with an extreme example:
h05 <- function(x = ls()) {
  a <- 1
  x
}
# ls() evaluated inside h05:
h05()
#> [1] "a" "x"

# ls() evaluated in global envionment:
h05(ls())
#> [1] "h05"

# 6.5.3 Missing arguments

# To determine if an argument's value comes from the user or from a default, you cna use `missing()`:
h06 <- function(x = 10) {
  list(missing(x), x)
}
str(h06())
#> List of 2
#>  $ : logi TRUE
#>  $ : num 10
str(h06(10))
#> List of 2
#>  $ : logi FALSE
#>  $ : num 10

# `missing()` is best used sparingly, however. Take sample(), for example.
# How many arguments are required?
args(sample)
#> function (x, size, replace = FALSE, prob = NULL) 
#> NULL

# It looks like both `x` are required, but if `size` is not aupplied, `sample()` uses `missing()` to provide a default.
# If I were rewrite sample, I'd use an explicit `NULL` to indicate that `size` is not required but can be supplied:
sample <- function(x, size = NULL, replace = FALSE, prob = NULL) {
  if (is.null(size)) {
    size <- length(x)
  }
  
  x[sample.int(length(x), size, replace = replace, prob = prob)]
}

# With the binary pattern created by the `%||%` infix function, which uses the left side if it's not `NULL` and the right side otherwise, 
# we can further simplify `sample()`:
`%||%` <- function(lhs, rhs) {
  if (!is.null(lhs)) {
    lhs
  } else {
    rhs
  }
}

smaple <- function(x, size = NULL, replace = FALSE, prob = NULL) {
  size <- size %||% length(x)
  x[sample.int(length(x), size, replace = replace, prob = prob)]
}

# Because of lazy evaluation, you don't need to worry about unnecessary computation:
# the right side of `%||%` will only be evaluated if the left side is `NULL`.

# 6.5.4 Exercises

# 1. What important property of `&&` makes `x_ok()` work?
x_ok <- function(x) {
  !is.null(x) && length(x) == 1 && x > 0
}

x_ok(NULL)
#> [1] FALSE
x_ok(1)
#> [1] TRUE
x_ok(1:3)
#> [1] FALSE

#   What is different with this code? Why is this befaviour undesirable here?
x_ok <- function(x) {
  !is.null(x) & length(x) == 1 & x > 0
}
x_ok(NULL)
#> logical(0)
x_ok(1)
#> [1] TRUE
x_ok(1:3)
#> [1] FALSE FALSE FALSE

# We expect `x_ok()` to validate its input via certain criteria: it must not be `NULL`, 
# but have length `1` and a value greater than `0`.
# Meaningful outcomes for this assertion will be `TRUE`, `FALSE` or `NA`.

# The desired befaviour is reached by combining the assertions through `&&` instead of `&`.
# `&&` does not perform elementwise comparisons, instead it uses the first element of each value only .
# It also uses lazy evaluation, in the sense that evaluation "proceeds only until the result is determined" (from `?Logic`).

# For some situations (`x = 1`) both operators will lead to the same result.
# But this is not always the case. For `x = NULL`, the `&&`- operator will stop after the `!is.null` -statement and return the result.
# The following conditions won't even be evaluated! (If the other conditions are also evaluated(by the use of `&`), 
# the outcome would change. `NULL` > 0 returns `logical(0)``, which is not a helpful in this case.)

# We can also see the difference in bahaviour, when we set `x = 1:3`.
# The `&&`-operator returns the result from `length(x) == 1`, which is `FALSE`.
# Using `&` as the logical operator lead to the (vectorised) `x > 0` condition being be evaluated and also returned.

# 2. What does this function return? Why? Which prindiple does it illustrate?
f2 <- function(x = z) {
  z <- 100
  x
}
f2()

# The function reutrns `100`. The default arguments are evaluated in the function envionment.
# Because of lazy evaluatin these arguments are not evaluated before they are accessed.
# At the time `x` is accessed `z` has already been bound to the value `100`.

# 3. What does this function return? Why? Which principle does it illustrate?
y <- 10 
f1 <- function(x = {y <- 1; 2}, y = 0) {
  c(x, y)
}
f1()
y

# The function returns `c(2, 1)`. This is due to name masking.
# When `x` is accessed within `c()`, the promise `x = {y <- 1; 2}` is evaluated inside `f1()`'s environment.
# `y` is bound to the value `1` and the return value of `{()(2)` is assigned to `x`.
# When `y` is accessed within `c()`, it has already the value `1` and R doesn't need to look it up any further.
# Therefore, the promise `y = 0` won't be evaluated. Also, because `y` is assigned within `f1()`'s envionment, 
# the value of the global variable `y` is left untouched.

# 4. In `hist()`, the default value of `xlim` is `range(break)`, the default value fo r`breaks` is `"Sturges"`, and 
range("Struges")
#> [1] "Struges" "Struges"
# Explain how `hist()` works to get a correct `xlim` value.

# The `xlim` argument of `hsit()` defines the range of the histogram's x-axis.
# In order to proviede a valid axis `xlim` must contain a numeric vector of exctly two unique values.
# Consequently fot the default `xlim = range(breaks)`), `breaks` must evaluate to a vector with at least tow unique values.

# During execution `hist()` overwrites the `breaks` argument. The `breaks` argument is quite flexible and allows the users to provide the breakpoints directly or compute them in several ways.
# Therefore the specific behaviour depends highly on the input. 
# But `hist` ensures that `breaks` evaluates to a numeric vactor containing  at least two unique elements before `xlim` is computed.

# 5. Explain why this funciton works. Why is it confusing?
show_time <- function(x = stop("Error")) {
  stop <- function(...) Sys.time()
  print(x)
}
show_time()

# Before `show_time()` accesses `x` (default `stop("Error")`), the `stop()` function is masked by `function(...) Sys.time()`.
# Because default arguments are evaluated in the function envionment, `print(x)` will be evaluated as `print(Sys.time())`.

# This function i sconfusing, because its behavior changes when `x`'s value is supplied directly.
# Now the value from the calling environment will be used and the overwriting of `stop` won't affect the outcome any more.

# 6. How many arguments are required when calling `libaray()`?

# `library()` doesn't require any arguments. When called without arguments `library()` (invisibly) returns a list of class "libraryIQR", 
# which contains a retults matrix one row and three cloumns per installed package.
# These columns contain entries for the name of the package ("Package"), the path to the package ("LibPaht") and the title of the package ("Title").
# `library()` also has its own print methos (`print.libraryIQR`), which displays this information converiently in its own window.
str(formals(library))
attributes(library())

# 6.6 ...(dot-dot-dot)

# Fuctions can have a special argument `...` (prononunced dot-dot-dot).
# With it, a function can take any number of additinoal arguments.
# In other programming languages, this type of arguments is often called varargs (short for variable arguments), 
# and a function that uses it is said to be variadic.

# You can also use `...` to pass thos e additional arguemnts on to another function.
i01 <- function(y, z) {
  list(y = y, z = z)
}

i02 <- function(x, ...) {
  i01(...)
}

str(i02(x = 1, y = 2, z = 3))
#> List of 2
#>  $ y: num 2
#>  $ z: num 3

# Using a special form, `..N`, it's possible (but rarely useful) to refer to elements of `...`  by position:
i03 <- function(...) {
  list(first = ..1, third = ..3)
}
str(i03(1, 2, 3))
#> List of 2
#>  $ first: num 1
#>  $ third: num 3

# More useful is `list(...)`, which evaluates the arguments and stores them in a list:
i04 <- function(...) {
  list(...)
}
str(i04(a = 1, b = 2))
#> List of 2
#>  $ a: num 1
#>  $ b: num 2

# (See also `rlang::list2()`) to support splicing and to silently ignore trailing commas, and `rlang::enquos()` to capture unevaluated arguments, the topic of `quasiauotation`.)

# There are two primary uses of `...`, both of which we'll come back to later in the book:

# - If your function takes a function as an argument, you want some way to pass additional arguemtns to that function.
#   In this example, `lapply()` uses `...` to pass `na.rm` on to `mean()`:
x <- list(c(1, 3, NA), c(4, NA, 6))
str(lapply(x, mean, na.rm = TRUE))
#> List of 2
#>  $ : num 2
#>  $ : num 5

# If your function is an S3 generic, you need some way to allow methods to take arbitrary extra arguemnts.
# Because there are different options for printing depending on the type of object, 
# there's no way to pre-specify every possible argument and `...` allows individual methods to have different arguments:
print(factor(letters), max.levels = 4)
print(y ~ x, showEnv = TRUE)
# We'll come back to this use of `...` in Section 13.4.3

# using `...` comes with tow downside:

# - When you use it to pass argument to another function, you have to carefully ecplain to the user where those arguments go.
#   This makes it hard to understard what you can do with functions like `lapply()` and `plot()`.

# - A misspelled argument will not raise an error.
#   This makes it easy for typos to go unnoticed:
sum(1, 2, NA, na_rm = TRUE)
#> [1] NA

# 6.6.1 Exercises

# 1. Explain the following results:
sum(1, 2, 3)
#> [1] 6
mean(1, 2, 3)
#> [1] 1

sum(1, 2, 3, na.omit = TRUE)
#> [1] 7
mean(1, 2, 3, na.omit = TRUE)
#> [1] 1

# Let's inspect the arguemtns and their order for both functions.
# for `sum()` these are `...` and `na.rm`:
str(sum)
#> function (..., na.rm = FALSE)  

# For the `...` argument `sum()`expects numeric, complex, or logical vector input (see ?sum).
# Unfortunately, when `...` is used, misspelled arguments (!) like `na.omit` won't raise an error (when no further input checks are implementeed).
# So instead, `na.omit` is treated as a logical and becomes part of the `...` argument.
# It will be coerced to `1` and be part of the sum. All other arguments are left unchanged.
# therefore `sum(1, 2, 3)` returns `6` and `sum(1, 2, 3, na.omit = TRUE)` returns `7`.

# In contrast, the generic funciton `mean()` expects `x`, `trim`, `na.rm` and `...` for its default method.
str(mean.default)
#> function (x, trim = 0, na.rm = FALSE, ...)  

# Because na.omit is not one of mean()’s named arguments (and also not a candidate for partial matching), na.omit again becomes part of the ... argument.
# The other supplied objects are matched by their order, i.e.: x = 1, trim = 2 and na.rm = 3. 
# Because x is of length 1 and not NA, the settings of trim and na.rm do not affect the calculation of the mean. Both calls (mean(1, 2, 3) and mean(1, 2, 3, na.omit = TRUE)) return 1.

# 2. Explain how to find the documentation for the named arguments in the followign function call:
plot(1:10, col = "red", pch = 20, xlab = "x", col.lab = "blue")

# First we type `?plot` in the console and check the "Usage" section:
#> plot(x, y, ...) 
# The arguments we want ot lwarn more about are part of the `...` argument.
# We can find indormation fo r`xlab` and follow the recommentdation to visit `?par` for the other arguemtns.
# Here we type "col" into the search bar, which leads us the seciton "Oolor Specification".
# We also search for the `pch` argument, thich lead to the recommendation to check `?points`.
# Finally `col.lab` is also directly documented within `?par`.


# 3. Why does `plot(1:10, col = "red")` only colour the points, not the axes or labels?
#    Read the source code of `plot.default()` to find out.

# TODO


# 6.7 Exiting a function

# Most functions exit in one of two ways: they either return a vlaue, indication success, or they thorw an error, indicating failure.
# This seciton describes return values(ipmolicit versus expicit; visible versus invisible) ,
# briefly discusses errors, and introuces exit handlers, which allow you to run code when a function exits.

# 6.7.1 Implicit versuss explicit returns

# There are two ways that a function can return a value:

# - Implicitly, where the last evaluated expression is the reutrn value:
j01 <- function(x) {
  if (x < 10) {
    0
  } else {
    10
  }
}
j01(5)
#> [1] 0
j01(15)
#> [1] 10

# - explicitly, by calling `return()`:
j2 <- function(x) {
  if (x < 10) {
    return(0)
  } else {
    return(10)
  }
}

# 6.7.2 Invisible values

# Most functions return visibly: calling the function in an interactirve context prints the result.
j03 <- function() 1
j03()
#> [1] 1

# However, you can prevent automatic printing by applying `invisible()` to the last value:
j04 <- function() invisible(1)
j04()

# To vertify that this value does indeed exist, you cna explicitly print it or wrap ti in parentheses:
print(j04())
#> [1] 1
(j04())
#> [1] 1

# Alternatively, you can use `withVisible()` to return the value and a visibility flag:
str(withVisible(j04()))
#> List of 2
#> $ value  : num 1
#> $ visible: logi FALSE

# The most comment function that returns invisibly is `<-`:
a <- 2
(a <- 2)
#> [1] 2

# This is what makes ti possible to chain assignments:
a <- b <- c <- d <- 2
# In general, any function called primarily for a side effect (like `<-`, `print()`, or `plot()`) should return an invisible value (typically the value of the first argument.)

# 6.7.2 Errors

# If a function cannot complete its assigned task, it should throw an error wtih `stop()`, 
# which immediately terminates the execurtion of the function.
j05 <- function() {
  stop("I'm an error") 
  return(10)
}
j05()
#> Error in j05() : I'm an error

# An error indicates that something ahs gone wrong, and forces the iser to deal with the problem.
# Some languages (like C, Go, and Rust) rely on special return values to indicate problems, 
# but in R you should alway throw an error. 
# You'll learn mor abbout errors, and how to handle them, in Chapter 8.

# 6.7.4 Exit handlers

# Sometimes a function need to make temporary changes to the global state.
# But havign to cleanup those changes can be painful (what happens if there's an error?).
# To ensure that chandges are undone and that the global state is restored no matter how a function exits,
# use `on.exit()` to set up an __exit handler__.
# The following simple example shows that the exit handler is run regardless of whether the function exits normally or with an error.
j06 <- function(x) {
  cat("Hello\n")
  on.exit(cat("Goodbye!\n"), add = TRUE) 
  
  if (x) {
    return(10)
  } else {
    stop("Error")
  }
}
j06(TRUE)
#> Hello
#> Goodbye!
#> [1] 10
j06(FALSE)
#> Hello
#> Error in j06(FALSE) : Error
#> Goodbye!

# Always set `add = TRUE` when using `on.exit()`. 
# If you don't, each call to `on.exit()` will overwrite the previous exit handler.
# Even when only registering a single handler, 
# it's good practice to set `add = TRUE` so that you won't get any unpleasant surprises if you later add more exit handlers.

# `on.exit()` is useful because it allows you to place clean-up code directly next to the code that requires clean-up:
cleanup <- function(dir, code) {
  old_dir <- setwd(dir)
  on.exit(setwd(old_dir), add = TRUE)
  
  old_opt <- options(stringsAsFactors = FALSE)
  on.exit(options(old_opt), add = TRUE)
}

# Coupled with lazy evaluation, this creates a very useful pattern for running a block of code in an altered envionment:
with_dir <- function(dir, code) {
  old <- setwd(dir)
  on.exit(setwd(old), add = TRUE)
  force(code)
}
getwd()
#> [1] "/Users/peter/Documents/Project/Notebook/Notebook_with_R"
with_dir("~", getwd())
#> [1] "/Users/peter"

# The use of `force()` isn't strictly necessary here as simply referring to `code` will force its evaluation.
# However, using `force()` makes it very clear that we are deliberately forcing the execution.
# You'll learn other uses of `force()` in Chapter 10.

# The withr package (Hester et al. 2018) porvides a collection of other functions for setting up a temporary state.

# In R 3.4 and earlier, `on.exit()` expressions are always run in order of creation:
j08 <- function() {
  on.exit(message("a"), add = TRUE)
  on.exit(message("b"), add = TRUE)
}
j08()
#> a
#> b

# This can make cleanup a little tricky if some actions need to ahppen in a specific order; 
# Typically you want the most recent added expression to be run first.
# In R 3.5 and later, you can contrlo this by setting `after = FALSE`:
j09 <- function() {
  on.exit(message("a"), add = TRUE, after = FALSE)
  on.exit(message("b"), add = TRUE, after = FALSE)
}
j09()
#> b
#> a

# 6.7.5 Exercises

# 1. What does `load()` return? Why don't you normally see these values?

# `load()` leads objects saved to disk in `.Rdata` files by `save()`.
# When run sucessfully, `laod()` invisibly returns a character vector containing the names of the noewly loaded objects.
# To print these names to the console, one can set the argument `verbose` to `TRUE` or surround the call in parentheses to trigger R's auto -printing mechanism.

# 2. What does `write.table()` return? What would be more useful?

# `write.table()` writes an onject, usually a data frame or a matrix, to disk.
# The function invisibly returns `NULL`.
# It would be more usuful if `write.table()` would (invisibly) return the input data, `x`.
# This would allow to save intemediate results and directly take on further processing steps without breaking the flow of the code (i.e. breaking it into different lines).
# One package which uses this pattern is the readr package, which is part of the "tidyverse"-ecosystem.

# 3. How does the `chdir` aprameter of `source()` compare to `with_dir()`?
#    Why might you prefer one to the other?

# The `in_dir()` approach was given in the book as 
in_dir <- function(dir, code) {
  old <- setwd(dir) 
  on.exit(setwd(old))
  
  force(code)
}

# `in_dir()` takes a path to a working directory as an argument.
# First the working directory is changed accordingly.
# `on.exit()` ensure that the modification to the working directory are reset to the initial value when the function exits.

# In `source()` the `chdir` argument specifies if the working directory should be changed during the evaluation of the `file` argument
# (which in this case has to be a pathname).

# 4. Write a function that opens a graphics device, runs the supplied code, and closes the graphics device
#    (always, regardless of whether or not the plotting code works).

# To contrl the graphics device we use `pdf()` and `dev.off()`.
# To ensure a clean termination `on.exit()` is used.
plot_pdf <- function(code) {
  pdf("test.pdf")
  on.exit(dev.off(), add = TRUE)
  code
}

plot_pdf("test")

# 5. We can use `on.exit()` to implement a simple version of `capture.output()`.
capture.output2 <- function(code) {
  temp <- tempfile()
  on.exit(file.remove(temp), add = TRUE, after = TRUE)
  
  sink(temp)
  on.exit(sink(), add = TRUE, after = TRUE)
  
  force(code)
  readLines(temp)
}
capture.output2(cat("a", "b", "c", sep = "\n"))
#> [1] "a" "b" "c"

# Compare `capture.output()` to `capture.output2()`. How do the function differ? 
# What feature hvae I removed to make the key ideas easier to see?
# How have I rewritten the key ideas so they're easier to understand?

# Using `body(capture.output)` we inspect the source code of the origial capture.output() function.
# `capture.output()` is a quite a bit longer(39 lines v.s. 7 lines).
# `capture.output()` write out entire methods, such as `readLines()`.
# Instead `capture.output2()` calls these methods directly.
# This brevity and modularity makes `capture.output2` easier to understad(given you know the underlying methods).

# 6.8 Function forms

# To understand computations in R, two slogans are helpful:

# - Everything that exists is an object.
# - Everything that happens is a function call.
# -- John chambers

# While everything that happens in R is a result of a function call, 
# not all calls look the same. Function calls in four varieties:

# - prefix: the function name comes before its arguments, like `foofy(a, b, c)`.
#   These condtitute of the majority of function calls in R.

# - infix: the function name comes in between its arguments, like `x + y`.
#   Infix forms are used for many mathematical operators, and for user-defined functions that begin and end with `%`.

# - replacement: functions that replace values by assignment, like `names(df) <- c("a", "b", "c")`.
#   They catually look like prefix functions.

# - special: functions like `[[`, if, and `for`. While they don't have a consistent structure, 
#   they play important roles in R's syntax.

# While there are four forms, you actually only need one because any call can be written in prefix form.
# I'll demostrate this property, and then you'll learn about each of the forms in turn.

# 6.8.1 Rewriting to prefix form

# An interesting property of R is that every infix, replacement, or special form can be rewritten in prefix form.
# Doing so is useful because it helps you better understand the structure fo the language, 
# it gives you the real name of every function, and it allows you to modify those functoins for fun and profit.

# The following example shows three pairs of equivalent calls, rewriting an innfix form, 
# replacement form, and special form into prefix form.
x + y
`+`(x, y)

names(df) <- c("x", "y", "z")
`names<-`(df, "x", "y", "z")

for (i in 1:10) print(i)
`for`(i, 1:10, print(i))

# Suprisingly, in R, `for` can be called like a regular function! The same is true fo rbasically every operation in R,
# which menas that knowing the function name of a non-prefix function allows you to override its behaviour.
# For exmaple, if you're ever feeling particularly eval, run the following code while a friend is away from their computer.
# It will introduce a fun bug: 10% of the time, it will add 1 to any numeric calculatoin inside the parentheses.
`(` <- function(e1) {
  if (is.numeric(e1) %% runif(1) < 0.1) {
    e1 + 1
  } else {
    e1
  }
}
replicate(50, (1 + 2))
#> [1] 3 4 3 3 3 3 3 3 3 3 4 3 4 3 3 4 4 4 3 3 4 3 3 3 4 4 4 4 4 3 3 4 4 3 4 4 3 3 3 3 3 4 4 3 3 4 4 4 3 4
rm("(")

# Of course, overriding built-in functions like this is a bad idea, but, as you'll learn in Section 21.2.5, 
# it's possible to apply it only to selected code blocks.
# This provides a clean and elegant approach to writing domain specific languages and traslators to other languages.

# A more useful application comes up when using functional programming tools.
# For example, you could use `lapply()` to add 3 to every element of a list by first defining a function `add()`:
add <- function(x, y) x + y
lapply(list(1:3, 4:5), add, 3)
#> [[1]]
#> [1] 4 5 6
#> 
#> [[2]]
#> [1] 7 8

# But we can also get the same result simply by relying on the existing `+` function:
lapply(list(1:3, 4:5), `+`, 3)
#> [[1]]
#> [1] 4 5 6
#> 
#> [[2]]
#> [1] 7 8

# We'll explore this idea in detail in Section 9.

# 6.8.2 Prefix form

# The prefix form is the common form in R code, and indeed in the majority of programming languages.
# Prefix calls in R are a little special because you can specify arguments in three ways:

# - By position, like `help(mean)`.
# - Using partial matching, like `help(top = mean)`.
# - By name, like `help(topic = mean)`.

# As illustrated by the following chunk, arguments are matched by exact name, then with unique prefixes, and finally by position.
k01 <- function(abcdef, bcde1, bcde2) {
  list(a = abcdef, b1 = bcde1, b2 = bcde2)
}
str(k01(1, 2, 3))
#> List of 3
#>  $ a : num 1
#>  $ b1: num 2
#>  $ b2: num 3
str(k01(2, 3, abcdef = 1))
#> List of 3
#>  $ a : num 1
#>  $ b1: num 2
#>  $ b2: num 3

# Can abbreviate long argument names:
str(k01(2, 3, a = 1))
#> List of 3
#>  $ a : num 1
#>  $ b1: num 2
#>  $ b2: num 3

# But this doesn't work because abbreviation is abbiguous
str(k01(1, 3, b = 1))
#> Error in k01(1, 3, b = 1) : argument 3 matches multiple formal arguments

# In genreral, use positional matching only for the first one or two arguments;
# they will be the most commonly used, and most readers will know what they are.
# Avoid using positional matching for less commonly used arguments, and never use partial matching.
# Unforunately you can't disable partial matching, but you can turn it into a warning with the `warnPartialMatchArgs` option:
options(warnPartialMatchArgs = TRUE)
x <- k01(a = 1, 2, 3)
#> Warning message: In k01(a = 1, 2, 3) : partial argument match of 'a' to 'abcdef'

# 6.8.3 Infix functions

# Infix functions get their name from the fact the function name comes ingetween its arguments, and hence have two arguments.
# R comes with a number of built-in infix operators: 
# `:`, `::`, `:::`, `$`, `@`, `^`, `*`, `/`, `+`, `-`, `>`, `>=`, `<=`, `==`, `!=`, `!`, `&`, `&&`, `|`, `||`, `~`, `<-`, and `<<-`.
# You can also create your own infix functions that start and end with `%`.
# Base R uses this pattern to define `%%`, `%*%`, `%/%`, `%in%`, `%o%`, and `%x%`.

# Defining your own infix function is simple.
# You create a two argument function and bind it to a name that starts and ends with `%`:
`%+%` <- function(a, b) paste0(a, b)
"new " %+% "string"
#> [1] "new string"

# The names of infix functions are more flexible than regular R functions: 
# they can contain any sequence of characters except for `%`.
# You will need to escape any special characters in the string used to define the function, but not when you call it:
`% %` <- function(a, b) paste(a, b)
`%/\\%` <- function(a, b) paste(a, b)

"a" % % "b"
#> [1] "a b"
"a" %/\% "b"
#> [1] "a b"

# R's default precedence rules mean that infix operators are composed left to right:
`%-%` <- function(a, b) paste0("(", a, " %-% ", b, ")")
"a" %-% "b" %-% "c"
#> [1] "((a %-% b) %-% c)"

# There are two special infix functions that can be called with a single argument: `+` and `-`.
-1
#> [1] -1
+10
#> [1] 10

# 6.8.4 Replacement functions

# Replacement functions act like they modify their arguments in place, and have the special name `xxx<-`.
# They must have arguemnts names `x` and `value`, and must return the modified object.
# For exmaple, the following function modifies the second element of a vector:
`second<-` <- function(x, value) {
  x[2] <- value
  x
}

# Replacement functions are used by placing the function call on the left side of `<-`:
x <- 1:10
second(x) <- 5L
x
#>  [1]  1  5  3  4  5  6  7  8  9 10

# I say they act like they modify their arguments in place, because, as explained in Section 2.5,
# they actually create a modified copy. We can see that by using `tracemem()`:
x <- 1:10
tracemem(x)
#> [1] "<0x11c3e4a88>"

second(x) <- 6L
#> tracemem[0x11c3e4a88 -> 0x1139fb5e8]: 
#> tracemem[0x1139fb5e8 -> 0x1139fb7a8]: second<- 

# If your replacement function needs additional arguments, place them between `x` and `value`, and call the replacement function with additional arguments on the left:
`modify<-` <- function(x, position, value) {
  x[position] <- value
  x
}
modify(x, 1) <- 10
x
#> [1] 10  6  3  4  5  6  7  8  9 10

# When you write `modify(x, 1) <- 10`, behind the scenes R turns it into:
x <- `modify<-`(x, 1, 10)

# Combining replacement with other functions requires more complex translation.
# For exmaple:
x <- c(a = 1, b = 2, c = 3)
names(x)
#> [1] "a" "b" "c"

names(x)[2] <- "two"
names(x)
#> [1] "a"   "two" "c"  

# is translated into :
`*tmp*` <- x
x <- `names<-`(`*tmp*`, `[<-`(names(`*tmp*`), 2, "two"))
rm(`*tmp*`)

# (Yes, it really does create a local variable named `*tmp*`, which is removed afterwards.)

# 6.8.5 Special forms

# Finally, there are a bunch of language features that are usually written in special ways, 
# but also have prefix forms, 

# These include parentheses:

# - (x)  (`(`(x))
# - {x}  (`{`(x))

# The subsetting operators:

# - x[i]  (`[`(x, i))
# - x[[i]] (`[[`(x, i))

# And the tools of control flow:

# - if (cond) true               (`if`(cond, true))
# - if (cond) true else false    (`if`(cond, true, false))
# - for (var in seq) action      (`for`(var, seq, action))
# - while(cond) action           (`while`(cond, action))
# - repeat expr                  (`repeat`(expr))
# - next                         (`next`())
# - break                        (`bread`())

# Finally, the most complex is the `function` function:

# - function(arg1, arg2) {body}  (`function`(alist(arg1, arg2), body, env))

# knowing the name of the function that underlies a spwcial form is useful for getting documentation: `?(` is a syntax error;
# `?`(`` will give you the documentation fo rparentheses.

# All special form sare implemented as primitive functions (i.e. in C);
# this means printing these function is not informative:
`for`
#> .Primitive("for")

# 6.8.6 Exercises 

# 1. Rewrite the following code snippets into prefix form:
1 + 2 + 3

1 + (2 + 3)

if (length(x) <= 5) x[[5]] else x[[n]]

# Let's rewrite the expressions to match the exact syntax from the code above.
# Because prefix function already define the execution order, 
# we may omit the parentheses in the second expression.

`+`(`+`(1, 2), 3)

`+`(1, `+`(2, 3))
`+`(1, `(`(`+`(2, 3)))

`if`(`<=`(length(x), 5), `[[`(x, 5), `[[`(x, n))

# 2. Clarify the following list of odd function calls:
x <- sample(replace = TRUE, 20, x = c(1:10, NA))
y <- runif(min = 0, max = 1, 20)
cor(m = "k", y = y, u = "p", x = x)

# None of these functions provides a `...` argument.
# Therefore the function arguments are first matched exactly, then via partial matching and fincally by positoin.
# This leads us to the following explicit function calls:
x <- sample(c(1:10, NA), size = 20, replace = TRUE)
x <- runif(20, min = 0, max = 1)
cor(x, y, use = "pairwise.complete.obs", method = "kendall")

# 3. Explain why the following code fails:
modify(get("x"), 1) <- 10
#> Error in modify(get("x"), 1) <- 10 : target of assignment expands to non-language object

# First, let's define `x` and recall the definition of `modify()` from the textbook:
x <- 1:3

`modify<-` <- function(x, position, value) {
  x[position] <- value
  x
}

# R internally transorms the code and the transformed code reproduces the error above.

get("x") <- `modify<-`(get("x"), 1, 10)
#> Error in get("x") <- `modify<-`(get("x"), 1, 10) : target of assignment expands to non-language object

# The error occurs during the assignment, because no corresponding replacement function, i.e. `get<-` exists for `get()`.
# To confirm this we can reproduce the error via the following simple example.
get("x") <- 2
#> Error in get("x") <- 2 : target of assignment expands to non-language object

# 4. Create a repalcement function that modifies a random location in a vector.
`random<-` <- function(x, value) {
  idx <- sample(length(x), 1)
  x[idx] <- value
  x
}

# 5. Write your own version of `+` that pastes inputs together if they are cahracter vectors but behaves as usual otherwise.
#    In other words, make this code work:
1 + 2
#> [1] 3

"a" + "b"
#> [1] "ab"

# To achieve this behaviour, we need to override the `+` operator.
# We need to take care to not use the `+` operator itself inside of the function definition, 
# because this would lead to an undesired infinite recursion.
# We also add `b = 0L` as a default value to keep the behaviour of `+` as a unary operator,
# i.e.. to keep `+1` workign and not throwing an error:
`+` <- function(a, b = 0L) {
  if (all(is.numeric(c(a, b)))) {
    base::`+`(a, b)
  } else {
    paste0(a, b)
  }
}

`+` <- function(a, b = 0L) {
  if (is.character(a) && is.character(b)) {
    paste0(a, b)
  } else {
    base::`+`(a, b)
  }
}

# test functionality
+ 1
#> [1] 1
1 + 2
#> [1] 3
"a" + "b"
#> [1] "ab"

# return back to the original `+` operator
rm(`+`)

# 6. Create a list of all the replacement functions found in the base package.
#    Which ones are primitive function? (Hint: use apropos().)

# The hint suggests to look for functions with a specific naming pattern:
# Replacement functions conventionally end on `<-`.
# We can search these objects with a regular expressoin(`<-$`)
apropos("<-$")

# However, instead of `apropos()` we will use `ls()` and adopt a bit of the code from a previous exercise.
# (This makes it easier to work with environments explicitly.)
# We first find all the objects in the base package which end on `<-`, 
# then filter to only look at functions:
repl_nms <- ls(baseenv(), all.names = TRUE, pattern = "<-$")
repl_objects <- mget(repl_nms, baseenv())
repl_functions <- Filter(is.function, repl_objects)
length(repl_functions)
#> [1] 35

# Additionally, we also filter for frimitive functions.
# Overall base R contains 35 replacement functions.
# The following 17 of them are also primitive functions:
names(Filter(is.primitive, repl_functions))
#> [1] "[[<-"           "[<-"            "@<-"            "<-"             "<<-"           
#> [6] "$<-"            "attr<-"         "attributes<-"   "class<-"        "dim<-"         
#> [11] "dimnames<-"     "environment<-"  "length<-"       "levels<-"       "names<-"       
#> [16] "oldClass<-"     "storage.mode<-"

# 7. What are valid names for user-created infix functions?

# Let's cite __Advanced R__ here (section on "Function Forms"):
# ...names of infix functions are more flexible than regular R functions:
# they can contain any sequence of characters except "%".

# 8. Create an infix `xor()` operator.
`%xor%` <- function(a, b) {
  xor(a, b)
}

TRUE %xor% TRUE
#> [1] FALSE
FALSE %xor% TRUE
#> [1] TRUE

# 9. Create infix versions of the set functions `intersect()`, `union()`, and `setdiff()`.
#    You might call them `%n%`, `%u%`, and `%/%` to match conventions from mathematics.
`%n%` <- function(a, b) {
  intersect(a, b)
}

`%u%` <- function(a, b) {
  union(a, b)
}

`%/%` <- function(a, b) {
  setdiff(a, b)
}

x <- c("a", "b", "d")
y <- c("a" ,"c", "d")

x %u% y
#> [1] "a" "b" "d" "c"
x %n% y
#> [1] "a" "d"
x %/% y
#> [1] "b"
