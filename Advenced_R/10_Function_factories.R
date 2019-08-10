set.seed(1014)

# 10.1 Introduction

# A __function factory__ is a function that makes functions.
# Here's a very simple example: 
# we use a function factory (power1()) to make two child functions (square() and cube()):
power1 <- function(exp) {
  function(x) {
    x ^ exp
  }
}

square <- power1(2)
cube <- power1(3)

# Don't worry if this doesn't make sense yet, it should by the end of the chapter!

# I'll call `square()` and `cube()` __manufactured functions__, but this is just a term to ease communication with other humans:
# from R's perspective they are no different to functions created any other way.
square(3)
#> [1] 9
cube(3)
#> [1] 27

# You have already learned about the individual components that make function factories possible:

# - In Section 6.2.3, you learned about R's first-class function.
#   In R, you bind a function to a name in the same way as you bind any object to a name: with `<-`.

# - In Section 7.4.2, you learned that a function captures (encloses) the environment in which it is created.

# - In Section 7.4.4, you learned that a function creates a new execution environment every time it is run.
#   This environment is usually ephemeral, but here it becaomes the enclosing environment of the manufactured function.

# In this chapter, you'll learn how the non-obvious combination of these three features leads to the function factory.
# You'll also see examples of their usage in visualisation and statistics.

# Of the three main functional programming tools (functionals, function factories, and function operators), function factories are the least used. 
# Generally, they don't tend to reduce overall code complexity but instead partition complexity into more easily digested chunks.
# Function factories are also an important building block for the very useful functoin operators, 
# which you'll learn about in Chapter 11.

# Outline

# - Section 10.2 begins the chapter with an explanation of how function factories work,
#   pulling together ideas from scpoing and environments.
#   You'll also see how function factories can be used to implement a memory for functions, 
#   allowing data to persist across calls.

# - Section 10.3 illustrates the use of function factories with examples from ggplot2.
#   you'll see two examples of how ggplot2 works with user supplied function factories,
#   and one example of where ggplot2 uses a function facotry internally.

# - Section 10.4 uses function facotries to tackle three challenges from statistics:
#   understanding the Box-Cox transform, solvnig maximun likihood problems, and drawing bootstrap resameples.

# - Section 10.5 shows how you can combine function factories and fucntionals to rapidly generate a family of fucntions from data.

# Prerequisites

# Make sure you're familiar with the contents of Section 6.2.3 (first-class functions),
# 7.4.2 (the fucntion environment), and 7.4.4 (execution environments) mentioned above.

# Function factories only need base R. 
# We'll use a little rlang to peek inside of them more easily, and we'll use ggplot2 and scales to explore the use of function facotries in visualisation.
library(rlang)
library(ggplot2)
library(scales)

# 10.2 Factory fundamentals

# The key idea that makes function facotries work can be expressed very condisely:
# The enclosing environment of the maunfactured function is an exxecution environment of the fucntion facotry.

# It only takes few words to express these big ideas, but it takes a lot more work to really understand what this means.
# This section will help you put the pieces together with interactive exploration and some diagrams.

# 10.2.1 Evironments

# Let's start by taking a look at `square()` and `cube()`:
square
#> function(x) {
#>   x ^ exp
#> }
#> <environment: 0x10c0e3178>

cube
# function(x) {
#   x ^ exp
# }
# <bytecode: 0x10bb77c68>
# <environment: 0x10c0e35d8>

# It's obvious where `x` comes from, but how does R find the value associated with `exp`?
# Simple printing the manufactured functions is not revealing because the bodies are identical;
# the contents of the enclosign environment are the important factors.
# We can get a little more insight by using `rlang::env_print()`.
# That shows us that we have two different environments (each of which was originally an execution environment of `power1()`).
# The environments have the same parent, which is the enclosing environment of `power1()`, the global environment.
env_print(square)
#> <environment: 0x10c0e3178>
#>   parent: <environment: global>
#>   bindings:
#>   * exp: <dbl>

env_print(cube)
#> <environment: 0x10c0e35d8>
#>   parent: <environment: global>
#>   bindings:
#>   * exp: <dbl>

# `env_print()` shows us that both environments have a binding to `exp`, but we want to see its value.
# We can do that by first getting the environment of the function, and then extractng the values:
fn_env(square)$exp
#> [1] 2
fn_env(cube)$exp
#> [1] 3

