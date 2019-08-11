set.seed(1014)

# 11 Function operators 

# 11.1 Introduciton

# In this chapter, you'll learnn about function operators.
# A __function operator__ is a function that takes one (or more) functions as input and returns a funtion as output.
# The following code shows a simple function operator, `chatty()`.
# It wraps a function, making a new function that prints out its first argument.
# You might create a function like this because it gives you a window to see how functionals, like `map_int()` wrok.
chatty <- function(f) {
  force(f)
  
  function(x, ...) {
    res <- f(x, ...)
    cat("Processing ", x, "\n", sep = "")
    res
  }
}

f <- function(x) x ^ 2
s <- c(3, 2, 1)
purrr::map_dbl(s, chatty(f))
#> Processing 3
#> Processing 2
#> Processing 1
#> [1] 9 4 1

# Function operators are colsely relted to function factories; indeed they're just a function factory that takes a function as input.
# Like factories, there's nothing you can't do without them, but they often allow you to factor out complexity in order to make your code more readable and reusable.

# Function operators are typically paired with functionals.
# If you're using a for-loop, there's rerely a reason to use a function operator, 
# as it will make your code more conplex for little gain.

# If you're familiar with Python, decorators is just another name for function operators.

# Outline

# - Seciton 11.2 introduces you to two extremely useful existing function operators, 
#   and shows you how to use them to solve real problems.

# - Section 11.3 works througn a problem amenable to solution with function operators: 
#   downloading many web pages.

# Prerequisites

# Function operators are a type of functin farctory, so make sure you're familiar with at least Section 6.2 before you go on.

# We'll use purrr for a couple of functionals that you learned about in Chapter 9, 
# and some function operators that you'll learn about below.
# We'll also use the momoise package (Wickham et al.2018) for the `memoise()` operator.

library(purrr)
library(memoise)

# 11.2 Existing function operators

# There are two very useful function operators that will both help you solve common recurring problems, 
# and give you a sense for what function operators can do: `purrr::safely()` and `memoise::memoise()`.

# 11.2.1 Capturing errors with `purrr::safely()`

# One advantage of for-loops is that if one of th eiterations fails, you can still access all the results up to the failure:
x <- list(
  c(0.512, 0.165, 0.717),
  c(0.064, 0.781, 0.427),
  c(0.890, 0.785, 0.495),
  "oops"
)

out <- rep(NA_real_, length(x))
for (i in seq_along(x)) {
  out[[i]] <- sum(x[[i]])
}
#> Error in sum(x[[i]]) : invalid 'type' (character) of argument
out
#> [1] 1.394 1.272 2.170    NA

# If you do the same thing with a functional, you get no ouptut, making it hard to figure out where the problem lies:
map_dbl(x, sum)
#> Error in .Primitive("sum")(..., na.rm = na.rm) : 
#>   invalid 'type' (character) of argument

# `purrr::safely()` provides a tool to help with this problem.
# `safely()` is a function operator that transforms a function to turn errors into data.
# (You can learn the basic idea that makes it work in Section 8.6.2.)
# Let's start by taking a look at it outside of `map_dbl()`:
safe_sum <- safely(sum)
#> function (...) 
#> capture_error(.f(...), otherwise, quiet)
#> <bytecode: 0x10ab2c590>
#> <environment: 0x10b9b6858>
 
# Like all function operators, `safely()` takes a function and returns a wrapped function which we can call as usual:
str(safe_sum(x[[1]]))
#> List of 2
#> $ result: num 1.39
#> $ error : NULL
str(safe_sum(x[[4]]))
#> List of 2
#> $ result: NULL
#> $ error :List of 2
#> ..$ message: chr "invalid 'type' (character) of argument"
#> ..$ call   : language .Primitive("sum")(..., na.rm = na.rm)
#> ..- attr(*, "class")= chr [1:3] "simpleError" "error" "condition"

# You can see that a fucntion transformed by `safely()` always returns a list with two elements, `result` and `error`.
# If th efunction runs successfully, `error` is `NULL` and `result` contains the result;
# if the fucntion fails, `result` is `NULL` and `error` contains the error.

