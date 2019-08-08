set.seed(1014)

# Introduction

# R, at its heart, is a __functional__language. This means tha tit has certain technical properites, 
# but more importantly that it lends itself to a style of problem solving centred on functions.
# Below I'll give a brief overview of the technical definition of a functional language, 
# but in this book I will primaryli focus on the functional style of programming, 
# because I think it is an extremely good fit to the tyrpes of proglem you commonly encourter when doing data analysis.

# Recently, functional techniques have experienced a surge in interest because they can procude efficient and elegant solutions to many modern problems.
# A functional sytle tends to create functions that can easily be analysed in isolation (i.e. using only local information),
# and hence is often much easier to automatially optimise of parallelise.
# The traditional weadnesses of functional langeages, poorer performance and sometimes unpredictable memory usage, have been much reduced in recent years.
# Functional programming is complementary to object-oriented programming,
# which has been the domainant programming paradigm for the last everal decades.

# Funtional programming languages

# Every programming language has functions, so what makeas a programming language funcitonal?
# There are many definitions for precisely what makes a language functional, but there are two common threads.

# Firstly, functional languages have __first-class functions__, functions that behave like any other data structure.
# In R, this means that you can do many of the things with a function that you can do with a vector:s
# you can assign them to variables, store them in lists, pass them as arguments to other functions, create them inside functions, 
# and even return them as the result of a function.

# Secondly, many functional languages require funcitons to be __pure__.
# A function is pure if it satisfies two properites:

# - The output only depends on the inputs, i.e. if you call it againg with the same inputs, you get the same output.
#   This excludes functions like `run()`, `read.csv()`, or `Sys.time()` that can return different values.

# - The fucntion has no side-effects, like changeing the value of a gobal variable, writing to disk, or displaying to the screen.
#   This excludes functions like `print()`, `write.csv()` and `<-`.

# Pure functions are much easier to reason about, but obviously have signigicant sownsides: imagine doing a data analysis where you couldn't generate random numers or read files from disk.

# Strictly speaking, R isn't a functionaal programming language because it doesn't require that you write pure functions.
# However, you can certianly adopt a functional style in parts fo your code: you don't have to write pure functions, but you often should.
# In my experience, partitioning code into functions that are wither extremely pure or extremely impure tends to lead to code that is easier to understand and extends to new situations.

# Functional style

# It's hard to describe exactly what a functional style is, but generally I think it means decomposing a big problem into smaller pieces, 
# then solving each peice with a function or combination of functions.
# When using a functional style, you strive to decompose componenets of the problem into isolated functions that opeate independently.
# Each function taken by itself is simple and staightforward to understand;
# complexity is handled by composing functions in vairous ways.

# The floowing three chapters discuss the three key functional techniques that help you to decompose problems into smaller pieces:

# - Chapter 9 shows you how to replace many for loops with __functoinals__ which are functions(like `lapply()`) that take another function as an argument.
#   Funcitonala allow you to take a function that solves the problem for a single input and generalise it to handle any numbers of inputs.
#   Functionals are by far and away the most important technique and you'll use them all the time in data anlysis.

# - Chpater 10 introduces __function factories__: functions that create function.
#   Function factories are less commonly used than functionals, but can allow you to elegantly partition work between different pares of your code.

# - Chapter 11 show yo how to create __function operators__: functions that take functions as input and produce functions as output.
#   They are like adverbs, because they typically modify the operation of a function.

# Collectively, these types of funtion are called __higher-order functions__ and they fill out a two-by-two table:

#      Out | Vector     | Function
#  In      |            |          
# ---------|------------|-----------
# Vector   | Regular    | Function 
#          | function   | factory 
# ---------|------------|-----------
# Function | Functional | Function
#          |            | operator
#          |            |

# 9 Functionals

# 9.1 Intrduction

# To become significantly more reliable, code must become more transparent.
# In particular, nested conditions and loops must be viewed with great suspicion.
# Complicated control flows confuse programmers. Messy code often hedes bugs.
# - Bjarne Stroustrup

# A __functional__ is a fucntion that take a function as an input and returns a vector as output.
# Here's a simple functional: it calls the function provded as input with 1000 random uniform numbers.
randomise <- function(f) f(runif(1e3))
randomise(mean)
#> [1] 0.5022935
randomise(mean)
#> [1] 0.4968236
randomise(sum)
#> [1] 495.9585

# The chances are that you've already used a functional.
# You might have used for-loop replacements like base R's `lapply()`, `apply()`, and `tapply()`;
# or purrr's `map()`; or maybe you've used a mathematical functional like `integrate()` or `optim()`.

# A common use of functionals is as an alternative to for loops.
# For loops have a bad rap in R because many people believe they are slow,
# but the downside of for loop is that they're very flexible: 
# a loop conveys that you're iterating, but not what should be done with the results.
# Just as it's better to use `while` than `repeat`, and it's better to use `for` than `while` (Seciton 5.3.2),
# it's better to use a functional than `for`.
# Each functional is tailored for a specific task, so when you recognise the functional you immediately know why it's being used.

# If you're an experienced for loop user, switching to functionals is typically a pattern matching exercise.
# You look at the for loop and find a functional tha tmatches the basic form.
# If one doesn' exist, don't try and torture an existing functional to fit the form you need.
# Instead, just leave it as a for loop! (Or once you've repeated the same loop two or more tiems,
# maybe think about writing your own functional).

# Outline 

# - Section 9.2 introduces your first functional: `purrr::map()`.

# - Section 9.3 demonstrates how you can combine mutiple simple functionals 
#   to solve a more complex problem and discusses how purrr style differs from other approaches.

# - Section 9.4 teaches you about 18 (!!) important variants of `purrr::map()`.
#   Fortunately, their orthogonal design makes them easy to learn, remember, and master.

# - Section 9.5 introduces a new style of functional: `purrr::reduce()`.
#   `recude()` systematically reduce a vector to a single result by applying a function the takes two inputs.

# - Setcion 9.6 teaches you about predicates: functions that return a single `TRUE` or `FALSE`, 
#   and the family of functionals that use then to solve common problems.

# - Sction 9.7 reviews some functionals in base R that are not memvers of the map, reduce, or predicated families.

# Prerequisites

# This chapter will focus on functionals provied by the `purrr package` (Henry and Wickham 2018a).
# These functions have a consistent interface that makes it easier to understand the key ideas than their base equivalents, 
# which have grown organically over many years.
# I'll compare and contrast base R functiona as we go,
# and then wrap up the chapter with a discussion of base functionals that don't have purrr equivalents.

library(purrr)

# 9.2 My first functional: map()

# The most fundamental functional is `purrr::map()`.
# It takes a vector and a function, calls the function once for each element of the vector,
# and returns the results in a list.
# In other words, `map(1:3, f)` is equivalent to `list(f(1), f(2), f(3))`.
triple <- function(x) x * 3
map(1:3, triple)
#> [[1]]
#> [1] 3
#> 
#> [[2]]
#> [1] 6
#> 
#> [[3]]
#> [1] 9

# or, graphically:
# 
#         __             |---------|
#        |__|            |    __   |
#        |__|            | f(|__|) |
#   map( |__|, f)   ->   |---------|
#        |__|            |    __   |
#                        | f(|__|) |
#                        |---------|
#                        |    __   |
#                        | f(|__|) |
#                        |---------|
#                        |    __   |
#                        | f(|__|) |
#                        |---------|
# 

# You might wonder why this function is called `map()`.
# What does it have to do with depicting physical features of land or sea?
# In fact, the meaning comes form mahtematics where map refers to "an operation that
# associates each element of given set with one or more elements of a second set".
# This makes sense here because `map()` defines a mapping from one vector to anther.
# ("Map" also has the nice property of beign short, which is useful for such a fundamental building block.)

# The implementation of `map()` is quite simple.
# We allocate a list the same length as the imput, and then fill in the list with a for loop.
# The hear of the implementation is only a handful of line of code:
simple_map <- function(x, f, ...) {
  out <- vector("list", length(x))
  for (i in seq_along(x)) {
    out[[i]] <- f(x[[i]], ...)
  }
  out
}

# The real `purrr::map()` function has a few differences: it is written in C to eke out every last iota of performance,
# preserves names, and supports a few shortcuts that you'll learn about in Section 9.2.2.