# This is what makes manufactured functions behave differently from one another:
# names in the enclosing environment are bound to different values.

# 10.2.2 Diagram conventions

# We can also show these relationships in a diagram:

# There's a lot going on this diagram and some of the details aren't that important.
# We can simplify condiserably by using two conventions:

# - Any free floating symbol lives in the global environment.
# - Any environment without an explicit parent inherits from the global environment.

# This view, which focuses on the environments, doesn't show any direct link between `cube()` and `square()`.
# That's because the link is the through the body of the function, which is identical for both,
# but is not shown in this diagram.

# To finish up, let's look at the execution environment of `square(10)`.
# When `square()` executes `x ^ exp` it finds `x` in the execution environment and `exp` in its enclosing environment.

square(10)
#> [1] 100

# 10.2.3 Forcing evaluation

# There's subtle bug in `power1()` caused by lazy evaluation.
# To see the problem we need to introduce some indirection:
x <- 2
square <- power1(x)
x <- 3

# What should `square(2)` return? You would hope it returns 4:
square(2)
#> [1] 8

# Unfortunately it doesn't because `x` is only evaluated lazily when `square()` is run, not when `power1()` is run.
# In gereral, this problem will arise whenever a binding changes in between calling the vacotry function and calling th emanufactured function.
# This is ilkely to only happen rarely, but when it does, it will lwad to a read head-scratcher of a bug.

# We can fix this problem by __forcing__ evaluation with `force()`:
power2 <- function(exp) {
  force(exp)
  function(x) {
    x ^ exp
  }
}

x <- 2
square <- power2(x)
x <- 3
square(2)
#> [1] 4

# Whenever you create a function factory, make sure every argument is evaluated, 
# using `force()` as necessary if the argument is only used by the maunfactured function.

# 10.2.4 Stateful functions

# Function factories also allow you to maintain state across function invocatoins, 
# which is generally hard to do because of the fresh start principle described in Section 6.4.3.

# There are two things that make this possible:

# - The enclosing environment of the manufactured function is unique and constant.
# - R has a special assignment operator, `<<-`, which modifies bindings in the enclosing environment.

# The usual assignment operator, `<-`, always creates a ginding in the current environment.
# The __super assignment operator__, `<<-` rebinds an exising name found in a parent environment.

# The following example shows how we can combine these ideas to create a function that records how many times it has been called:

new_counter <- function() {
  i <- 0
  
  function() {
    i <<- i + 1
    i
  }
}

counter_one <- new_counter()
counter_two <- new_counter()

# When the manufactured function is run `i <<- i + 1` will modify `i` in its enclosing environment.
# Because manufactured functions have independent enclosing environments, they have independent counts:
counter_one()
#> [1] 1
counter_one()
#> [1] 2
counter_two()
#> [1] 1

# Stateful functions are best used in moderation.
# As soon as your function starts managing the state of multiple variables, 
# it's better to switch to R6, the topic of Chapter 14.

# 10.2.5 Garbage collection

# With most functions, you can rely on the garbage collector to clean up any large temporary objects crerated inside a function.
# However, manufactured functions hold on the execution environment, so you'll need to explicitly unbind any large temporary objects with `rm()`.
# Compare the sizes of `g1()` and `g2()` in the example below:
f1 <- function(n) {
  x <- runif(n)
  m <- mean(x)
  function() m
}

g1 <- f1(1e6)
lobstr::obj_size(g1)
#> 8,002,416 B

f2 <- function(n) {
  x <- runif(n)
  m <- mean(x)
  rm(x)
  function() m
}

g2 <- f2(1e6)
lobstr::obj_size(g2)
#> 1,896 B

# 10.2.6 Exercises

# 1. The definition of `force()` is simple:
force
#> function (x) 
#>   x
#> <bytecode: 0x10285c4a0>
#> <environment: namespace:base>

# As you can see `force(x)` is just syntactic sugar for `x`.
# We perfer this explicit form, because 
# using this function clearly indicates that you're forcing evaluation, 
# not that you've accidentally typed `x`. (Quote from the textbook)

