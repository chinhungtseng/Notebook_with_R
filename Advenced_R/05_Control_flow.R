set.seed(1014)

# 5 Control flow 

# 5.1 Introduction

# There are two primary tools of control flow: choices and loops.
# Choices, like `if` statements and `switch()` callls, allow you to run different code depending on the input.
# Loops, like `for` and `while`, allow you to repeatedly run code, typically with changing options.
# I'd expect that you're already familiar with the basics of these functions so I'll briefly cover some technical details and then introduce some useful, but lesser known, features.

# The condition system (messages, warnings, and errors), which you'll learn about int Chapter 8, also provides non-local control flow.

# Quiz

# Want to skip this chapter? Go fo it, if you can asnwer the questions below.
# Find the answers at the end of the chapter in SEction 5.4.

# 1. What is the different between `if` and `ifelse()`?

# 2. In the following code, what will the value f `y` be if `x` is `TRUE`?
#    What if `x` is `FALSE`? What if `x` is `NA`?
y <- if (x) 3

# 3. What does `switch("x", x = , y = 2, z = 3)` return?

# Outline 

# - Section 5.2 dives into the details of `if`, then discusses the close relatives `ifelse()` and `switch()`.

# - Section 5.3 starts off by reminding you of the basic structure of the for loop in R,
#   discusses some common pitfalls, and then talks about the related `while` and `repeat` statements.

# 5.2 Choices

# The basic form of an if statement in R is as follows:
if (condidtion) true_action
if (condition) true_action else false_action

# If `condition` is `TRUE`, `ture_cation` is evaluated; 
# if `condition` is `FALSE`, the optional `false_action` is evaluated.

# Typically the actions are compound statements contained within `{`:
grade <- function(x) {
  if (x > 90) {
    "A"
  } else if (x > 80) {
    "B"
  } else if (x > 50) {
    "C"
  } else {
    "F"
  }
}

# `if` returns a value so that you can assign the results:
x1 <- if (TRUE) 1 else 2
x2 <- if(FALSE) 1 else 2
c(x1, x2)
#> [1] 1 2

# (I recommend assigning the results os an `if` statement only when the entire expression fits on one line;
#  otherwise it tend to be hard to read.)

# When you use the single argument form without an else statement, `if` invisibly (section 6.7.2) returns `NULL` if the condition is `FALSE`.
# Since functinos like `c()` and `paste()` drop `NULL` inputs, this allows for a compact expression of certain idioms:
greet <- function(name, birthday = FALSE) {
  paste0(
    "Hi ", name,
    if (birthday) " and HAPPY BIRTHDAY"
  )
}
greet("Maria", FALSE)
greet("Jaime", TRUE)

# 5.2.1 Invalid inputs

# The `condition` should evaluate to a single `TRUE` or `FALSE`. Most other inputs will generate an error:
if ("x") 1
#> Error in if ("x") 1 : argument is not interpretable as logical
if (logical()) 1
#> Error in if (logical()) 1 : argument is of length zero
if (NA) 1
#> Error in if (NA) 1 : missing value where TRUE/FALSE needed

# The exctption is a logical vector of length greater than 1, which generates a warning:
if (c(TRUE, FALSE)) 1
# [1] 1
# Warning message:
# In if (c(TRUE, FALSE)) 1 : the condition has length > 1 and only the first element will be used

# In R 3.5.0 and greater, thanks to Henrik Bengtsson, you can turn this into an error by setting an envionment variable:
Sys.setenv("_R_CHECK_LENGTH_1_CONDITION_" = "true")
if (c(TRUE, FALSE)) 1
#> Error in if (c(TRUE, FALSE)) 1 : the condition has length > 1

# I think this is good practice as it reveals a clear mistake that you might otherwise miss if it were only shown as a warning.

# 5.2.2 Vectorised if 