########## In base R ###########
# The base equivalent to `map()` is `lapply()`.
# The only difference is that `lapply()` does not support the helpers that you'll learn about below,
# so if you're only using `map()` from purrr, you can skip the additional dependency and use `lapply()` directly.
################################

# 9.2.1 Producting atomic vectors

# `map()` returns a list, which makes it the most general of the map family because you cna put anything in a list.
# But it is inconvenient to return a list when a simpler data structure would do, 
# so there are four more specific variants: `map_lgl()`, `map_int()`, `map_dbl()`, and `map_chr()`.

# map_chr() always returns a character vector
map_chr(mtcars, typeof)
#> mpg      cyl     disp       hp     drat       wt     qsec       vs       am     gear 
#> "double" "double" "double" "double" "double" "double" "double" "double" "double" "double" 
#> carb 
#> "double" 

# map_lgl() always returns a logical vector
map_lgl(mtcars, is.double)
#> mpg  cyl disp   hp drat   wt qsec   vs   am gear carb 
#> TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE 

# map_int() always returns a integer vector
n_unique <- function(x) length(unique(x))
map_int(mtcars, n_unique)
#> mpg  cyl disp   hp drat   wt qsec   vs   am gear carb 
#> 25    3   27   22   22   29   30    2    2    3    6

# map_dbl() always returns a double vector
map_dbl(mtcars, mean)
#> mpg        cyl       disp         hp       drat         wt       qsec         vs 
#> 20.090625   6.187500 230.721875 146.687500   3.596563   3.217250  17.848750   0.437500 
#> am       gear       carb 
#> 0.406250   3.687500   2.812500

# purrr uses the convention that suffixes, like `_dbl()`, refer to the output.
# All `map_*()` functions can take any type of vactor as input.
# These examples rely on two facts: `mtcars` is a data frame, and data frames are lists containing vectors of the same length.
# This is more obvious if we draw a data frame with the same orientation as vector:

# All map functions always return an output vector the same length as the input, which implies that each call to `.f` must return a single value.
# If it does not, you'll get an error:
pair <- function(x) c(x, x)
map_dbl(1:2, pair)
#> Error: Result 1 must be a single double, not an integer vector of length 2
#> Call `rlang::last_error()` to see a backtrace

# This is similar to the error you'll get if `.f` returns the wrong type of the result:
map_dbl(1:2, as.character)
#> Error: Can't coerce element 1 from a character to a double

# In either case, it's often useful to switch back to `map()`, because `map()` can accept any type of output.
# That allows you to see the problematic output, and figure out waht to do with it.
map(1:2, pair)
#> [[1]]
#> [1] 1 1
#> 
#> [[2]]
#> [1] 2 2

map(1:2, as.character)
#> [[1]]
#> [1] "1"
#> 
#> [[2]]
#> [1] "2"

########### In base R #############
# BAse R has two apply functions that can return atomic vectors: `sapply()` and `vapply()`.
# I recommend that you avoid `sapply()` because it tries to simplify the result, so it can return a list, a vector, or a matrix.
# This makes it difficult to program with, and it should be avoided in non-interactive settings.
# `vapply()` is safer because it allows you to provide a template, `FUN.VALUE`, that describes the output shape.
# If you don't want to use purrr, I recommend you always use `vallply()` in your functions, not `sapply()`.
# The primary downside of `vapply()` is its verbosity: for example, the wquivalent to `map_dbl(x, mean, na.rm = TRUE)` is `vapply(x, mean, na.rm = TRUE, FUN.VALUE = double(1))`
###################################

# 9.2.2 Anonymous functions and shorcuts

# Instead of using `map()` with an existing function, you can create an inline anonymous function(as mentioned in Section 6.2.3):
map_dbl(mtcars, function(x) length(unique(x)))
#> mpg  cyl disp   hp drat   wt qsec   vs   am gear carb 
#> 25    3   27   22   22   29   30    2    2    3    6 

# Anonymous functions are very useful, but th syntax is verbose.
# So purrr supports a special shortcut:
map_dbl(mtcars, ~ length(unique(.x)))
#> mpg  cyl disp   hp drat   wt qsec   vs   am gear carb 
#> 25    3   27   22   22   29   30    2    2    3    6 

# This works because all purrr functions translate formulas, created by `~` (pronounced "twiddle"), into functions.
# You can see waht's happening behind the secnes by calling `as_mapper()`:
as_mapper(~ length(unique(.x)))
#> <lambda>
#> function (..., .x = ..1, .y = ..2, . = ..1) 
#> length(unique(.x))
#> attr(,"class")
#> [1] "rlang_lambda_function" "function" 

# The functions arguments look quirky but allow you to refer to `.` for one argument functions, `.x` and `.y`
# for two argument functions, and `..1`, `..2`, `..3`, etc, for functions with an arbitrary unmber of arguments.
# `.` remains for backward compatibility but I don't recommend using it because it's easily confused with the `.` used by magrittr's pipe.

# This shortcut is particularly useful for generating random data.
x <- map(1:3, ~ runif(2))
str(x)
#> List of 3
#>  $ : num [1:2] 0.0808 0.8343
#>  $ : num [1:2] 0.601 0.157
#>  $ : num [1:2] 0.0074 0.4664

# Reserve this syntax for short and simple functions.
# A good rule of thumb is that if your function spans line or uses `{}`, it's time to give it a name.

# The map functions also have shortcuts for extracting elements from a vector, powered by `purrr::pluck()`.
# You can use a character vector to select elements by name, an integer vector to select by position, or a list to select by both name and positoin.
# These are very useful for working with deeply nested lists, which often arise when working with JSON.
x <- list(
  list(-1, x = 1, y = c(2), z = "a"),
  list(-2, x = 4, y = c(5, 6), z = "b"),
  list(-3, x = 8, y = c(9, 10, 11))
)

# Select by name
map_dbl(x, "x")
#> [1] 1 4 8

# Or by position
map_dbl(x, 1)
#> [1] -1 -2 -3

# Or by both
map_dbl(x, list("y", 1))
#> [1] 2 5 9

# You'll get an error if a component doesn't exist:
map_chr(x, "z")
#> Error: Result 3 must be a single string, not NULL of length 0
#> Call `rlang::last_error()` to see a backtrace

# Unless you supply a .default value
map_chr(x, "z", .default = NA)
#> [1] "a" "b" NA 

########### In base R #############
# In base R functoins, like `lapply()`, you can provide the name of the function as a string.
# This isn't tremendously useful as `lapply(x, "f")` is almost alawys equivalent to `lapply(x, f)` and is more typing.
###################################

# 9.2.3 Passing arguments with `...`

# It's often convenient to pass along additional arguments to the function that you're calling.
# For exmple, you might want to pass `na.rm = TRUE` along to `mean()`.
# One way to do that is with an anonymous function:
x <- list(1:5, c(1:10, NA))
map_dbl(x, ~ mean(.x, na.rm = TRUE))
#> [1] 3.0 5.5

# But because the map functions pass `...` along, there's a simpler form available:
map_dbl(x, mean, na.rm = TRUE)
#> [1] 3.0 5.5

# This is easiest to understand with a picture: 
# any arguments that come after `f` in the call to `map()` are inserted after the data in individual calls to `f()`:

# It's important to note that these arguments are not decomposed; or said another way, `map()` is only vectorised over it's first argument.
# If an argument after `f` is a vector, it will be passed along as is:
# (You'll learn about map variants that are vectorised over multiple arguments in Sectoins 9.4.2 and 9.4.5.)

# Note there's a subtle difference between placing extra arguments inside an anonymous function compared with passing them to `map()`.
# Putting them in an anonymous function means that they will be evaluated every time `f()` is executed,
# not just once when you call `map()`. This is easiest to see if we make the additional argument random:
plus <- function(x, y) x + y

x <- c(0, 0, 0, 0)
map_dbl(x, plus, runif(1))
#> [1] 0.493637 0.493637 0.493637 0.493637
map_dbl(x, ~ plus(.x, runif(1)))
#> [1] 0.77930863 0.20417834 0.71339728 0.06521611

# 9.2.4 Argumrnt names

# In the diagrams, I've omitted argument names to focus on overall sturcture.
# But I recommend writing out the full names in your code, as it makes it easier to read.
# `map(x, mean, 0.1)` is perfectly valid code, but will call `mean(x[[1]], 0.1)` 
# so it relies on the reader remembering that the second argument to `mean()` is `trim`.
# To avoid unnecessary burden on the brain of the reader, be kink and write `map(x, mean, trim = 0.1)`.

