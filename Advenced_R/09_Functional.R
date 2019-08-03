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





