# 2. Base R contains two function factories, `apporxfun()` and `ecdf()`.
#    Read their documentation and experiment figure out what the functions do and what they return.

# Let's begin with `apprxfun()` as it is used within `ecdf()` also:

# - `approxfun()` takes a 2-dimensional combination of data points (`x` and `y`)
#    as input and returns a stepwise interpolation function, which transforms new `x` values.
#    Additional arguments control how the created function should behave.
#    (The interpolation `method` may be linear or ocnstant. 
#    `yleft`, `yright` and `rule` specify how the newly created function should map new values which are outside of `range(x)`.
#    `f` controls the degree fo right-left-contibuity via a numeric value from `0` to `1` and `ties` expects function names like min, mean, etc.
#    Which defines how on-unique x-y-combinations should be handled when interpolating the data points.)

# - `ecdf()` is an acronym for empirical cumulative distribution function.
#    for a numeric vector, `ecdf()` returns the appropiate distribution function
#    (of class "ecdf", which is inderiting from class "stepfun").
#    Initially the (x, y) pairs for the nodes of the density function are calculated.
#    Afterwards these pairs are passed to `approxfun()`, which then returns the desired function.

# 3. Create a function `pick()` that takes an index, `i` as an argument and returns a function with an arguemnt `x` that subsets `x` with `i`.
pick(1)(x)
# should be equivalent to 
x[[1]]

lapply(mtcars, pick(5))
# should be equivalent to 
lapply(mtcars, function(x) x[[5]])

pick <- function(i) {
  force(i)
  
  function(x) x[[i]]
}
x <- 1:3
identical(x[[1]], pick(1)(x))
#> TRUE
identical(lapply(mtcars, function(x) x[[5]]),
          lapply(mtcars, pick(5)))
#> TRUE

# 4. Create a fucntion tha tcreates function that compute the i^th contral moment of a numeric vector.
#    You can test it by running the following code:
m1 <- moment(1)
m2 <- moment(2)

x <- runif(100)
stopifnot(all.equal(m1(x), 0))
stopifnot(all.equal(m2(x), var(x) * 99 / 100))

# The first moment is closely related to the mean and describes the average deviation from the mean,
# which is 0 ( within numerial margin of error).
# The second moment describes the variance of the input data.
# If we want compare it to `var`, we need to undo [Bessel's correction}
# (https://en.wikipedia.org/wiki/Bessel%27s_correction) correction by multiplying with (N - 1) / N.

moment <- function(i) {
  force(i)
  function(x) sum(x - mean(x) ^ i) / length(x)
}

m1 <- moment(1)
m2 <- moment(2)

x <- runif(100)
all.equal(m1(x), 0)
#> [1] TRUE
all.equal(m2(x), var(x) * 99 / 100)
#> [1] "Mean relative difference: 0.6758236"

# 5. What happens if you don't use a closure? Make predictions, 
#    then verify with the code below.
i <- 0
new_counter2 <- function() {
  i <<- i + 1
  i
}

# Without the captured and encapsulated environment of a closure the counts will be stored in the global environment.
# Here they can be overwritten or deleted as well as interfere with other counters.
new_counter2()
#> [1] 1
i
#> [1] 1
new_counter2()
#> [1] 2
i
#> [1] 2

i <- 0
new_counter2()
#> [1] 1
i
#> [1] 1

# 6. What happens if you use `<-` instead of `<<-`?
#    Make predictions, then verify with the code below.
new_counter3 <- function() {
  i <- 0
  function() {
    i <- i + 1
    i
  }
}

# Without the super assignment `<<-`, the counter will always return 1.
# The counter always starts in a new execution environment within the same enclosing environment, 
# which contains an unchanged value for `i` (in this case it remains 0).
new_counter_3 <- new_counter3()

new_counter_3()
#> [1] 1
new_counter_3()
#> [1] 1

# 10.3 Graphical factories

# We'll begin our exploratino of useful function factories with a few examples from ggplot2.

# 10.3.1 Labelling 

# One of the goals of the scales package is to make it easy to customise the labels on ggplot2.
# It provides many functions to control the fine details of axes and legends.
# The formatter functions are a useful class of functions which make it easier to control the appearance of axis breaks.
# The design of these functions might initially seem a little odd:
# they all return a function, which you have to call in order to format a number.
y <- c(12345, 123456, 1234567)
comma_format()(y)
#> [1] "12,345"    "123,456"   "1,234,567"