# This is the reason why the arguments to `map()` are a little odd: instead of being `x` and `f`, they aer `.x` adn `.f`.
# It's easiest to see the problem that leads to these names using `simple_map()` defined above.
# `simple_map()` has arguments `x` and `f` so you'll have problems whenever the function you are calling has arguments `x` or `f`:
bootstrap_summary <- function(x, f) {
  f(sample(x, replace = TRUE))
}

simple_map(mtcars, bootstrap_summary, f = mean)
#>  Error in mean.default(x[[i]], ...) : 'trim' must be numeric of length one 

# The error is a little bewildering until you remember that the call to `simple_map()` is equivalent to `simple_map(x = mtcars, f = mean, bootstrap_summary)` 
# because named matching beats positional matching.

# purrr functions reduce the likehood of sucha clash by using `.f` and `.x` instead of the more common `f` and `x`.
# Of course this technique isn't perfect (because the function you are calling might still use `.f`, and `.x`),
# but it avoids 99% of issues. The remaining 1% of the time, use an anonymous function.

########## In base R ###########
# Base functions taht pass along `...` use a variety of naming conventions to prevent undesired argument matching:

# - The apply family mostly uses capital letters (e.g. `X` and `FUN`.)

# - `trasform()` uses the more exotic prefix `_`: this makes the name non-syntacitc so ti must always be surrounded in ```,
#    as described in Seciton 2.2.1. This makes undersired matches extremely unlikely.

# - Other fucntionals like `uniroot()` and `optim()` make no effort to avoid clashes but they tend to be used with specially created functions so calshes are less likely.
################################

# 9.2.5 Varing another argument

# So far the first argument to `map()` has always become the first arugment to the function.
# But waht happens if the first argument should be constant, and you want ot vary a different argument? 
# How do you get the result in this picture?

# It turns out that there's no way to do it directly, but there are tow tricks you can use instead.
# To illustrate them, imagine I have a vector that contains a few unusual values, and I want to explore the effect of different amounts of trimming when computing the mean.
# In this case, the first argument to `mean()` will be constant, and I want to vary the second argument, `trim`.
trims = c(0, 0.1, 0.2, 0.5)
x <- rcauchy(1000)

# - The simplest technique is to use an anonymous function to rearrange the argument order:
map_dbl(trims, ~ mean(x, trim = .x))
#> [1] -2.57419427 -0.07924700 -0.07265856 -0.06132888

# This is still a little confusing because I'm using both `x` and `.x`.
# You can make it a little clearer by abandoning the helper.
map_dbl(trims, function(trim) {mean(x, trim = trim)})
#> [1] -2.57419427 -0.07924700 -0.07265856 -0.06132888

# - Sometimes, if you want to be (too) clever, you can take advantage of R's flexible argument matching rules(as described in Section 6.8.2).
#   For exmaple, in this example you can rewrite `mean(x, trim = 0.1)` as `mean(0.1, x = x)`, 
#   so you could write the call to `map_dbl()` as:
map_dbl(trims, mean, x = x)
#> [1] -2.57419427 -0.07924700 -0.07265856 -0.06132888

#   I don't recommend this technique as it relies on the reader's familiarty with both the argumetn order to `.f`, and R's argument matching rules.

# You'll see one more alternative in Section 9.4.5.

# 9.2.6 Exercses 

# 1. Use `as_mapper()` to explore how purrr generates anonymous functions for the integer, character, and list helpers.
#    What helper allows you to extract attributes?
#    Read the documentation to find out.

# `map()` offers multple ways (functions, formulas and extrector functions) to speciyf the function argument(`.f`).
# Initially, the various inputs have to be transformed into a valid fuctnion, which is then applied.
# The creation of this valid function is the job of `as_mapper()` and it is called every time `map()` is used.

# Given character, numeric or list input `as_mapper()` will create an extractor function.
# Characters select by name, while numeric input selects by positions and a list allows a mix of these two approaches.
# This extractor interface can be very useful, when working with nested data.

# The extrector function is implemented as a call to `purrr::pluck()`, which accepts a list of accessors 
# (accessors "access" some part of your data object).
as_mapper(c(1, 2))
#> function (x, ...) 
#> pluck(x, 1, 2, .default = NULL)
#> <environment: 0x10bd448f8>

as_mapper(c("a", "b"))
#> function (x, ...) 
#> pluck(x, "a", "b", .default = NULL)
#> <environment: 0x11027ae98>

as_mapper(list(1, "b"))
#> function (x, ...) 
#> pluck(x, 1, "b", .default = NULL)
#> <environment: 0x10b542ca8>

# Besides mixing positions and names, it is also possible to pass along an accessor function.
# This is basically an anonymous function, 
# that gets information about some aspect of the input data.
# You are ferr to define your own accessor functions.

# If you need to access certain attributes, the helper `attr_getter(y)` 
# is already perdefined and will create teh appropriate accessor function for you.

# define custom acdessor funciton
get_class <- function(x) attr(x, "class")
pluck(mtcars, get_class)
#> [1] "data.frame"

# use attr_getter() as a helper
pluck(mtcars, attr_getter("class"))
#> [1] "data.frame"

# 2. `map(1:3, ~ runif(2))` is useful pattern for genreating random numbers, but `map(1:3, runif(2))` is not.
#    Why not? Can you explain why it returns the result that it does?

# The first pattern creates multiple random numbers, because `~ runif(2)` successfully uses the formula interface.
# Internally `map()` applies `as_mapper()` to this formula, which converts `~ runif(2)` into an anonymous funtion.
# Agterwards `runif(2)` is applied three times (one time during each iteration),
# leading to three different pairs of rando numbers.

# In the second pattern `runif(2)` is evaluated once, then results are passed to `map()`.
# Consequently `as_mapper()` creates an extractor function based on the return values from `runif(2)`, (via `pluck()`).
# This lead to three `NULL`s (pluck())'s `.default` return), because no values corresponding to the index can be found.
map(1:3, ~ runif(2))
#> [[1]]
#> [1] 0.1438034 0.2651872
#> 
#> [[2]]
#> [1] 0.1484630 0.4142487
#> 
#> [[3]]
#> [1] 0.1089497 0.2470779
as_mapper(~ runif(2))
#> <lambda>
#> function (..., .x = ..1, .y = ..2, . = ..1) 
#> runif(2)
#> attr(,"class")
#> [1] "rlang_lambda_function" "function" 

map(1:3, runif(2))
#> [[1]]
#> NULL
#> 
#> [[2]]
#> NULL
#> 
#> [[3]]
#> NULL
as_mapper(runif(2))
#> function (x, ...) 
#> pluck(x, 0.732970522018149, 0.727905224077404, .default = NULL)
#> <environment: 0x10f345d18>

# 3. Use the appropiate `map()` function to:
#    a. Compute the standard deviation o fevery column in a numeric data frame.
#    b. Compute the standard deviation of every numeric cloumn in a mixed data frame.
#       (Hint: you'll need to do it in two steps.)
#    c. Compute the numer of levels for every facor in a data frame.

# To solve this exercise we take advantage of calling the type stable variants of `map()`, 
# which give us more condise output, and use `map_lgl()` to select the columns of the data frame (later you'll learn about `keep()`), 
# which simplifies this pattern a little).
map_dbl(mtcars, sd)
#> mpg         cyl        disp          hp        drat          wt        qsec          vs 
#> 6.0269481   1.7859216 123.9386938  68.5628685   0.5346787   0.9784574   1.7869432   0.5040161 
#> am        gear        carb 
#> 0.4989909   0.7378041   1.6152000 

iris_numeric <- map_lgl(iris, is.numeric)
map_dbl(iris[iris_numeric], sd)
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#> 0.8280661    0.4358663    1.7652982    0.7622377 

iris_factor <- map_lgl(iris, is.factor)
map_int(iris[iris_factor], ~ length(levels(.x)))
#> Species 
#>       3

# 4. The floowing code simulates the performance fo a t-test for non-normal data.
#    Extract the p-value from each test, then visualise.
trails <- map(1:100, ~ t.test(rpois(10, 10), rpois(7, 10)))

# There are many ways to visulise this data, but since it's relatively small, 
# a dot plot allows us to see coth the individual values and the overall distribution.
library(ggplot2)
library(tibble)