# Given that `if ` only works with a single `TRUE` or `FALSE`, you might wonder what to do if you a vector of logical values.
# Handing vectors of values is the job of `ifelse()`: a vectorised funciton with `test`, `yes`, and `no` vectors(that will be recycled to the same length):
x <- 1:10
ifelse(x %% 5 == 0, "xxx", as.character(x))
#> [1] "1"   "2"   "3"   "4"   "xxx" "6"   "7"   "8"   "9"   "xxx"

ifelse(x %% 2 == 0, "even", "odd")
#> [1] "odd"  "even" "odd"  "even" "odd"  "even" "odd"  "even" "odd"  "even"

# Note that missing values will be propagated into the output.

# I recommend using ifelse() only when the yes and no vectors are the same type as it is otherwise hard to predict the output type. 
# See https://vctrs.r-lib.org/articles/stability.html#ifelse for additional discussion.

# Another vectorised equivalent is the more general dplyr::case_when(). It uses a special syntax to allow any number of condition-vector pairs:
dplyr::case_when(
  x %% 35 == 0 ~ "fizz buzz",
  x %% 5 == 0 ~ "fizz",
  x %% 7 == 0 ~ "buzz",
  is.na(x) ~ "???",
  TRUE ~ as.character(x)
)
#> [1] "1"    "2"    "3"    "4"    "fizz" "6"    "buzz" "8"    "9"    "fizz"

# Closely related to `if` is the `switch()`-statement.
# It's a compact, special purpose equivalent that lets you replace code like:
x_option <- function(x) {
  if (x == "a") {
    "option 1"
  } else if (x == "b") {
    "option 2"
  } else if (x == "c") {
    "option 3"
  } else {
    stop("Invalid `x` value")
  }
}

# With the more succinct:
x_option <- function(x) {
  switch(x,
    a = "option 1",
    b = "option 2",
    c = "option 3",
    stop("Invalid `x` value")
  )
}

# The last component of a `switch()` should always throw an error, otherwise unmatched inputs will invisibly return `NULL`:
(switch("c", a = 1, b = 2))
#> NULL

# If multiple inputs have the same output, you can leave the right hand side of `=` empty adn the input will "all through" to the nexe value.
# This minics the behaviour of C's `swith` statement:
legs <- function(x) {
  switch(x,
    cow = ,
    horse = ,
    dog = 4,
    human = ,
    chicken = 2,
    plant = 0,
    stop("Unknown input")
  )
}
legs("cow")
#> [1] 4
legs("dog")
#> [1] 4

# It is also possible to use `switch()` with a numeric `x`, but is harder to read, and has undesirable failure modes if `x` is a not a whole number.
# I recommend using `switch()` only with character inputs.

# 5.2.4 Exercises

# 1. What type of vector does each of the following calls to `ifesle()` return?
ifelse(TRUE, 1, "no")
ifelse(FALSE, 1, "no")
ifelse(NA, 1, "no")
# Read the documentation and write down the rules in your own words.

# The arguments of `ifelse()` are `test`, `yes` and `no`.
# `ifelse()` is vectorised, so when `yes` or `no` are shorter than `test`, they will be recycled.
# (When they are longer than `test`, their additional elements will be ignored.)

# 2. Why does the following code work?
x <- 1:10
if (length(x)) "not empty" else "empty"
#> [1] "not empty"

x <- numeric()
if (length(x)) "not empty" else "empty"
#> [1] "empty"

# `if()` expects a logicla condition, but also accepts a numeric vactor where `0` is treated as `FALSE` and all other numbers are treated as `TRUE`.
# Numeric missing values (including `NaN`) lead to an error in the same way that a logical missing, `NA`, does.

# 5.2 Loops

# `for` loops are used to iterate over items in a vector.
# They have the following basic form:

for (item in vector) perform_action

# For each item in `vector`, `perform_action` is call once; updating the value of `item` each time.
for (i in 1:3) {
  print(i)
}
#> [1] 1
#> [1] 2
#> [1] 3
# (When iterating over a vector of indices, it's convertional to use very short variable names like `i`, `j`, or `k`.)