number_format(scale = 1e-3, suffix = " K")(y)
#> [1] "12 K"    "123 K"   "1 235 K"

# In other words, the primary interface is a function facotry.
# At first glance, this seems to add extra complexity for little gain.
# But it enables a nice interaction with ggplot2's scales, 
# because they accept fucntions in the `label` argument:

df <- data.frame(x = 1, y = y)
core <- ggplot(df, aes(x, y)) + 
  geom_point() +
  scale_x_continuous(breaks = 1, labels = NULL) +
  labs(x = NULL, y = NULL)
core
core + scale_y_continuous(
  labels = comma_format()
)
core + scale_y_continuous(
  labels = number_format(scale = 1e-3, suffix = " k")
)
core + scale_y_continuous(
  labels = scientific_format()
)

# 10.3.2 Histogram bins 

# A little known feature of `geom_histogram()` is that the `binwidth` argument can be a function.
# This is particularly useful because the function is executed once for each group, 
# which means you can have different binwidths in different facets, which is otherwise not possible.

# To illustrate this idea, and where variable binwidth migh tbe useful, 
# I'm going to construct an example where a fixed binwidth isn't great.

# construct some sample data with very different numbers in each cell
sd <- c(1, 5, 15)
n <- 100

df <- data.frame(x = rnorm(3 * n, sd = sd), sd = rep(sd, n))

ggplot(df, aes(x)) +
  geom_histogram(binwidth = 2) +
  facet_wrap(~ sd, scales = "free_x") +
  labs(x = NULL)

# Here each facet has the same number of observations, but the variability is very different.
# It would be nice if we could request that the binwidths vary so we get approximately the same numbers fo observation in each bin.
# One way to do that is with a function factory that inputs the desired number of bins(n), 
# and outputs a function that takes a numeric vector and returns a binwidth:
binwidth_bins <- function(n) {
  force(n)
  
  function(x) {
    (max(x) - min(x)) / n
  }
}

ggplot(df, aes(x)) + 
  geom_histogram(binwidth = binwidth_bins(20)) +
  facet_wrap(~ sd, scales = "free_x") + 
  labs(x = NULL)

# We could use this same pattern to warp aroud the base R functions that automatically find the so-colled optimal binwidth,
# `nclass.Sturges()`, `nclass,scott()`, and `nclass.FD()`:
base_bins <- function(type) {
  fun <- switch(type,
    Sturges = nclass.Sturges,
    scott = nclass.scott,
    FD = nclass.FD,
    stop("Unknown type", call. = FALSE))
  
  function(x) {
    (max(x) - min(x)) / fun(x)
  }
}

ggplot(df, aes(x)) + 
  geom_histogram(binwidth = base_bins("FD")) + 
  facet_wrap(~ sd, scales = "free_x") + 
  labs(x = NULL)

# 10.3.3 `ggsave()`

# Finally, I want to show a function facotry used internally by ggplot2.
# `ggplot2::plot_dev()` is used by `ggsave()` to go from a file extension (e.g. `png`, `jpeg` etc) 
# to a graphics device function (e.g. `png()`, `jpeg()`).
# The callenge here arises because the base graphics devices have some minor inconsistencies which we need to paper over:

# - Most have `filename` as first argument but some have `file`.
# - The `width` and `height` of raster graphic devices use pixels units by default, 
#   but the vector graphics use inches.

# A mildly simplified version of `plot_dev()` is shown below:

plot_dev <- function(ext, dpi = 96) {
  force(dpi)
  
  switch(ext,
         eps =  ,
         ps  =  function(path, ...) {
           grDevices::postscript(
             file = filename, ..., onefile = FALSE, 
             horizontal = FALSE, paper = "special"
           )
         },
         pdf = function(filename, ...) grDevices::pdf(file = filename, ...),
         svg = function(filename, ...) svglite::svglite(file = filename, ...),
         emf = ,
         wmf = function(...) grDevices::win.metafile(...),
         png = function(...) grDevices::png(..., res = dpi, units = "in"),
         jpg = ,
         jpeg = function(...) grDevices::jpeg(..., res = dpi, units = "in"),
         bmp = function(...) grDevices::bmp(..., res = dpi, units = "in"),
         tiff = function(...) grDevices::tiff(..., res = dpi, units = "in"),
         stop("Unknown graphics extension: ", ext, call. = FALSE)
  )
}