trails_tbl <- tibble(p_value = map_dbl(trails, "p.value"))
ggplot(trails_tbl, aes(x = p_value, fill = p_value < 0.05)) + 
  geom_histogram(binwidth = .025) + 
  ggtitle("Distribution of p-value for random poisson data.")

# 5. The following code uses a map nested inside another map to apply a function to every element of a nested list.
#    Why does it fail, and what do you need to do to make it work?
x <- list(
  list(1, c(3, 9)),
  list(c(3, 6), 7, c(4, 7, 6))
)

triple <- function(x) x * 3
map(x, map, .f = triple)
#> Error in .f(.x[[i]], ...) : unused argument (map)

# This fucntion call fails, because `triple()` is specitfied as the `.f` argument and consequently belongs to the output `map()`.
# The unnamed argument `map` is treated as an argument of `triple()`, which causes the error.

# There are number of ways we could resolve the problem.
# I don't think there's much to choose between them for this simple example, 
# but it's good to know your options for more compliated cases.
map(x, ~ map(.x, .f = triple))
map(x, map, triple)

# 6. Use `map()` to fit linear models to the `mtcars` dataset using the formulas stored in this list:
formulas <- list(
  mpg ~ disp, 
  mpg ~ I(1 / disp),
  mpg ~ disp + wt,
  mpg ~ I(1 / disp) + wt
)

# The data (mtcars) is constant for all these models and we iterate over the `formulas` proveded.
# Because the formula is the first argument of a `lm()`-call,
# it doesn't need to be specified explicitly.
map(formulas, ~ lm(.x, data = mtcars))
#> [[1]]
#> 
#> Call:
#>   lm(formula = .x, data = mtcars)
#> 
#> Coefficients:
#>   (Intercept)         disp  
#> 29.59985     -0.04122  
#> 
#> 
#> [[2]]
#> 
#> Call:
#>   lm(formula = .x, data = mtcars)
#> 
#> Coefficients:
#>   (Intercept)    I(1/disp)  
#> 10.75      1557.67  
#> 
#> 
#> [[3]]
#> 
#> Call:
#>   lm(formula = .x, data = mtcars)
#> 
#> Coefficients:
#>   (Intercept)         disp           wt  
#> 34.96055     -0.01772     -3.35083  
#> 
#> 
#> [[4]]
#> 
#> Call:
#>   lm(formula = .x, data = mtcars)
#> 
#> Coefficients:
#>   (Intercept)    I(1/disp)           wt  
#> 19.024     1142.560       -1.798  

# 7. Fit the model `mpg ~ disp` to each of the bootstrap replicates of `mtcars` in the list below, 
#    then extract the R^2 of the model fit (Hint: you can compute the R^2 with `summary()`.)
bootstrap <- function(df) {
  df[sample(nrow(df), replace = TRUE), , drop = FALSE]
}
bootstraps <- map(1:10, ~ bootstrap(mtcars))

# To accomplish this task, we take advantage of the "list in, list out" - functionality of `map()`.
# This allow us to chain multiple transformation together.
# We start by fitting the models. We then calaulate the summaries and extract the R^2 values.
# For the last call we use `map_dbl`, which provides convenient output.
bootstraps %>% 
  map(~ lm(mpg ~ disp, data = .x)) %>% 
  map(summary) %>% 
  map_dbl("r.squared")
#> [1] 0.8155624 0.7164965 0.7185595 0.5714590 0.7693603 0.8461478 0.7111400 0.7296471 0.6765396
#> [10] 0.7138391

# 9.3 Purrr style 

# Before we go on to explore more map variants, let's take a quick look at how you tend to use multiple purrr functions to slove a moderately realistic problem:
# fitting a model to each subgroup and extracting a coeffcient of the model.
# For this toy example, I'm going to break the `mtcars` data set down into groups defined by the number of cylinders, using the base `split` function:
by_cyl <- split(mtcars, mtcars$cyl)

# This creates a list of three data frames: the cars with 4, 6, 8 cylinders respectively.

# Now imagine we want to fit a linear model, then extract the second coefficient (i.e. the slope).
# The following code shows how you might do that with purrr:
by_cyl %>% 
  map(~ lm(mpg ~ wt, data = .x)) %>% 
  map(coef) %>% 
  map_dbl(2)
#>         4         6         8 
#> -5.647025 -2.780106 -2.192438 
# (If you haven't seen ` %>% `, the pipe, before, it's described in Seciton 6.3.)

# I think this code is easy to read because each line encapsulates a single step,
# you can easily distinguich the function from what it does, 
# and the purrr helpers allow us to very condisely describe what to do in each step.

# How would you attack this problem with base R? 
# You can certainly could replace each purrr function with the equivalent base function:
by_cyl %>% 
  lapply(function(data) lm(mpg ~ wt, data = data)) %>% 
  lapply(coef) %>% 
  vapply(function(x) x[[2]], double(1))
#>         4         6         8 
#> -5.647025 -2.780106 -2.192438 

# But this isn't really base R since we're using the pipe.
# To tackle purely in base I think you'd use an intermediate variable, and do more in each step:
models <- lapply(by_cyl, function(data) lm(mpg ~ wt, data = data))
vapply(models, function(x) coef(x)[[2]], double(1))

# Or, of course, you could use a for loop:
intercepts <- double(length(by_cyl))
for (i in seq_along(by_cyl)) {
  model <- lm(mpg ~ wt, data = by_cyl[[i]])
  intercepts[[i]] <- coef(model)[[2]]
}
intercepts
#> -5.647025 -2.780106 -2.192438 

# It's interesting to note that as you move from purrr to base apply functions to for loops you tend to do more and more in each teration.
# In purrr we iterate 3 times (map(), map(), map_dbl()), with apply functions we iterate twice(lapply(), vapply()), 
# and with a for loop we iterate once.
# I prefer more, but simpler, steps because I think ti makes the code easier to understand and later modify.

# 9.4 Map variants

# There are 23 primary variants of `map()`.
# So far, you've learned about five (map(), map_lgl(), map_int(), map_dbl() and map_chr()).
# That means that you've got 18 (!!) more to learn.
# That sounds like a lot, but fortunately the design of purrr means that you only need to learn five new ideas:

# - Output same type as input with `modify()`.

# - Iterate over two inputs with `map2()`.

# - Iterate with an index using `imap()`.

# - Return nothing with `walk()`.

# - terate over any number of inputs with `pmap()`.

# The map family of functions has orthogonal input and outputs, 
# meaning that we can organise all the family into a matrix, with inputs in thw rows and outputs in the columns.
# Once you've mastered the idea in a row, you can combine it with any column;
# once you've mastered the idea in a column, you can combine it with any row.
# That relattionship is summarised in the following table:

# ---------------------|--------|-----------------|-----------|---------
#                      | List   | Atomic          | Same type | Nothing 
# ---------------------|--------|-----------------|-----------|---------
# One argument         | map()  | map_lgl(),  ... | modify()  | walk()
# Two arguments        | map2() | map_lgl2(), ... | modify2() | walk2()
# One argument + index | imap() | imap_lgl(), ... | imodify() | iwalk()
# N arguments          | pamp() | pmap_lgl(), ... | -         | pwalk() 
# ---------------------|--------|-----------------|-----------|---------
# 

# 9.4.1 Same type of output as input: modify()

# Imagine you wanted to double every column in a data frame.
# You might first try using `map()`, but `map()` always returns a list:
df <- data.frame(
  x = 1:3,
  y = 6:4
)

map(df, ~ .x * 2)
#> $x
#> [1] 2 4 6
#> 
#> $y
#> [1] 12 10  8

# If you wnat to keep the output as a data frame, you can use `modify()`, which always returns the same type of output as the input:
modify(df, ~ .x * 2)
#>   x  y
#> 1 2 12
#> 2 4 10
#> 3 6  8

# Desplite the name, `modify()` doesnt' modify in place, it returns a modified copy, 
# so if you wnated to permanently modify `df`, you'd need to assign it:
df <- modify(df, ~ .x * 2)

# as usual, the basic implementation of `modify()` is simple and in fact it's even simpler than `map()` because we don't need to create a new output vector;
# we can ust progressively replace the input. (The real code is a little complex to handle edge cases more gracefully.)
simple_modify <- function(x, f, ...) {
  for (i in seq_along(x)) {
    x[[i]] <- f(x[[i]], ...)
  }
  x
}