# Now lets use `safely()` with a fucntional:
out <- transpose(map(x, safely(sum)))
str(out)
#> List of 2
#> $ result:List of 4
#> ..$ : num 1.39
#> ..$ : num 1.27
#> ..$ : num 2.17
#> ..$ : NULL
#> $ error :List of 4
#> ..$ : NULL
#> ..$ : NULL
#> ..$ : NULL
#> ..$ :List of 2
#> .. ..$ message: chr "invalid 'type' (character) of argument"
#> .. ..$ call   : language .Primitive("sum")(..., na.rm = na.rm)
#> .. ..- attr(*, "class")= chr [1:3] "simpleError" "error" "condition"

# Now we can easily find th eresults that worked, or the inputs that filed:
ok <- map_lgl(out$error, is.null)
ok
#> [1]  TRUE  TRUE  TRUE FALSE

x[!ok]
#> [[1]]
#> [1] "oops"
out$result[ok]
#> [[1]]
#> [1] 1.394
#> 
#> [[2]]
#> [1] 1.272
#> 
#> [[3]]
#> [1] 2.17

# You can use this same technique in many different situations.
# For example, imagine you're fitting a generalised linear model (GLM) to a list of data frmaes.
# GLMs can sometimes fail because of optimisation problems, but you still want to be able to try to fit all the models, 
# and later look back at those that failed:
fit_model <- function(df) {
  glm(y ~ x1 + x2 * x3, data = df)
}

models <- transpose(map(datasets, safely(fit_model)))
ok <- map_lgl(models$error, is.null)

# which data failed to converge?
datasets[!ok]

# which models were successful?
models[ok]

# I think this is a great example of the power of combining functionals and function operators:
# `safely()` lets you succinctly express what you need to solve a commom data analysis problem.

# purrr comes with three other functin operators in a similar vein:

# - `possibly()`: retuns a default value when there's an error.
#    It provides no way to tell if an error occured or not, 
#    so it's best reserved for casses when there's some obvious sentinel value (like NA).
map_dbl(x, possibly(sum, otherwise = NA_real_))

# - `quietly()`: turns output, messages, and warning side-effects into `outptu`,
#   `message`, and `warning` components of the output.

# - `auto_browser()`: automatically executes `browser()` inside the functin when there's an error.

# 11.2.2 Caching computations with `memoise::memoise()`

# Another handy function operator is `memoise::memoise()`.
# It __memoises__ a function, meaning that the function will rememeber previous inputs and return cached results.
# Memoisation is an example of the class computer science tradeoff of memory versus speed.
# A memoised function can run much faster, but because it stores all of the previous inputs and outputs, it uses more memory.

# Let's explore this idea with a toy function that simulates an expensive operation:
slow_function <- function(x) {
  Sys.sleep(1)
  x * 10 * runif(1)
}
system.time(print(slow_function(1)))
#> [1] 6.049454
#>     user  system elapsed 
#>    0.006   0.005   1.001
system.time(print(slow_function(1)))
#> [1] 8.440193
#>     user  system elapsed 
#>    0.009   0.006   1.003 

# When we memoise this function, it's slow when we call it with new arguments.
# But when we call it wiht arguments that it's seen before it's instantaneous: 
# it retrieves the prevous value of the copuatation.
fast_function <- memoise::memoise(slow_function)
system.time(print(fast_function(1)))
#> [1] 6.458006
#>     user  system elapsed 
#>    0.011   0.007   1.004 
system.time(print(fast_function(1)))
#> [1] 6.458006
#>     user  system elapsed 
#>    0.017   0.000   0.016 

# A relatively realistic use of memoisation is computing the Fibonacci series.
# The fibonacci series is defined recursively: the first two values are difined by ocnvention,
# f(0) = 0, f(1) = 1, and then f(n) = f(n - 1) + f(n - 2) (for any positive integer).
# A naive version is slow because, for example, `fib(10)` computes `fig(9)` and `fib(8)`, and `fib(9)` computes `fib(8)` and `fib(7)`, and so on.
fib <- function(n) {
  if (n < 2) return(1)
  fib(n - 2) + fib(n - 1)
}

system.time(fib(23))
#>  user  system elapsed 
#> 0.038   0.000   0.038 
system.time(fib(24))
#>  user  system elapsed 
#> 0.061   0.000   0.062 