plot_dev("pdf")
#> function(filename, ...) grDevices::pdf(file = filename, ...)
#> <bytecode: 0x112875738>
#> <environment: 0x111c4b7c8>
plot_dev("png")
#> function(...) grDevices::png(..., res = dpi, units = "in")
#> <bytecode: 0x10de9ddc8>
#> <environment: 0x11185f958>

# 10.3.4 Exercises

# 1. Compare and contrast `ggplot2::label_bquote()` with `scales::number_format()`

# label_bquote() offers a flexible way of labelling facet rows or columns with plotmath expressions.
# Backquoted variables will be replaced with their value in the facet.

# 10.4 Statisticla facotries 

# More motivating examples for function factories come from statistics:

# - The Box-Cox transformation.
# - Bootstrap resampling.
# - Maximun likelihood estimation.

# All of these examples can be tackled without function factories, 
# but I think funtion factories are a good fit fo rthese problems and provide elegant solutions.
# These examoples expect some statistical backgroud, so feel free to skip if they don't make much sense to you.

# 10.4.1 Box-Cox transformation

# The Box-Cox transformation (a type of power transformation) is a flexible transformation often used to transform data toards noramlity.
# It has a single parameter, λ, which controls the strength of the tranformation.
# We could express the transformation as a simpel two argument function:
boxcox1 <- function(x, lambda) {
  stopifnot(length(lambda) == 1)
  
  if (lambda == 0) {
    log(x)
  } else {
    (x ^ lambda - 1) / lambda
  }
}

# But re-formulating as a function factory makes it easy to explore its behaviour with `stat_function()`:
boxcox2 <- function(lambda) {
  if (lambda == 0 ) {
    function(x) lag(x)
  } else {
    function(x) (x ^ lambda - 1) / lambda
  }
}

stat_boxcox <- function(lambda) {
  stat_function(aes(colour = lambda), fun = boxcox2(lambda), size = 1)
}

ggplot(data.frame(x  = c(0, 5)), aes(x)) + 
  lapply(c(0.5, 1, 1.5), stat_boxcox) + 
  scale_colour_viridis_c(limits = c(0, 1.5))

# visually, log() does seem to make sense as the transformation 
# for lambda = 0; as values get smaller and smaller, the function 
# gets close and closer to a log transformation
ggplot(data.frame(x = c(0.01, 1)), aes(x)) +
  lapply(c(0.5, 0.25, 0.1, 0), stat_boxcox) +
  scale_colour_viridis_c(limits = c(0, 1.5))

# In grneral, this allows you to use a Box-Cox transformation with any function that accepts a unary transformation function :
# you don't have to worry about that function providing `...` to pass along additoinal arguments.
# I also think that the partitioning of `lambda` and `x` into two different function arguments is natural since `lambda` plays quite a fifferent role than `x`.

# 10.4.2 Bootstrap generators

# Function factories are a useful approach for bootstrapping.
# Instead of thinking about a single bootstrap (you always need more than one!),
# you can think about a bootstrap __generator__, a function that yields a fresh bootstrap every time it is called:
boot_permute <- function(df, var) {
  n <- nrow(df)
  force(var)
  
  function() {
    col <- df[[var]]
    col[sample(n, replace = TRUE)]
  }
}

boot_mtcars1 <- boot_permute(mtcars, "mpg")
head(boot_mtcars1())
#> [1] 15.2 21.0 19.2 19.2 21.0 13.3
head(boot_mtcars1())
#> [1] 15.8 19.7 22.8 22.8 21.0 24.4

# The advantag eof a function factory is more clear with a parametric bootstrap where we have to first fit a model.
# We can do this setup step once, when the factory is called, rather than once every time we generate the bootstrap:

boot_model <- function(df, formula) {
  mod <- lm(formula, data = df)
  fitted <- unname(fitted(mod))
  resid <- unname(resid(mod))
  rm(mod)
  
  function() {
    fitted + sample(resid)
  }
}