# In Seciton 9.6.2 you'l learn about a vary useful variant of `modify()`, called `modify_if()`.
# This allows you to (e.g.) only double numeric cloumns of a data frame with `midify_if(df, is.numeric, ~ .x * 2)`.

# 9.4.2 Two inputs: `map2()` and friends

# `map()` is vectorised over a single argument, `.x`.
# This means it only varies `.x` when calling `.f`, and all other arguments are passed along unchanged,
# thus making it poorly suited for some problems.
# For example, how would you find a weighted mean when you have a list of observations and a list of weights?
# Imagine we have the following data:
xs <- map(1:8, ~ runif(10))
xs[[1]][[1]] <- NA
ws <- map(1:8, ~ rpois(10, 5) + 1)

# You can use `map_dbl()` to compute the unweighted means:
map_dbl(xs, mean)
#> [1]        NA 0.4982678 0.4211191 0.5740406 0.4863683 0.5076534 0.6172335 0.5112014

# But passing `ws` as an additional argument doesn't work because arguments after `.f` are not transformed:
map_dbl(xs, weighted.mean, w = ws)
#> Error in weighted.mean.default(.x[[i]], ...) : 
#>   'x' and 'w' must have the same length

# We need a new tool: a `map2()`, which is vectorised over two arguments.
# This means both `.x` and `.y` are varied in each call to `.f`:
map2_dbl(xs, ws, weighted.mean)
#> [1]        NA 0.5206619 0.4111444 0.5674256 0.5025883 0.5180697 0.6166951 0.5030616

# The arguments to `map2()` are slightly different to the arguments to `map()` as two vectors come before the function, rather than one.
# Additional arguments still go afterwards:

# The basic implementation of `map2()` is simple and quite similar to that of `map()`.
# Instead of iterating over one vector, we iterate over two in parallel:
simple_map2 <- function(x, y, f, ...) {
  out <- vector("list", length(xs))
  for (i in seq_along(x)) {
    out[[i]] <- f(x[[i]], y[[i]], ...)
  }
  out
}

# One of the big differents between `map2()` and the simple function above is that `map2()` recycles its inputs to make sure that they're the same length:

# In other words, `map2(x, y, f)` will automatically behave like `map(x, f, y)` when needed.
# This is helpful when writting functions; in secipts you'd generally just use the simpler form directly.

########### In base R ############
# The closest base equivalent to `map2()` is `Map()`, which is discussed in Seciton 9.4.5.
##################################

# 9.4.3 No outputs: `walk()` and friends

# Most functions are called for the value that they return, so it makes sense to capture and strore teh value wth a `map()` function.
# But some functions are called primarily for their side-eddects (e.g. `cat()`, `write.csv()`, or `ggsave()`) adn it doesn't make sense to capture their results.
# Take this simple example that display a welcome message using `cat()`.
# `cat()` returns `NULL`, so while `map()` works (in the sense that it generates the desired welcomes),
# it also returns `list(NULL, NULL)`.
welcome <- function(x) {
  cat("Welcome ", x, "!\n", sep = "")
}
names <- c("Hadley", "Jenny")

# As well as generate the welcomes, it also shows the return value of cat()
map(names, welcome)
#> Welcome Hadley!
#> Welcome Jenny!
#> [[1]]
#> NULL
#> 
#> [[2]]
#> NULL

# You could avoid this problem by assigning the results of `map()` to a variable that yu never use,
# but that would muddy the intent of the code.
# Instead, purrr provides the walk family of functions that ignore the return values of the `.f` and instead return `.x` invisibly.
walk(names, welcome)
#> Welcome Hadley!
#> Welcome Jenny!

# My visul depicition of walk attempts to capture the important difference from `map()`: 
# the outputs are ephemeral, and the input is returned invisibly.

# One of the most useful `walk()` variants is `walk2()` because a very common side-effect is saving something to disk,
# and when saving something to disk you always have a pair of values: 
# the object and the path that you want to save it to.

# For example, imagine you have a list of data frames (which I've created here using `split()`),
# and you'd like to save each one to a separate CSV file.
# That's easy with `walk2()`:
temp <- tempfile()
dir.create(temp)