# Memoising `fib()` makes the imolementation much faster because each value is computed only once:
fib2 <- memoise::memoise(function(n) {
  if (n < 2) return(1) 
  fib2(n - 2) + fib(n - 1)
})
system.time(fib2(23))
#>  user  system elapsed 
#> 0.068   0.001   0.071

# And future calls can rely on previous computations:
system.time(fib2(24))
#>  user  system elapsed 
#> 0.084   0.001   0.086 

# This is an example of __dynamic programming__, where a complex problem can be broken down into many overlapping subproblems,
# and rememebering the results of a subproblem consderably imporves performance.

# Think carefully before memoiseing a function.
# If the function is not __pure__, i.e. the output does not depend only on the input, 
# you will get misleading and confusing results.
# I created a subtle bug in devtools because I memorised the results of `available.packages()`, 
# which is rather slow because it has to download a large file from CRAN.
# The available packages don't change that frequently, but if you have an R process that's been running for a few days,
# the changes can become important, and because the problem only arose in long-runnign R processes, 
# the bug was very painful to find.

# 11.2.3 Exercises

# 1. Base R provides a fucntion ooperator in the form of `Vectorize()`.
#    What does it do? When might you use it?

# In R a lot of functions are "vectorised". Vectorised has two meanings.
# Fitst, it means (broadly) that a function inputs a vector or vectors, and does something to each element.
# Secondly, it usually implies that these operations are implemented in a complied language such as C or Fortran, 
# so that the implememtation is very fast.

# However, despite what the function's name implies, `Vectorize()` in not able to speed up the provided function.
# It rather changes the input format fo the supplied arguments (vectorize.args),
# so that they can be iterated over.

# In essence, `Vectorize()` is mostly a wrapper for `mapply()`.
# Let's take a look at an example from the documentation.
vrep <- Vectorize(rep.int)
vrep
#> function (x, times) 
#> {
#>   args <- lapply(as.list(match.call())[-1L], eval, parent.frame())
#>   names <- if (is.null(names(args))) 
#>     character(length(args))
#>   else names(args)
#>   dovec <- names %in% vectorize.args
#>   do.call("mapply", c(FUN = FUN, args[dovec], MoreArgs = list(args[!dovec]), 
#>                       SIMPLIFY = SIMPLIFY, USE.NAMES = USE.NAMES))
#> }
#> <environment: 0x10c72bd40>

# Application
vrep(1:2, 3:4)
#> [[1]]
#> [1] 1 1 1
#> 
#> [[2]]
#> [1] 2 2 2 2

# Naming arguments still works 
vrep(times = 1:2, x = 3:4)
#> [[1]]
#> [1] 3
#> 
#> [[2]]
#> [1] 4 4

# Vectorize() provides a convenient and concise notation to iterate over multiple arguments, 
# but has some major drawbacks that mean you generally shouldn't use if.
# See https://www.jimhester.com/2018/04/12/vectorize/ for more details.

# 2. Read the source code for `possibly()`. How does it work?

# `possibly()` modifies functions to return a specified default value in case of an error (otherwise)
# and to suppress any error messages (quiet = TRUE).

# While reading the source code, we notice that `possibley()` internally uses `purrr::as_mapper()`.
# This enables users to supply not only functions, but also formulas or atomics via the same syntax as known from other functions in the purrr package.
# Besides this, the new default value (otherwise) gets evaluated once to make it (almost)  immutable from now on.

# The main functionality of `possibly()` is provided by `base::tryCatch()`.
# In this part the supplied function (.f) gets wrapped and error and interrupt handling are specified.
possibly
#> function (.f, otherwise, quiet = TRUE) 
#> {
#>   .f <- as_mapper(.f)
#>   force(otherwise)
#>   function(...) {
#>     tryCatch(.f(...), error = function(e) {
#>       if (!quiet) 
#>         message("Error: ", e$message)
#>       otherwise
#>     }, interrupt = function(e) {
#>       stop("Terminated by user", call. = FALSE)
#>     })
#>   }
#> }
#> <bytecode: 0x106db8298>
#> <environment: namespace:purrr>

# 3. Read the source code for `safely()`. How does it work?

# `safely()` moidfies funcitons to return a list containing the elements "resutl" and "error".
# It works in a similar fashion as `possibly()` and besides using `as_mapper()`,
# `safely()` also provides the `otherwise` and `quiet` argument.
# However, in part of the implementation returns a list with the same structure in both cases.
# In the case of successful evaluation "error" eauals to `NULL` and in case of an error "result" equals to `otherwise`, which is `NULL` by default.