# N.B.: `for` assigns the `item` to the current environment, overwriting any existing variable with the same name:
i <- 100
for (i in 1:3) {}
i
#> [1] 3

# There are two ways to terminate a `for` loop early:
for (i in 1:10) {
  if (i < 3)
    next
  
  print(i)
  
  if (i >= 5)
    break
}
#> [1] 3
#> [1] 4
#> [1] 5

# 5.3.1 Common pitfalls

# There are three common pitfalls to watch out for when using `for`.
# First, if you're generating data, make sure to preallocate the output container.
# Otherwise the loop will be very slow; see Section 23.2.2 and 246 for more details.
# The `vector()` function is helpful here.
means <- c(1, 50, 20)
out <- vector("list", length(means))
for (i in 1:length(means)) {
  out[[i]] <- rnorm(10, means[[i]])
}

# Next, beware of iterating over `1:length(x)`, which will fail in unhelpful ways if `x` has length 0:
means <- c()
out <- vector("list", length(means)) 
for (i in 1:length(means)) {
  out[[i]] <- rnorm(10, means[[i]])
}
#> Error in rnorm(10, means[[i]]) : invalid arguments

# This occurs because `:` works with both increasing and decreasing sequences:
1:length(means)
#> [1] 1 0

# Use `seq_along(x)` instead. It always returns a value the same length as `x`:
seq_along(means)
#> [1] integer(0)

out <- vector("list", length(means))
for (i in seq_along(means)) {
  out[[i]] <- rnorm(10, means[[i]])
}

# Finally, you might enocounter problems when iterating over S3 vector, as loops typically strip the attributes:
xs <- as.Date(c("2020-01-01", "2010-01-01"))
for (x in xs) {
  print(x)
}
#> [1] 18262
#> [1] 14610

# Work around this by calling `[[` yourself:
for (i in seq_along(xs)) {
  print(xs[[i]])
}
#> [1] "2020-01-01"
#> [1] "2010-01-01"

# 5.3.2 Related tools

# `for` loops are useful if you know in advance the set of vlaues that you want to iterate over.
# If you don't know, there are two related tools with more flexible specifications:

# - `while(condition) action`: performs `action` while `condition` is `TRUE`.
# - `repeat(action)`: repeats `action` forever (i.e. until it encounters `break`).

# R does not have an equivalent to the `do {action} while (condition)` syntax found in other languages.

# You can rewrite any `for` loop to use `while` instead, and you can rewrite any `while` loop to use `repeat`, but the converses are not true.
# That means `while` is more flexible than `for`, and `repeat` is more flexible than `while`.
# It's good practice, however, to use the least-flexible sulution to a problem, so you should use `for` wherever possible.

# Generally speaking you shouldn't need to use `for` loops for data analysis tasks, as `map()` and `apply()` already provide less flexible solutions to most problems.
# You'll learn more in Chapter 9.

# 5.3.3 Exercises 

# 1. Why does this code succeed without errors or warnings?
x <- numeric()
out <- vector("list", length(x))
for (i in 1:length(x)) {
  out[i] <- x[i] ^ 2
}
out


# When the following code is evlauated, what can you say about the vector being iterated?
xs <- c(1, 2, 3)
for (x in xs) {
  xs <- c(xs, x * 2)
}
xs
#> [1] 1 2 3 2 4 6




# What does the following code tell you about when the index is updated?
for (i in 1:3) {
  i <- i * 2
  print(i)
}
#> [1] 2
#> [1] 4
#> [1] 6

# 5.4 Quiz answers

# - `if` works with scalars; `ifelse()` works with vectors.

# - When `x` is `TRUE`, `y` will be `3`; when `FALSE`, `y` will be `NULL`;
#   When `NA` the if statement will throw an error.

# - This `switch()` statement makes use of fall-through so it will retyrn 2.
#   See details in Seciton 5.2.3.