boot_mtcars2 <- boot_model(mtcars, mpg ~ wt)
head(boot_mtcars2())
#> [1] 24.45596 28.34175 24.83570 26.97536 19.76702 21.25762
head(boot_mtcars2())
#> [1] 20.50167 18.71441 23.96618 16.19729 19.25657 21.25762

# I use `rm(mod)` because linear model objects are quite large
# (they include complete copies of the model matrix and input data) 
# and I want to keep the manufactured function as samll as possible.

# 10.4.3 Maximum likelyhood estimation

# The goal of maximum likelhood estimation (MLE) is to find the parameter values for a distribution that make the observed data most likely.
# To do MLE, you start with a probability function. For example, take the Poisson distribution.
# If we know λ, we can compute the probablility of getting a vector x of values(x_1, x_1, ..., x_n)
# by multiplying th ePoisson probability function as follows:

# We can now turn this function into an R function.
# The R function is quite elegant because R is vectorised and, because it's a statistical programming language,
# R comes with built-in functions like the log-factorial(`lfactorial()`).
lprob_poisson <- function(lambda, x) {
  n <- length(x)
  (log(lambda) * sum(x)) - (n * lambda) - sum(lfactorial(x))
}

# Consider this vector of observations:
x1 <- c(41, 30, 31, 38, 29, 24, 30, 29, 31, 38)

# We can use `lprob_poisson()` to compute the (logged) probability of `x1` for different values of `lambda`.
lprob_poisson(10, x1)
#> [1] -183.6405
lprob_poisson(20, x1)
#> [1] -61.14028
lprob_poisson(30, x1)
#> [1] -30.98598

# So far we've been thinking of `lambda` as fixed and known and the function told us the probalility of getting different values of `x`.
# But in real-life, we observer `x` and it is `lambda` that is unknown.
# This likelihood is the probability function seen throung this lens: 
# we want to find the `lambda` that makes the observed `x` the most likely.
# That is, given `x`, what value of `lambda` gives us the highest value of `lprob_poisson()`?

# In statistics, we hightlight this change in perspective by writting f_x(λ) instead of f(λ, χ).
# In R, we can use a function factory. We provide `x` and generate a function with a single parameter, `lambda`:
ll_poisson1 <- function(x) {
  n <- length(x) 
  
  function(lambda) {
    log(lambda) * sum(x) - n * lambda - sum(lfactorial(x))
  }
}

# (We don't need `force()` because `length()` impolicitly forces evaluation of `x`.)

# One nect thing about this appraoch is that we can do some precomputation:
# any term that only involves `x` can be computed once in factory.
# This is useful because we're going to need to call this function many tiems to find the best `lambda`.
ll_poisson2 <- function(x) {
  n <- length(x) 
  sum_x <- sum(x)
  c <- sum(lfactorial(x))
  
  function(lambda) {
    log(lambda) * sum_x - n * lambda - c
  }
}

# Now we can use this function to find the value of `lambda` that maximizes the (log) likelihood:
ll1 <- ll_poisson2(x1)
ll1(10)
#> [1] -183.6405
ll1(20)
#> [1] -61.14028
ll1(30)
#> [1] -30.98598

# Rather than trial and error, we can automate the process of finding the best value with `optimise()`.
# It will evaluate `ll1()` many times, usign mathematical tricks to narro in on th elargest value as quickly as possible.
# the results tell us that the hightest value is `-30.27` which occurs when `lambda = 32.1`:
optimise(ll1, c(0, 100), maximum = TRUE)
#> $maximum
#> [1] 32.09999
#> 
#> $objective
#> [1] -30.26755

# Now, we could have solved this problem without using a function factory because `optimise()` passes `...` on to the function being optimised.
# That meas we could use the log-probability function directly:
optimise(lprob_poisson, c(0, 100), x = x1, maximum = TRUE)
#> $maximum
#> [1] 32.09999
#> 
#> $objective
#> [1] -30.26755

# The advantage of using a function factory here is fairly small, but there are two niceties:

# - We can precompute some value in the factory, saving computation time in each iteration.
# - The two-level design better reflects the mathematical structure of teh underlying problem.

# These advantages get bigger in more complex MLE problems, where you have multiple parameters and multiple data vectors.

# 10.4.4 Exercises