# As the `tryCatch()` part is hidden in the internal `purrr:::capture_output()` function, 
# we provide it here in addition to `safely()`:
safely
#> function (.f, otherwise = NULL, quiet = TRUE) 
#> {
#>   .f <- as_mapper(.f)
#>   function(...) capture_error(.f(...), otherwise, quiet)
#> }
#> <bytecode: 0x1071b7330>
#> <environment: namespace:purrr>

purrr:::capture_error
#> function (code, otherwise = NULL, quiet = TRUE) 
#> {
#>   tryCatch(list(result = code, error = NULL), error = function(e) {
#>     if (!quiet) 
#>       message("Error: ", e$message)
#>     list(result = otherwise, error = e)
#>   }, interrupt = function(e) {
#>     stop("Terminated by user", call. = FALSE)
#>   })
#> }
#> <bytecode: 0x106f0db98>
#> <environment: namespace:purrr>

# Take a look at the textbook or the documentation of safely() to see how you can take advantage fo this behaviour,
# for example when fitting many models.

# 11.3 Case stydy: Creating your own function operators

# `meomoise()` and `safely()` are very useful but also quite complex.
# In this case study you'll learn how to create your own simpler function operators.
# Imagine you have a named vector of URLs and you'd like to download each one to disk.
# That's pretty simple with `walk2()` and `file.download()`:

urls <- c(
  "adv-r" = "https://adv-r.hadley.nz", 
  "r4ds" = "http://r4ds.had.co.nz/"
  # and many many more
)

path <- paste(tempdir(), names(urls), ".html")

walk2(urls, path, download.file, quiet = TRUE)

# This approach is fine for a handful of URLs, but as  the vector gets longer, 
# you might want to add a couple more features:

# - Add a smell delay between each request to avoid hammering the server.

# - Display a `.` every few URLs to that we know that the function is still working.

# It's relatively wasy to add these extra features if we're using a for loop:
for (i in seq_along(urls)) {
  Sys.sleep(0.1)
  if (i %% 10 == 0) cat(".")
  download.file(urls[[i]], path[[i]])
}

# I think this for loop is suboptimal because it interleaves different concerns:
# pausing showing progress, and downloading.
# This makes the code harder to read, and it makes it harder to reuse the componenets in new situations.
# Instead, let's see if we can use function operators to extract out pausing and showing progress adn make them reuseable.

# First, let's write an function operator that adds a small delay.
# I'm going to call it `delay_by()` for reasons that will be ore clear shortly,
# and it has two arguments: the function to wrap, and the amount of delay to add.
# The actual implementation is quite simple.
# The main trick is forcing evaluation of all arguments as described in Section 10.2.5,
# because function operators are a speciall type of function factory:

delay_by <- function(f, amount) {
  force(f)
  force(amount)
  
  function(...) {
    Sys.sleep(amount)
    f(...)
  }
}

system.time(runif(100))
#>  user  system elapsed 
#> 0.001   0.000   0.000
system.time(delay_by(runif, 0.1)(100))
#>  user  system elapsed 
#> 0.001   0.001   0.101

# And we can use it with the original `walk2()`:
walk2(urls, path, delay_by(download.file, 0.1), quiet = TRUE)

# Creating a function to display the occasional dot is a little harder, 
# because we can no loger rely on the index from the loop.
# We could pass the index along as another argument,
# but the breaks encapsulation: 
# a concern of the prgress function now becomes a problem that the higher level wrapper needs to hadle.
# Instead, we'll use another function trick (from Section 10.2.4),
# so that the progress wrapper can manage its own internal counter:
dot_every <- function(f, n) {
  force(f)
  force(n)
  
  i <- 0
  function(...) {
    i <<- i + 1
    if (i %% n == 0) cat(".")
    f(...)
  }
}
walk(1:100, runif)
walk(1:100, dot_every(runif, 10))

# Now we can express our original for loop as:
walk2(
  urls, path,
  dot_every(delay_by(download.file, 0.1), 10),
  quiet = TRUE
)

# This is starting to get a little hard to read because we are composing many funciton calls, 
# and the arguments are getting spread out.
# One way to resolve that is to use the pipe.