cyls <- split(mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(cyls, paths, write.csv)

dir(temp)
#> [1] "cyl-4.csv" "cyl-6.csv" "cyl-8.csv"

# Here the `walk2()` is equivalent to `write.csv(cyls[[1]], paths[[1]])`,
# `rite.csv(cyls[[2]], paths[[2]])`, `rite.csv(cyls[[3]], paths[[3]])`.

########## In base R ############
# There is no base equivalent to `walk()`; 
# either wrap the result of `lapply()` in `invisible()` or save it to a variable that is never used.
#################################

# 9.4.4 Iterating over values and indices

# There are three basic ways to loop over a vector with a for loop:

# - Loop over the elements: `for (x in xs)`

# - Loop over the numeric indices: `for (i in seq_along(xs))`

# - Loop over the names: `for (nm in names(xs))`

# The first form is analogous to the `map()` family.
# The second and third forms are equivalent to the `imap()` family 
# which allows you to iterate over the vlaue and the indices of a vector in parallel.

# `imap()` is like `map2()` in the sense that your `.f` gets called with two arguments,
# but here both are derived from the vector.
# `imap(x, f)` is equivalent to `map2(x, names(x), f)` if x has names, 
# and `map2(x, seq_along(x), f)` if it does not.

# `imap()` is often useful for constructing labels:
imap_chr(iris, ~ paste0("The first value of ", .y, " is ", .x[[1]]))
#>                             Sepal.Length                              Sepal.Width 
#> "The first value of Sepal.Length is 5.1"  "The first value of Sepal.Width is 3.5" 
#>                             Petal.Length                              Petal.Width 
#> "The first value of Petal.Length is 1.4"  "The first value of Petal.Width is 0.2" 
#>                                  Species 
#> "The first value of Species is setosa"

# If the vector is unnamed, the second argument will be the index:
x <- map(1:6, ~ sample(1000, 10))
imap_chr(x, ~ paste0("The highest value of ", .y, " is ", max(.x)))
#> [1] "The highest value of 1 is 977" "The highest value of 2 is 889"
#> [3] "The highest value of 3 is 952" "The highest value of 4 is 994"
#> [5] "The highest value of 5 is 706" "The highest value of 6 is 970"

# `imap()` is a useful helper if you want to work with the values in a vector along with their positions.

# 9.4.5 Any number of inputs: `pmap()` and friends

# Since we have `map()` and `map2()`, you might expect `map3()`, `map4()`, `map5()`, ... But where would you stop? 
# Instead of generalising `map2()` to an arbitrary number of arguments, purrr takes a slightly different tack with `pmap()`:
# you supply it a single list, which contains any number of arguments.
# In most cases, that will be a list of equal-length vectors, i.e. something very similar to a data frame.
# In diagrams, I'll emphasise that relationship by drawing the input similar to a data frame.

# There 's a simple equivalence between `map2()` and `pmap()`: `map2(x, y, f)` is the same as `pmap(list(x, y), f)`.
# The `pmap()` equivalent to the `map2_dbl(xs, ws, weighted.mean`) used above is:
pmap_dbl(list(xs, ws), weighted.mean)
#> [1]        NA 0.5206619 0.4111444 0.5674256 0.5025883 0.5180697 0.6166951 0.5030616

# As before, the verying arguments come before `.f` (although now they must be wrapped in a list),
# and the constnt arguments come afterwards.
pmap_dbl(list(xs, ws), weighted.mean, na.rm = TRUE)
#> [1] 0.3040503 0.5206619 0.4111444 0.5674256 0.5025883 0.5180697 0.6166951 0.5030616

# A big difference between `pmap()` and the other map functions is that `pmap()` gives you much finer control over argument matching because you can name the components of the list.
# Returning to our example from Section 9.2.5, where we wanted to vary the `trim` argument to `x`,
# we could instead use `pmap()`:
trims <- c(0, 0.1, 0.2, 0.5)
x <- rcauchy(1000)

pmap_dbl(list(trim = trims), mean, x = x)
#> 1]  0.35541238  0.01484187 -0.01243557 -0.06227540

# I think it's good practice to name the components of the list to make it very clear how the function will be called.

# It's often convenient to call `pmap()` with a data frame.
# A handy way to create that data frame is with `tibble::tribble()`, which allows you to describe a data frame row-by-row (rather than column-by-column, as usual):
# thinking about the parameters to a function as a data frame is very powerful pattern.
# The following example show how you might draw random uniform numbers with varying parameters:

params <- tibble::tribble(
  ~ n, ~ min, ~ max,
   1L,    0,      1,
   2L,   10,    100,
   3L,  100,   1000
)

pmap(params, runif)
#> [[1]]
#> [1] 0.02171639
#> 
#> [[2]]
#> [1] 51.14951 47.34315
#> 
#> [[3]]
#> [1] 297.7300 184.0697 307.7025

# Here, the column names are critical: I've carefully chosen to match them to the arguments to `runif()`, 
# so the `pmap(parms, runif)` is equivalent to `runif(n = 1L, min = 0, max = 1)`, `runif(x = 2L, min = 10, max = 100)`, `runif(x = 3L, min = 100, max = 1000)`.
# (If you have a data frame in hand, and the names don't match, use dplyr::rename() or similar.)

############ In base R #############
# There are two base equivalents to the `pmap()` family: `Map()` and `mapply()`.
# Both have significant drawbacks:

# - `Map()` vecitorises over all arguments so you cannot supply arguments that do not vary.

# - `mapply()` is the multidimensional version of `sapply()`; conceptually it takes the output of `Map()` and simplifies it if possible.
#    This gives it similar issues to `sapply()`. There is not multi-input equivalent of `vapply()`.
####################################

# 9.4.6 Exercises

# 1. Explain the results of `modify(mtcars, 1)`.

# `modify()` is based on `map()`, and in this case, the extractor interface will be used.
# It extracts the first element of each column in `mtcars`.
# `modify()` always returns the same structure as its input: in this case it forces the first row to be recycled 32 times.
# (Internally `modify()` uses `.x[] <- map(x., .f, ...) for assignment`.)

# 2. Rewrite the following code to use `iwalk()` instead of `walk2()`.
#    What are the advantages and disadvantages?
cyls <- split(mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(cyls, paths, write.csv)

# `iwalk()` allows us to use a single variable, storing the output path in the names.
cyls <- split(mtcars, mtcars$cyl)
names(cyls) <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
iwalk(cyls, ~ write.csv(.x, .y))

# We could do this in a single pipe by taking advantage of `set_names()`:
mtcars %>%
  split(.$cyl) %>% 
  set_names(file.path(temp, paste0("cyl-", names(.), ".csv"))) %>% 
  iwalk(~ write.csv(.x, .y))

# 3. Explain how the following code transforms a data frame using functions stored in a list.
trans <- list(
  disp = function(x) x * 0.0163871,
  am = function(x) factor(x, labels = c("auto", "manual"))
)

nm <- names(trans)
mtcars[nm] <- map2(trans, mtcars[nm], function(f, var) f(var))

#   Compare and contrast the `map2()` approach to this `map()` approach:
mtcars[vars] <- map(vars, ~ trans[[.x]](mtcars[[.x]]))

# In the first apporach the list of functions and the appropriately selected data frame columns are supplied to `map2()`.
# `map2()` creates an nonymous function`f(var)` which applies th eufncitons to the variables when `map2()` iterates over their (similar) index.
# On the left hand side the regarding elements fo `mtcars` are being replaced by their new transformations.

# The `map()` variant does basically the same. 
# However, it directly iterates over the names of the transformations.
# Therefore, the data frame columns are selected furing the iteration.

# Basides the iteration pattern, the approaches differ in the possibilities for appropriate argument nameing in the `.f` argument.
# Therefore, it is possible to choose appoopriate placehoders like `f` and `var`.
# This makes the anonymous function more expressive at the cost of making it longer.
# However, we think using the formular interfact here makes for rather crypitc code:
# `mtcars[vars] <- map2(trans, mtcars[vars], ~ .x(.y))`.

# In the `map()` approah we map over the variable names.
# It is therefore not possible to introduce placeholders for the function and variable names.
# The formula syntax together with the `.x` shortcut is pretty compact.
# The object names and the brackets indicate clearly the application of transformations to specific columns of `mtcars`.
# In this case the iteration over the variable names comes in handy, 
# as it highlights the importance of matching between `trans` and `mtcars` element names.
# Together with the replacement form on the left hand side, this lines is relatively easy to inspect.
# To summarise, in situations where `map()` and `map2()` provide solutions for an iteration problem,
# several points are to condider before deciding for one or the other approach.

# 4. What does `write.cas()` return? i.e. what happens if you use it with `map2()` instead of `walk2()`?

# `write.csv()` returns `NULL`.
# In the example above we iterated over a list of data frames and file names a named list of `NULL`s would be returned.
#    What are the advantages and disadvantages?
cyls <- split(mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
map2(cyls, paths, write.csv)

# 9.5 Reduce family

# After the map family, the next most important family of functions is the reduce family.
# This family is much smaller, with only two mian variants, and is used less commonly, 
# but it's a powerful idea, gives us the opportunity to discuss some useful algebra,
# and powers teh map-reduct framework frequently used for processing vary large datasets.

# 9.5.1 Basics

# `reduce()` takes a vector of length n and produces a length 1 by calling a function with a pair of values at a time:
# `reduce(1:4, f)` is equivalent to `f(f(f(1, 2), 3), 4)`.

# `reduce()` is a useful way to generalise a function that works with two inputs (a __binary__ function) to work with any number of inputs.
# Imagine you have a list of numeric vectors, and you want to find the values that occur in every element.
# First we generate some sample data:
l <- map(1:4, ~ sample(1:15, replace = TRUE))
str(l)
#> List of 4
#> $ : int [1:15] 14 9 10 2 15 2 15 6 12 4 ...
#> $ : int [1:15] 11 7 12 11 8 11 13 7 7 14 ...
#> $ : int [1:15] 3 7 12 8 14 7 4 8 6 5 ...
#> $ : int [1:15] 1 5 1 13 13 1 15 7 15 15 ...

# To solve this challenge we need to use `intersect()` repeatedly:
out <- l[[1]]
out <- intersect(out, l[[2]])
out <- intersect(out, l[[3]])
out <- intersect(out, l[[4]])
out
#> [1] 10 12  7

# `reduce()` automates this solution for us, so we can write:
reduce(l, intersect)
#> [1] 10 12  7

# We could apply the same idea if we wanted to list all the elements that appear in at least one entry.
# All we have to do is switch from `intersect()` to `union()`:
reduce(l, union)
#> 1] 14  9 10  2 15  6 12  4  7 11  8 13  1  3  5

# like the map family, you can also pass adiitional arguments. 
# `intersect()` and `union()` don't take extra argumensts so I can't demonstrate them here, 
# but the principle is straightforward and I drew you a picture.

# As usual, the essence of `reduce()` can be reduced to a simple wrapper around a for loop:
simple_reduce <- function(x, f) {
  out <- x[[1]]
  for (i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}

######### In base R #########
# The vase equivalent is `Reduce()`. Note that the argument order is different:
# the function comes first, dollowed by the vector, and there is no way to supply additonal arguments.
#############################

# 9.5.2 Accumulate

# The first `reduce()` ariant, `accumulate()`, is useful for understanding how reuce works, 
# because instead of returning just the final result, 
# it returns all the intermdiate results as well:
accumulate(l, intersect)
#> [[1]]
#> [1] 14  9 10  2 15  2 15  6 12  4 15  7 12 10  9
#> 
#> [[2]]
#> [1] 14 10 12  7
#> 
#> [[3]]
#> [1] 14 10 12  7
#> 
#> [[4]]
#> [1] 10 12  7

# Another useful way to understand reduce is to think about `sum()`: 
# `sum(x)` si equivalent to `x[[1]] + x[[2]] + x[[3]] + ...`, i.e. `reduce(x, `+`).`
# Then `accumulate(x, `+`)` is the cumulative sum:
x <- c(4, 3, 10)
reduce(x, `+`)
#> [1] 17

accumulate(x, `+`)
#> [1]  4  7 17

# 9.5.2 Output types 

# In the above example using `+`, what should `reduce()` return when `x` is short,
# i.e. length 1 or 0" Without additonal arguments, `reduce()` just returns the input when `x` is length 1:
reduce(1, `+`)
#> [1] 1

# This means that `reduce()` has no way to check that the inputs is valid:
reduce("a", `+`)
#> [1] "a"

# What if it's length 0? We get an error that suggests we need to use the `.init` argument:
reduce(integer(), `+`)
#> Error: `.x` is empty, and no `.init` supplied

# What should `.init` be here? To figure that out, we need to see what happens when `.init` is supplied:

# So if we call `reduce(1, `+`, init)` the result will be `1 + init`.
# Now we know that the result should be just 1, so that suggests that `.init` should be 0:
reduce(integer(), `+`, .init = 0)
#> [1] 0

# This also ensures that `reduce()` checks that length 1 inputs are valid for the function that you're calling:
reduce("a", `+`, .init = 0)
#> Error in .x + .y : non-numeric argument to binary operator

# If you want to get algebraic about it, 0, is called the __identity__ of the real numbers under the operation of addtion:
# if you add a 0 to any number, you get the same number back.
# R applies the same principle to determin what a summary functin with a zero length input should return:
sum(integer())   # x + 0 = x
#> [1] 0
prod(integer())  # x * 1 = x
#> [1] 2
min(integer())   # min(x, Inf) = x
# [1] Inf
# Warning message:
#   In min(integer()) : no non-missing arguments to min; returning Inf
max(integer())   # max(x, -Inf) = x
# [1] -Inf
# Warning message:
#   In max(integer()) : no non-missing arguments to max; returning -Inf

# If you're using `reduce()` in a function, you should always supply `.init`.
# Think carefully about what your function should return when you pass a vector of length 0 or 1,
# and make sure to test your implementation.

# 9.5.4 Multiple inputs

# Very occationally you need to pass two arguments to the functions that you're reducing.
# For example, you might have a list of data frames that you want to join together, and the variables you use to join will vary from element to elemnet.
# This is a very specialised scenario, so I don't want to spend much time on it, 
# but I do want you to know that `reduce2()` exists.

# The length of the second argument varies based on whether or not `.init` is supplied:
# if you have four elements of `x`, `f` will only be called three tiems.
# If you supply init, `f` will be called four times.

# 9.5.5 Map-reduce

# You might have heard of map-reduce, the idea that powers technolgy like Hadoop.
# Now you can see how simple and powerful the underlying idea is:
# map-reduce is a map combined with a reduce.
# The difference for large data is that the data is spread over muotiple computers.
# Each computer performs the map on the data that it has,
# then it sends the result to back to a coordinator which reduces teh individual results back to a single result.

# As a simple example, imagine computing the mean of a very large vector, so large that it has to be split over multiple computers.
# You could ask each computer to calculate the sum and the length, 
# and then return those to the coordinator which computes the overall mean by dividing the total sum by the total length.

# 9.6 Rredicate functions

# A __predicate__ is a function that returns a single `TRUE` or `FALSE`, like `is.character()`,
# `is.null()`, or `all()`, and we say a predicate __matches__ a vector if it retuns `TRUE`.

# 9.6.1 Basics

# A __predicate functional__ applies a predicate to each element of a vector.
# purrr provides six useful functions which come in three pairs:

# - `some(.x, .p)` returns `TRUE` if any element matches;
#   `every(.x, .p)` returns `TRUE` if all elements match.

#   These are similar to `any(map_lgl(.x, .p))` and `all(map_lgl(.x, .p))` but they terminate early:
#   `some()` returns `TRUE` when it sees the first `TRUE` and `every()` retuns `FALSE` when it sees the first `FALSE`.

# - `detect(.x, .p)` returns the value of the first match;
#   `detect_index(.x, .p)` returns the location of the first match.

# - `keep(.x, .p)` keeps all matching elements;
#   `discard(.x, .p)` drops all matching elements.

# The following example shows how you might use these functionals with a data frame:
df <- data.frame(x = 1:3, y = c("a", "b", "c"))
detect(df, is.factor)
#> [1] a b c
#> Levels: a b c
detect_index(df, is.factor)
#> [1] 2

str(keep(df, is.factor))
#> 'data.frame':	3 obs. of  1 variable:
#>  $ y: Factor w/ 3 levels "a","b","c": 1 2 3
str(discard(df, is.factor))
#> 'data.frame':	3 obs. of  1 variable:
#>  $ x: int  1 2 3

# 9.6.2 Map variants

# `map()` and `modify()` come in variants that also take predicate functions,
# transforming only the elements of `.x` where `.p` is `TRUE`.
df <- data.frame(
  num1 = c(0, 10, 20),
  num2 = c(5, 6, 7),
  chr1 = c("a", "b", "c"),
  stringsAsFactors = FALSE
)

str(map_if(df, is.numeric, mean))
#> List of 3
#>  $ num1: num 10
#>  $ num2: num 6
#>  $ chr1: chr [1:3] "a" "b" "c"
str(modify_if(df, is.numeric, mean))
#> 'data.frame':	3 obs. of  3 variables:
#>  $ num1: num  10 10 10
#>  $ num2: num  6 6 6
#>  $ chr1: chr  "a" "b" "c"
str(map(keep(df, is.numeric), mean))
#> List of 2
#>  $ num1: num 10
#>  $ num2: num 6

# 9.6.3 Exercises

# 1. Why isn't `is.na()` a predicate function?
#    What base R function is closest to being a predicate version of `is.na()`?
df <- data.frame(
  num1 = c(0, 10, 20),
  num2 = c(5, 6, 7),
  chr1 = c("a", "b", "c"),
  stringsAsFactors = FALSE
)

# `is.na()` is not a predicate function, because it returns a logical vector the same length as the input,
# not a single `TRUE` or `FALSE`.

# 2. `simple_reduce()` has a problem when `x` is length 0 or length 1.
#     Describe the source of the problem and how you might go about fixing it.
simple_reduce <- function(x, f) {
  out <- x[[1]]
  for (i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}

# The loop inside `simple_reduce()` always starts with the index 2, 
# and `seq()` can count both up and down:
seq(2, 0)
#> [1] 2 1 0
seq(2, 1)
#> [1] 2 1

# Therefore, subsetting length-0 and length-1 vectors via `[[` will lead to a subscript out of bounds error.
# To avoid this, we allow `simple_reduce()` to `return()` before the for-loop is started and include default argument for 0-length vectors.
simple_reduce <- function(x, f, .init) {
  if (is.data.frame(x)) return(x)
  if (length(x) == 0L) return(.init)
  if (length(x) == 1L) return(x[[1L]])
  
  out <- x[[1]]
  for (i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}

# Our new `simple_reduce()` now works as intended:
simple_reduce(integer(0), `+`)
#> Error in simple_reduce(integer(0), `+`) : 
#>   argument ".init" is missing, with no default
simple_reduce(integer(0), `+`, .init = 0)
#> [1] 0
simple_reduce(1, `+`)
#> [1] 1
simple_reduce(1:3, `+`)
#> [1] 6
simple_reduce(df, rbind)
#> num1 num2 chr1
#> 1    0    5    a
#> 2   10    6    b
#> 3   20    7    c
simple_reduce(list(df, df), rbind)
#> num1 num2 chr1
#> 1    0    5    a
#> 2   10    6    b
#> 3   20    7    c
#> 1    0    5    a
#> 2   10    6    b
#> 3   20    7    c

# 3. Implement the `span()` function from Haskell: given a list `x` and a predicate function `f`, 
#    `span(x, f)` returns the location of the longest sequential run of elements where the predicate is true.
#    (Hint: you might find `rle()` helpful.)
span_r <- function(x, f) {
  idx <- unname(map_lgl(x, ~ f(.x)))
  rlee <- rle(idx)
  # check that predicate is never TRUE
  if (!any(rlee$values)) {
    return(integer(0))
  }
  # Find length of longest run of TRUE
  longest <- max(rlee$lengths[rlee$values])
  # Find positition of (first) longest run
  longest_idx <- which(rlee$values & rlee$lengths == longest)[1]
  # Add up all lengths before the longest run
  out_start <- sum(rlee$lengths[seq_len(longest_idx - 1)]) + 1L
  out_end <- out_start + rlee$lengths[[longest_idx]] - 1L
  out_start:out_end
}
# Check that it works
span_r(iris, is.numeric)
#> [1] 1 2 3 4
span_r(iris, is.factor)
#> [1] 5
span_r(iris, is.character)
#> integer(0)

# 4. Implement `arg_max()`. It should take a function and a vector of inputs,
#    and return the elements of the input where the function returns the hightest value.
#    For example, `arg_max(-10:5, function(x) x ^ 2)` should return -10.
#    `arg_max(-5:5, function(x) x ^ 2)` should return `c(-5, 5)`.
#    Also implement the matching `arg_min()` function.

# Both funcitons take a vector of inputs and a function as an argument.
# The functions output are then used to subset the input accordingly.
arg_max <- function(x, f) {
  y <- map_dbl(x, f)
  x[y == max(y)]
}

arg_min <- function(x, f) {
  y <- map_dbl(x, f)
  x[new_x == min(y)]
}

arg_max(-10:5, function(x) x ^ 2)
#> [1] 10
arg_min(-10:5, function(x) x ^ 2)
#> [1] 0

# 5. The function below scales a vector so it falls in the range [0, 1].
#    How would you apply it to every column of a data frame? 
#    How would you apply it to every numeric column in a data frame?
scale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

# To apply a function to every function of a data frame, we can use `purrr::modify`, 
# which also conveniently returns a data frame.
# To limit the application ot numberic columns, the scoped versions `modify_if()` can be used.
str(iris)
#> 'data.frame':	150 obs. of  5 variables:
#>  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
#>  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
#>  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
#>  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
#>  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
str(modify_if(iris, is.numeric, scale01))
#> 'data.frame':	150 obs. of  5 variables:
#>  $ Sepal.Length: num  0.2222 0.1667 0.1111 0.0833 0.1944 ...
#>  $ Sepal.Width : num  0.625 0.417 0.5 0.458 0.667 ...
#>  $ Petal.Length: num  0.0678 0.0678 0.0508 0.0847 0.0678 ...
#>  $ Petal.Width : num  0.0417 0.0417 0.0417 0.0417 0.0417 ...
#>  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...

# 9.7 Base functionals

# To finish up the chapter, here I provide a survey of important base functionals that are not members of the map,
# reduce, or predicate families, and hence have no equivalent in purrr.
# This is not to say that they're not important, but they have more of a mathematical or statistical flavour,
# and they are generally less useful in data analysis.

# 9.7.1 Matrices and arrays

# `map()` and friends are specialised to work with one-dimensional vectors.
# `base::apply()` is specialised to work with two-dimensional and higher vectors, i.e. matrices and arrays.
# You can think of `apply()` as an operation that summarises a matrix or array by collapsing each row or column to a single value.
# It has hour arguments:

# - `X`, the matrix or array to summarise.

# - `MARGIN`, an integer vector giving the dimensions to summarise over 1 = rwos, 2 = columns, etc.
#   (The argument name comes from thinking about the margins of a joint distribution.)

# - `FUN`, a summary function.

# - `...` other arguments to passed on to `FUN`.

# A typicall example of `aaply()` looks like this 
a2d <- matrix(1:20, nrow = 5)
apply(a2d, 1, mean)
#> [1]  8.5  9.5 10.5 11.5 12.5
apply(a2d, 2, mean)
#> [1]  3  8 13 18

# You can specify moltiple dimensions to `MARGIN`, which is useful for high-dimensional arrays:
a3d <- array(1:24, c(2, 3, 4))
apply(a3d, 1, mean)
#> [1] 12 13
apply(a3d, c(1, 2), mean)
#      [,1] [,2] [,3]
# [1,]   10   12   14
# [2,]   11   13   15

# There are two caveats to using `apply()`:

# - Like `base::sapply()`, you have no control over the output;
#   it will automatically be simplified to a list, matrix, or vector.
#   However, you usually use `apply()` with numric arrays and a numbers summary function so you are less likely to encounter a problem than with `sapply()`.

# - `apply()` is also not idempotent in the sense that if the summary function is the idnetity operator,
#   the output is not always the same as the input.
a1 <- apply(a2d, 1, identity)
identical(a2d, a1)
#> [1] FALSE
a2 <- apply(a2d, 2, identity)
identical(a2d, a2)
#> [1] TRUE

# - Never use `apply()` with a data frame. It always coerces it to a matrix, 
#   which will lead to undesirable results if your data frame contains anything other than numbers.
df <- data.frame(x = 1:3, y = c("a", "b", "c"))
apply(df, 2, mean)
#> x  y 
#> NA NA 
#> Warning messages:
#> 1: In mean.default(newX[, i], ...) :
#>   argument is not numeric or logical: returning NA
#> 2: In mean.default(newX[, i], ...) :
#>   argument is not numeric or logical: returning NA

# 9.7.2 Mathematical concerns

# Functionals are very common in mathematics. The limit, the maximum, the roots(the set of points where `f(x) = 0`),
# and the definete integral are all functionals: given a function, they return a single number (or vector of numbers).
# At first glance, these functions don't seem to fit in with the theme of eliminating loops, 
# but if you dig deeper you'll find out that they are all implemented using an algorithm that involves iteration.

# Base R proivdes a useful set:

# - `integrate()` finds the area under the curve defined by `f()`

# - `uniroot()` finds where `f()` hits zero

# - `optimise()` finds the location of the lowest (or highest) value of `f()`

# The following example shows how functionals might be used with a simple function, `sin()`:
integrate(sin, 0, pi)
#> 2 with absolute error < 2.2e-14
str(uniroot(sin, pi * c(1 / 2, 3 / 2)))
#> List of 5
#>  $ root      : num 3.14
#>  $ f.root    : num 1.22e-16
#>  $ iter      : int 2
#>  $ init.it   : int NA
#>  $ estim.prec: num 6.1e-05
str(optimise(sin, c(0, 2 * pi)))
#> List of 2
#>  $ minimum  : num 4.71
#>  $ objective: num -1
str(optimise(sin, c(0, pi), maximum = TRUE))
#> List of 2
#>  $ maximum  : num 1.57
#>  $ objective: num 1

# 9.7.3 Exercises

# 1. How does `apply()` arrange the output?
#    Read the documentation and perform some experiments.

# Basically `apply()` applies a function over the margins of an array.
arr2 <- array(1:12, dim = c(3, 4))
rownames(arr2) <- paste0("row", 1:3)
colnames(arr2) <- paste0("col", 1:4)
arr2
#>      col1 col2 col3 col4
#> row1    1    4    7   10
#> row2    2    5    8   11
#> row3    3    6    9   12

# When we apply the `head()` function over the first margin of `arr2()`
# (i.e. the rows), the results are contained in the columns of the output,
# transposing the array compared to the original input.
apply(arr2, 1, function(x) x[1:2])
#>      row1 row2 row3
#> col1    1    2    3
#> col2    4    5    6

# And vice versa if we apply over the second margin (the columns):
apply(arr2, 2, function(x) x[1:2])
#>      col1 col2 col3 col4
#> row1    1    4    7   10
#> row2    2    5    8   11

# The output of `apply()` is organised first by the margins being operated over, 
# the the reults of the function. This can become quite confusing for higher dimensional arrays.

# 2. What do `eapply()` and `rapply()` do? Does purrr have equivalents?

# `eapply()` is a variant of `lapply()`, which iterates over the (named) elements of an environment.
# In purrr there is no equivalent for `eapply()` as purrr mainly provides functions that operate on vectors and function,
# but not on environments.

# `rapply()` applies a function to all elements of a list recursively.
# This function makes it possible to limit the application of the function to specified classes (default `classes = ANY)`).
# One may also specify how elements of other classes should remain:
# i.e. as their identity (how = replace) or another value (deflt = NULL).
# The closest equivalent in purrr is `modify_depth()`, 
# which allows you to modify elements at a specified depth in a nested list.

# 3. Challenge: read about the `fixed point algorithm`.
#    Complete the exercises using R.

fixed_point <- function(f, x_init, n_max = 10000, tol = 0.0001) {
  n <- 0
  x <- x_init
  y <- f(x)
  
  is_fixed_point <- function(x, y) {
    abs(x - y) < tol
  }
  
  while (!is_fixed_point(x, y)) {
    x <- y
    y <- f(x)
    
    n <- n + 1
    if (n > n_max) {
      stop("Failed to converge", call. = FALSE)
    }
  }
  
  x
}

# Functions with fixed points
fixed_point(sin, x_init = 1)
#> [1] 0.08430922
fixed_point(cos, x_init = 1)
#> [1] 0.7391302

# Functiona without fixed points
add_one <- function(x) x + 1
fixed_point(add_one, x_init = 1)
#> Error: Failed to converge

# References

# Henry, Lionel, and Hadley Wickham. 2018a. Purrr: Functional Programming Tools. 
# https://purrr.tidyverse.org.