# 1. In `boot_model()`, why don't I need to force the evaluation of `df` or `model`?

# `boot_model()` ultimately returns a function, and whenever you return a function you need to make sure all the inputs are explicitly evaluated.
# Here that happens automatically because we use `df` and `formula` in `lm()`.

# 2. Why might you formultate the Box-Cox transformation like this?
boxcox3 <- function(x) {
  function(lambda) {
    if (lambda == 0) {
      log(x)
    } else {
      (x ^ lambda - 1) / lambda
    }
  }
}

# `boxcox3` returns a function where `x` is fixed (though it is not forced, so it may manipulated later).
# This allows us to apply and test different trnasfroamtions for different inputs an dgive them a desctiptive name.

# initail example (shoud be imporved) 
boxcox_airpassengers <- boxcox3(AirPassengers)
plot(boxcox_airpassengers(0))
plot(boxcox_airpassengers(1))
plot(boxcox_airpassengers(2))

# 3. Why don't you need to worry that `boot_permute()` stores a copy of the data inside the function that it generates?

# Because it doesn't actually store a copy;
# it's just a name that points to the same underlying object in memory.
boot_permute <- function(df, var) {
  n <- nrow(df)
  force(var)
  
  function() {
    col <- df[[var]]
    col[sample(n, replace = TRUE)]
  }
}

boot_mtcars1 <- boot_permute(mtcars, "mpg")

lobstr::obj_size(mtcars)
#> 7,208 B
lobstr::obj_size(boot_mtcars1)
#> 11,880 B
lobstr::obj_sizes(mtcars, boot_model)
#> * 7,208 B
#> * 7,880 B

# 4. How much time does `ll_poisson2()` save compared to `ll_poisson1()`?
#    Use `bench::mark()` to see how much faster the optimisation occurs.
#    How does changing the length of `x` change the results?

# Let us recall the definitions of `llpoisson1()` and `ll_poisson2()` and the test data `x1`:
ll_poisson1 <- function(x) {
  n <- length(x)
  
  function(lambda) {
    log(lambda) * sum(x) - n * lambda - sum(lfactorial(x))
  }
}

ll_poisson2 <- function(x) {
  n <- length(x)
  sum_x <- sum(x)
  c <- sum(lfactorial(x))
  
  function(lambda) {
    log(lambda) * sum_x - n * lambda - c
  }
}

# provided test data 
x1 <- c(41, 30, 31, 38, 29, 24, 30, 29, 31, 38)

# A benchmark with this data reveals a performance imporvement of factor 2 for `ll_poisson2()` over `ll_poisson1()`
bench::mark(
  llp1 = optimise(ll_poisson1(x1), c(0, 100), maximum = TRUE),
  llp2 = optimise(ll_poisson2(x1), c(0, 100), maximum = TRUE)
)
#> # A tibble: 2 x 13
#>   expression    min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result memory
#>   <bch:expr> <bch:> <bch:>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm> <list> <list>
#> 1 llp1       33.3µs 35.3µs    26165.        0B    10.5   9996     4      382ms <list… <df[,…
#> 2 llp2         18µs 19.7µs    42230.        0B     8.45  9998     2      237ms <list… <df[,…
#> # … with 2 more variables: time <list>, gc <list>

# Regarding differing length of `x1`, we expect even further performanc imporvements of `ll_poisson2()` compared to `ll_poisson1()`,
# as the redundant calculations within `ll_poisson1()`, become more expensive with growing length of `x1`.
# The following results imply that for a length of `x1` of 100000, `ll_poisson2()` is about 20+ times as fast as `ll_poisson1()`:
library(purrr)
library(dplyr)

bench_poisson <- function(i) {
  x_i_length <- 10L ^ i
  x_i <- rpois(x_i_length, 100L)
  
  rel_advantage <- bench::mark(llp1 = optimise(ll_poisson1(x_i), c(0, 100), maximum = TRUE),
                               llp2 = optimise(ll_poisson2(x_i), c(0, 100), maximum = TRUE),
                               relative = TRUE)$median %>% 
    max()
  rel_advantage
}
bench_df <- map_dbl(1:5, bench_poisson) %>% 
  tibble(i = 1:5, 
         rel_advatage = .,
         x_length = 10 ^ i)