walk2(
  urls, path,
  download.file %>% dot_every(1) %>% delay_by(0.1),
  quiet = TRUE
)

# This pipe works well here because I've carefull chosen the function names to yield an (almost) readable sentence:
# take `download.file` then (add) a dot every 10 iterations, then delay by 0.1s.
# The more clearly you can express the intent of your code through functino names, the more easily others (including future you!)
# can read and understand the code.

# 11.3.1 Exercises

# 1. Weigh the pros and cons of `soenload.file %>% dot_every(10) %>% delay_by(0.1)` versus
#    `download.file %>% delay(0.1) %>% dot_every(10)`.



# 2. should you memoise `file.download()`? Why or why not?

# Memoising `file.download()` will only work if the files are immutable;
# i.e. if the file at a given url is always same. 
# There's no point memoising unless this is true.
# Even if this is true, however, memoise has to store the results in memory,
# and large files will potentially take up a lot of memory.

# This implies that it's probably not beneficial to memorise `file.download()` in most cases.
# The only exception is if you are downloading small files many times, 
# and the file at a given url is graranteed not to change.

# 3. Create a function operator that reports whenever a file is created or deleted in the working directory,
#    using `dir()` and `setidff()`. What other global function effects might you want to track?

# We first start with a functino that simply reports the difference between two vectors of files:
dir_compare <- function(old, new) {
  if (setequal(old, new)) {
    return()
  }
  
  added <- setdiff(new, old)
  removed <- setdiff(old, new)
  
  changes <- c(
    if (length(added) > 0) paste0(" * '", added, "' was added"),
    if (length(removed) > 0) paste0(" * '", removed, "' was removed")
  )
  message(paste(changes, collapse = "\n"))
}

dir_compare(c("x", "y"), c("x", "y"))
#> NULL
dir_compare(c("x", "y"), c("x", "a"))
#> * 'a' was added
#> * 'y' was removed

# Then we wrap it up in a function operator
track_dir <- function(f) {
  force(f)
  function(...) {
    dir_old <- dir()
    on.exit(dir_compare(dir_old, dir()), add = TRUE)
    
    f(...)
  }
}

# And try it out by creating wrappers around `file.create()` and `file.remove()`:
file_create <- track_dir(file.create)
file_remove <- track_dir(file.remove)

file_create("delect_me")
#> * 'delect_me' was added
#> [1] TRUE
file_remove("delect_me")
#> * 'delect_me' was removed
#> [1] TRUE

# To create a more serious version of `track_dir()` on emight provide optionality to set the `full.naems` and `recursive` arguments of `dir()` to TRUE.
# This would enable to also track the creation/deletion of hidden files and files in folders contained in the wroking directory.

# Other global effects that might be worth tracking include changes regarding:

# - the search path and possibly introuced `condlicts()`
# - `options()` and `par()` which modify global settings
# - the path of the working directory
# - environment variables

# 4. Write a function operator that logs a timestamp and message to a file every tiem a function is run.

append_line <- function(path, ...) {
  cat(..., "\n", sep = "", file = path, append = TRUE)
}
logger <- function(f, log_path) {
  force(f)
  force(log_path)
  
  append_line(log_path, "created at: ", as.character(Sys.time()))
  function(...) {
    append_line(log_path, "called at: ", as.character(Sys.time()))
    f(...)
  }
}


log_path <- tempfile()
mean2 <- logger(mean, log_path)
mean2(1:4)
Sys.sleep(1)
mean2(1:4)

readLines(log_path)

# 5. Modify `delay_by()` so that instead of delaying by a fixed amount of time,
#    it ensures that certain amount of time has elapsed since the function was last called.
#    That is, if you called `g <- delay_by(1, f); g(); Sys.sleep(2); g()` 
#    there shouldn't be an extra delay.

# We can do this with three little tricks (and the help of 42):
delay_atleast <- function(f, amount) {
  force(f)
  force(aount)
  
  # Store the last time the function was run
  last_time <- NULL
  
  function(...) {
    if (!is.null(last_time)) {
      wait <- (last_time - Sys.time()) + amount
      if (wait > 0) {
        Sys.sleep(wait)
      }
    }
    on.exit(last_time <<- Sys.time())
    
    f(...)
  }
}