bench_df %>% 
  ggplot(aes(x_length, rel_advatage)) +
  geom_point() + 
  geom_line() + 
  ggtitle("Rel. Speed of ll_poisson2() increases with vector length") + 
  scale_x_log10()

# 10.5 Function factories + functionals

# To finish off the chapter, I'll show how you might combine functionals and function factories to turn data into many functions.
# The following code creates many specially named power functions by iterating over a list of arguments:
names <- list(
  square = 2, 
  cube = 3, 
  root = 1/2,
  cuberoot = 1/3,
  reciprocal = -1
)

funs <- purrr::map(names, power1)

funs$root(64)
#> [1] 8
funs$root
#> function(x) {
#>   x ^ exp
#> }
#> <bytecode: 0x106e8a098>
#> <environment: 0x10c26abe0>

# This idea extends in a straightforward way if your function factory takes two (replace `map()` with `map2()`) or more (replace with `pmap()`) arguments.

# One downside of the current construction is that you have to prefix every function call with `funs$`.
# There are three ways to eliminate this additonal syntax:

# - For a very temporary effect, you can use `with()`:
with(funs, root(100))
#> [1] 100

#   I recommend this because it makes it very clear when code is being executed in a special context and what that context is.

# - For a longer effect, you can `attach()` the functions to the search path, then `detach()` when you're done:
attach(funs)
#> The following objects are masked _by_ .GlobalEnv:
#>   
#>   cube, square
root(100)
#> [1] 10
detach(funs)

#   You've probably been told to avoid using `attach()`, and that's generally good advice.
#   Howevery, the situation is a little different to the ususal because we're attaching a list of functions, not a data frame.
#   It's less likely that you'll modif a function than a column in data fraem, 
#   so the some of the worst problems with `attch()` don't apply.

# - Finally, you could copy th unctions to the globla environment with `env_bind()` 
#   (you'll learn abotu `!!!` in Section 19.6). This is mostly permanent:
rlang::env_bind(globalenv(), !!!funs)
root(100)

#   You can later unbind those same names, but there's no guarantee tha tthey haven't been rebound in the meantime,
#   you might be deleting an object that someone else ceated.
rlang::env_unbind(globalenv(), names(funs))

# You'll laern an alternative approach to the same problem in Section 19.7.4.
# Instead of using a function factory, you could construct the fucntion with quasiquotation.
# This require additional knowledge, but generates functions wtih readable bodies, and avoids accidentally capturing large objects in the enclosing scope.
# We use that idea in Sectin 21.2.4 when we work on tools for generating HTML from R.

# 10.5.1 Exercises

# 1. Which of the following commands is equivalent to `with(x, f(z))`?

#   a. x$f(x$z).
#   b. f(x$z).
#   c. x$f(z).
#   d. f(z).
#   e. It depends.
# (e) "It depends" is the correct answer. Usually `with()` is used with a data frame, 
# so you'd usually expect (b), but if `x` is a list, it coould be any of the options.
f <- mean
z <- 1
x <- list(f = mean, z = 1)

identical(with(x, f(z)), x$f(x$z))
#> [1] TRUE
identical(with(x, f(z)), f(x$z))
#> [1] TRUE
identical(with(x, f(z)), x$f(z))
#> [1] TRUE
identical(with(x, f(z)), f(z))
#> [1] TRUE

# 2. Compare and contrast the effects of `env_bind()` vs. `attach()` for the following code.
funs <- list(
  mean = function(x) mean(x, na.rm = TRUE),
  sum = function(x) sum(x, na.rm = TRUE)
)

attach(funs)
#> The following objects are masked from package:base:
#>   
#>   mean, sum
detach(funs)

env_bind(globalenv(), !!!funs)
mean <- function(x) stop("Hi!")
env_unbind(globalenv(), names(funs))

# `attach()` adds `funs` to the search path. Therefore, the provide functions are found before their respective versons form teh vase package.
# Further, thery can not get accidnetly overwritten by similar named function in the global environment.
# One annonying downside of using `attach()` is the possibility to attach the same object multiple times, 
# making it necessary to call `detach()` equally often.

# In contrast `rlang::env_bind()` just adds the funtions in `fun` to the global environment.
# No further ide effects are introduced and the functions are overwritten when similarly namesd functions are defined.
