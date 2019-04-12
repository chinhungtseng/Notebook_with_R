# 21 Iteration

# 21.1 Introduction

# In funcitons, we talked about how important it is to reduce duplication in your code by creating funcitons instead of copying-and-pasting.
# Reducing code duplication has three main benefits:
# 1. It's easier to the intent of your code, because your eyes are drawn to what's different, not what stays the same.
# 2. It's easier to respond to changes in requirements. As your need change, you only need to make changes in one place, 
#    rather than remembering to change every place that you copied-and-pasted the code.
# 3. You're likely to have fewer bugs because each line of code is used in more places.

# One tool for duplication is functions, which reduce duplication by identifying repeated patterns of code 
# and extract them out into independent pieces that can be easily reused and update.
# Another tool for reducing duplication is iteration, which helps you when you need to do the same thing to multiple inputs:
# repeating the same operation on different columns, or on different datasets.
# In this chapter you'll learn about two important iteration paradigms: imperative programming and functional programming.
# On the imperative side you have tools like for loops and while loops, which are a great place to start because they make iteration very explicit,
# so it's ovious what's happening.
# However, for loops are quite verbose, and require quite a bit of bookkeeping code that is duplicated for every for loop.
# Functional programming(FP) offers tools to extract out that is duplicated code, so each common for loop pattern gets its own funciton.
# Once you master the vocabulary of FP, you can solve many common iteration problems with less code, more ease, and fewer errors.

# 21.1.1 Prerequisites

# Once you've mastered the for loops provided by base R, you'll learn some of the powerful programming tools provided by purrr,
# one of the tidyverse core packages.
library(tidyverse)

# 21.2 For loop

# Imagine we have this simple tibble:
df <- tibble(
  a = rnorm(10), 
  b = rnorm(10), 
  c = rnorm(10), 
  d = rnorm(10)
)

# We want to compute the median of each column. You could do with copy-and paste:
median(df$a)
median(df$b)
median(df$c)
median(df$d)

# But that break our rule of thumb: never copy and paste more than twice. Instead, we could use a for loop:
output <- vector("double", ncol(df)) # 1. output
for (i in seq_along(df)) {           # 2. sequence
  output[[i]] <- median(df[[i]])     # 3. body
}
output

# Every for loop has three components;
# 1. The output: output <- vector("double", length(x)). Before you start the loop, you must always allocate sufficient space for the output.
#    This is very important for efficiency: if you grow the for loop at each iteration using c() (for example), your for loop will be very slow.

#    A general way of creating an empty vector of given length is the vector() function.
#    It has two arguments: the type of the vector("logical", "integer", "double", "cahtacter", etc) and the length of the vector. 

# 2. The sequence: i in seq_along(df). This determines what to loop over: each run of the for loop will assign i to a different value from seq_along(df).
#    It's useful to think of i as a pronoun, like "it".

#    You might not have seen seq_along() before. it's a safe version of the familiar 1:length(l), with an important diffenence: 
#    if you have a zero-length vector, seq_along() does the right thing: 
y <- vector("double", 0)
seq_along(y)
1:length(y)

#    You probably won't create zero-length vector deliberately, but it's easy to create them accidentally.
#    If you use 1:length(x) instead of seq_along(x), you're likely to get a condusion error message.

# 3. The body: output[[i]] <- median(df[[i]]). This is the code that does the work.
#    It's run repeatedly, each time with a different value for i.
#    The first iteration will run output[[1]] <- median(df[[1]]), the second will run output[[2]] <- median(df[[2]]), and so on.

# That's all there is to the for loop! Now is a good time to practice creating some besic(and not so basic) for using the exercises below.
# Then we'll move on some variations of the for loop that help you solve other problems that will crop up in practice.

# 21.2.1 Exercises

# 1. Write for loops to:
#    (1) Compute the mean of every column in mtcars.
#    (2) Determine the type of each column in nycflights13::flights.
#    (3) Compute the number of unique values in each column of iris.
#    (4) Generate 10 random normals for each of µ = -10, 0, 10, and 100.
#    think about the output, sequence, and body before you start writing the loop.

## (1) Compute the mean of every column in mtcars.
mtcars_col_mean <- vector("double", ncol(mtcars))
names(mtcars_col_mean) <- names(mtcars)
for (i in seq_along(col_mean)) {
  mtcars_col_mean[[i]] <- mean(mtcars[[i]])
}
mtcars_col_mean

## (2) Determine the type of each column in nycflights13::flights.
flights_col_type <- vector("list", ncol(nycflights13::flights))
names(flights_col_type) <- names(nycflights13::flights)
for (i in seq_along(flights_col_type)) {
  flights_col_type[[i]] <- typeof(nycflights13::flights[[i]])
}
flights_col_type

## (3) Compute the number of unique values in each column of iris.
unique_number <- vector("double", ncol(iris))
names(unique_number) <- names(iris)
for (i in seq_along(unique_number)) {
  unique_number[[i]] <- n_distinct(iris[[i]])
}
unique_number

## (4) Generate 10 random normals for each of µ = -10, 0, 10, and 100.
n <- 10 
mu <- c(-10, 0, 10, 100)
normals <- vector("list", length(mu))
for (i in seq_along(normals)) {
  normals[[i]] <- rnorm(n, mean = mu[i])
}
normals

# 2. Eliminate the for loop each of the following examples by taking advantage of an existing function that works with vectors:
# (1)
out <- ""
for (x in letters) {
  out <- stringr::str_c(out, x)
}
## (1)
stringr::str_c(letters, collapse = "")

# (2)
x <- sample(100)
sd <- 0
for (i in seq_along(x)) {
  sd <- sd + (x[i] - mean(x)) ^ 2
}
sd <- sqrt(sd / (length(x) - 1))
## (2)
sd(x)
sqrt(sum((x - mean(x)) ^ 2) / (length(x) -1))

# (3)
x <- runif(100)
out <- vector("numeric", length(x))
out[1] <- x[1]
for (i in 2:length(x)) {
  out[i] <- out[i - 1] + x[i]
}
## (3)
cumsum(x)

# 3. Combine your funciton writing and for loop skills:
#    (1) Write a for loop that prints() the lyrics to the children's song "Alice the camel".
#    (2) Convert the nursery rhyme "ten in the bed" to a function. Generalise it to any number of people in any sleeping structure.
#    (3) Convert the song "99 bottles of beer on the wall" to a function. Generalise to any number of any vessel containing any liquid on any surface.

## (1)
humps <- c("five", "four", "three", "two", "one", "no")
for (i in humps) {
  writeLines(str_c("Alice the camel has ", rep(i, 3), " humps."))
  if (i == "no") {
    cat("Now Alice is a horse.")
  } else {
    cat("So go, Alice, go.\n")
  }
  cat("\n")
}

## (2)
ten_in_the_bed <- function(x) {
  x <- (11 - x):10
  n <- c("ten", "nine", "eigth", "seven", "six", "five", "four", "three", "two", "one")
  
  s <- n[x]
  
  for (i in s) {
    cat(str_c("There were ", i, " in the bed\n",
              "And the little one said,\n"))
    if (i == "one") {
      cat("Alone at last!\n")
    } else {
      cat(str_c("\"Roll over! Roll over!\"\n",
                "So they rolled over and one fell out\n"))
    }
    cat("\n")
  }
}
ten_in_the_bed(2)


## (3)
bottles <- c(99:1, "no more")

for (i in seq_along(bottles)) {
  cat(str_c(bottles[i], " bottles of beer on the wall, ", bottles[i], " bottles of beer.\n"))
  if (bottles == "no") {
    cat(str_c("Go to the store and buy some more, ", bottles[((i + 1) %% 100)], " bottles of beer on the wall.\n"))
  } else {
    cat(str_c("Take one down and pass it around, ", bottles[((i + 1) %% 100)], " bottles of beer on the wall.\n"))
  }
  cat("\n")
}

# 4. It's common to see for loops that don't preallocate the output and instead increase the length of a vector at each step:
output <- vector("integer", 0)
for (i in seq_along(x)) {
  output <- c(output, lengths(x[[i]]))
}
output
#    How does this affect performance? Design and execute an experiment.

test1 <- function(x) {
  output <- vector("integer", 0)
  for (i in seq_along(x)) {
    output <- c(output, lengths(x[[i]]))
  }
  output
}

test2 <- function(x) {
  output <- vector("integer", length(x))
  for (i in seq_along(x)) {
    output <- c(output, length(x[[i]]))
  }
  output
}

microbenchmark::microbenchmark(
  no_allocate = test1(1:10000),
  with_allocate = test2(1:10000),
  times = 3
)
## with_allocate is 3 times faster than no_allocate

# 21.3 For loop variations 

# Once you have the basic for loop under your belt, there are some variations that you should be aware of.
# These variations are important regardless of how you do iteration, 
# so don't forget about them once you've mastered the FP techniques you'll learn about in the next section.

# There are four variations on the basic theme of the for loop:
# 1. Modifying an existing object, instead of creating a new object.
# 2. Looping over names or values, instead of indices.
# 3. Handling outputs of unknown length.
# 4. Handling sequences of unknown length.

# 21.3.1 Modifying an existing object

# Sometimes you want to use a for loop to modify an existing object.
# For exampe, remember our challenge from functions. We wanted to rescale every column in a data frame:
df <- tibble(
  a = rnorm(10), 
  b = rnorm(10), 
  c = rnorm(10), 
  d = rnorm(10)
)
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)

# To solve this with a for loop we again think about the three components:
# 1. Output: we already have the output - it's the same as the input!
# 2. Sequence: we can think about a data frame as a list of columns, so we can iterate over each column with seq_along(df).
# 3. Body: apply rescale01()

# This gives us:
for (i in seq_along(df)) {
  df[[i]] <- rescale01(df[[i]])
}

# Typically you'll be modifying a list or data frame with this sort of loop, so remember to use [[, not [.
# You might have spotted that I use [[ in all my for loops:
# I think it's better to use [[ even for atomic vectors because it makes it clear that I want to work with a single element.

# 21.3.2 Looping patterns

# There are three basic ways to loop over a vector. So far I've shown you the most general: 
# looping over the numeric indices with for (i in seq_along(xs)), and extracting the value with x[[i]].
# There are two other forms:
# 1. Loop over the elements: for (x in xs). This is most useful if you only care about side-effects, like plotting or saving a file, 
#    because it's difficult to save the output efficiently.
# 2. Loop over the names: for (nm in names(xs)). This gives you name, which you can use to access the value with x[[nm]].
#    This is useful if you want to use the name in a plot title or a file name.
#    If you're creating named output, make sure to name the results vector like so:
results <- vector("list", length(x))
names(results) <- names(x)

# Iteration over the numeric indices is the most general form, because given the position you can extract both the name and the value:
for (i in seq_along(x)) {
  name <- names(x)[[i]]
  value <- x[[i]]
}

# 21.3.3 Unknown output length

# Sometimes you might not know how long the output will be.
# For example, imagine you want to simulate some random vectors of random lengths.
# You might be tempted to solve this problem by progressively growing the vector:
means <- c(0, 1, 2)

output <- double()
for (i in seq_along(means)) {
  n <- sample(100, 1)
  output <- c(output, rnorm(n, means[[i]]))
}
str(output)

# But this is not efficient because in each iteration, R has to copy all the data from the previous iterations.
# In technical terms you get "quadratic" (O(n)^2)) behaviour which means that a loop with three times as many elements would take nine (3^2) times as long to run.

# A better solution to save the results in a list, and then combine into a single vector after the loop is done:
out <- vector("list", length(means))
for (i in seq_along(means)) {
  n <- sample(100, 1)
  out[[i]] <- rnorm(n, means[[i]])
}
str(out)
str(unlist(out))

# Have I've used unlist() to flatten a list of vectors into a single vector.
# A stricter option is to use purrr::flatten_dbl() - it will throw an error if the input isn't a list of doubles.
# This pattern occurs in other places too:
# 1. You might be generating a long string. Instead of paste()ing together each iteration with the previous,
#    save the output in a character vector and then combine that vector into a single string with paste(output, collapse = ").
# 2. You might be generating a big data frame. Instead of sequentially rbind()ing in each iteration, 
#    save the output in a list, then use deplyr::bind_rows(output) to combine the output into a single date frame.

# Watch out for this pattern. Whenever you see it, switch to a more complex result object, and then combine in one step at the end.

# 21.3.4 Unknown sequence length

# Sometimes you don't even know how long the input sequence should run for. This is common when doing simulations.
# For example, you might want to loop until you get three heads in a row.
# You can't do that sort of iteration with the for loop. Instead, you can use a while loop.
# A while loop is simpler than for loop because it only has two components, a condition and a body:
while (condition) {
  # body
}
# A while loop is also more general than a for loop, because you can rewrite any for loop as a while loop, but you can't rewrite every while loop as a for loop:
for (i in seq_along(x)) {
  # body
}

# Equivalent to 
i <- 1
while (i <= length(x)) {
  # body
  i <- i +1
}

# Here's how we could use a while loop to find how many tries it takes to get three heads in a row:
flip <- function() sample(c("T", "H"), 1)

flips <- 0
nheads <- 0

while (nheads < 3) {
  if (flip() == "H") {
    nheads <- nheads + 1
  } else {
    nhead <- 0
  }
  flips <- flips + 1
}
flips

# I mention while loops only briefly, because I hardly ever use them.
# they're most often used for simulation, which is outside the scope of this book.
# However, it is good to know they exist so that you're prepared for problems where the number of iterations is not know in advance.

# 21.3.5 Exercises

# 1. Imagine you have a directory full of CSV files that you want to read in. 
#    You have their paths in a vector, files <- dir("data/", pattern = "\\.csv$", full.names = TRUE),
#    and now want to read each one with read_csv().
#    Write the for loop that will load them into a single data frame.
file_list <- dir("data/", pattern = "\\.csv$", full.names = TRUE)
df <- vector("list", length(file_list))
for (i in seq_along(df)) {
  df[[i]] <- read_csv(file_list[[i]])
}
df

# 2. What happens if you use for (nm in names(x)) and x has no names? 
#    What if only some of the elements are named? What if the names are not unique?
## (1) When there are no any names in a vector, it does not run the cade.
x <- 1:10
names(x) # NULL

for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}

## (2) If we only have some naems in a vector. we will get an error.
x <- c(a = 1, b = 2, 3)
names(x)
for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}

## (3) 
x <- c(a = 1, b = 2, b = 3)
names(x)
for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}

# 3. Write a function that prints the mean of each numeric column in a data frame, along with its name.
#    For example, show_mean(iris) would print:
show_mean(iris)
#> Sepal.Length: 5.84
#> Sepal.Width:  3.06
#> Petal.Length: 3.76
#> Petal.Width:  1.20
# (Extra challenge: what function did I use to make sure that the numbers lined up nicely,
# even though the variable names had different lengths?)

show_mean <- function(df, digits = 2) {
  # find max length of df name.
  nm_max_length <- max(str_length(names(df)))
  
  for (nm in names(df)) {
    # check whether the colums type, if is numeric, then continue.
    if(is.numeric(df[[nm]])){
      cat(
        # set the column names as the same length
        str_pad(str_c(nm, ":"), width = (nm_max_length + 1), side = "right"),
        # calculate the mean of numeric column.
        format(mean(df[[nm]], na.rm = TRUE), digits = digits, nsmall = digits),
        "\n")
    }
  }
}
show_mean(iris)

# 4. What does this code do? How does it work?
trans <- list( 
  disp = function(x) x * 0.0163871,
  am = function(x) {
    factor(x, labels = c("auto", "manual"))
  }
)
for (var in names(trans)) {
  mtcars[[var]] <- trans[[var]](mtcars[[var]])
}

## This code will compute and convert value at the columns of disp and am.
## The list of trans stores two function:
## 1. disp: is multiplied by 0.0163871.
## 2. am: convert (0,1) to (auto, manual) factor.

# 21.4 For loops vs.functionals

# For loops are not as important in R as they are in other languages because R is a functional programming language.
# This means that it's possible to wrap up for loops in a function, and call that function instead of using the for loop directly.

# To see why this is important, consider(again) this simple data frame:
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# Imagine you want to compute the mean of every column. You could do that with a for loop:
output <- vector("double", length(df))
for (i in seq_along(df)) {
  output[[i]] <- mean(df[[i]])
}
output

# You realise that you're going to want to compute the means of every column pretty frequently, 
# so you extract it into a function:
col_mean <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[[i]] <- mean(df[[i]])
  }
  output
}

# But then you think it's also be helpful to be able to compute the median, and the standard deviation, 
# so you copy and paste your col_mean() function and replace the mean() with median() and sd():
col_median <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- median(df[[i]])
  }
  output
}
col_sd <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- sd(df[[i]])
  }
  output
}

# Uh oh! You've copied-and-pasted this code twice, so it's time to think about how to generalise it.
# Notice that most of this code is for-loop boilerplate and it's hard to see the one thing
# (mean(), median(), sd()) that is different between the functions.

# What would you do if you saw a set of functions like this:
f1 <- function(x) abs(x - mean(x)) ^ 1
f2 <- function(x) abs(x - mean(x)) ^ 2
f3 <- function(x) abs(x - mean(x)) ^ 3

# Hopefully, you'd notice that there's a lot of duplication, and extract it out into an additional argument:
f <- function(x, i) ags(x - mean(x)) ^ i

# You're reduced the chance of bugs(because you now have 1/3 of the original code),
# and made it easy to generalise to new situations.

# We can do exactly the same thing with col_mean(), col_median() and col_sd() by adding an argument 
# that supplies the function to apply to each column:
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}
col_summary(df, mean)
col_summary(df, median)

# The idea of passing a function to another function is extremely powerful idea, 
# and it's one of the behavours that makes R a functional programming language.
# It might take you a while to wrap your head around the idea, but it's worth to investment.
# In the rest of the chapter, you'll learn about and use the purrr package, 
# which provides functions that eliminate the need for many common for loops.
# The apply family of functions in base R (apply(), lapply(), tapply(), etc) solve a similar problem,
# but purrr is more consistent and thus is easier to learn.

# The goal of using usrrr funcitons instead of for loops is to allow you break common list manipulation challenges into independent pieces:
# 1. How can you solve the problem for a single element of the list? Once you've solved that problem,
#    purrr takes care of generalising your solution to every element in the list.
# 2. If you're solving a complex problem, how can you break it down into bite-sized pieces that allow you to advance one small step towards a solution?
#    With purrr, you get lots of small pieces that you can compose together with the pipe.

# This structure makes it easier to solve new problems. 
# It also makes it easier to understand your solutions to old problems when you re-read your old code.

# 21.4.1 Exercises

# 1. Read the documentation for apply(). In the 2d case, what two for loop does it generalise?
?apply
## Returns a vector or array or list of values obtained by applying a function to margins of an array or matrix.

## apply(X, MARGIN, FUN, ...)

## X - an array, including a matrix.
## MARGIN - a vector giving the subscripts which the function will be applied over. E.g., 
##          for a matrix 1 indicates rows, 2 indicates columns, c(1, 2) indicates rows and columns. 
##          Where X has named dimnames, it can be a character vector selecting dimension names.
## FUN - the function to be applied: see ‘Details’. In the case of functions like +, %*%, etc., 
##       the function name must be backquoted or quoted.
## ... - optional arguments to FUN.

# 2. Adapt col_summary() so that it only applies to numeric columns.
#    You might want to start with an is_numeric() function that a logical vector that has a TRUE corresponding to each numeric column.
## Create a test sample df1
df1 <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = letters[1:10]
)

col_summary2 <- function(df, fun) {
  num <- vector("logical", length(df))
  for (i in seq_along(df)) {
    num[[i]] <- is.numeric(df[[i]])
  }
  out <- vector("double", length(df[num]))
  for (i in seq_along(df[num])) {
    names(out) <- names(df[num])
    out[[i]] <- fun(df[num][[i]])
  }
  out
}
col_summary2(df1, sum)

## rewrite the col_summary2():
col_summary2 <- function(df, f) {
  is_num <- df[, map_lgl(df, is.numeric)]
  output <- vector("double", length(is_num))
  for (i in seq_along(is_num)) {
    output[[i]] <- f(is_num[[i]])
  }
  output
}
col_summary2(iris, mean)

# 21.5 The map functions 

# The pattern of looping over a vector, doing something to each element and saving the results 
# is so common that the purrr package provides a family of functions to do it for you.
# There is one funciton for each type of output:
# 1. map() makes a list.
# 2. map_lgl() makes a logical vector.
# 3. map_int() makes an integer vector.
# 4. map_dbl() makes a double vector.
# 5. map_chr() makes a character vector.

# Each function takes vector as input, applies a function to each piece, and then returns a new vector that's the same length
# (and has the same names) as the input.
# The type of the vector is determined by the suffix to the map function.

# Once you master these functions, you'll find it takes much less time to slove iteration problems.
# But you should never feel bad about using a for loop instead of a map function.
# The map functions are a step up a tower of abstraction, and it can take a long time to get your head around how they work.
# The important thing is that you solve the problem that you're working on, not write the most concise and elegant code
# (although that's definitely somthing you want to strive towards!).

# Some people will tell you to avoid for loops because they are slow. They're wrong!
# (Well at least they're rather out of date, as for loops haven't been slow for many years).
# The chief benefits of using functions like map() is not speed, but clarity:
# they make your code easier to write and to read.

# We can use these functions to perform the same computations as the last for loop.
# Those summmry functions returned doubles, so we need to use map_dbl():
map_dbl(df, mean)
map_dbl(df, median)
map_dbl(df, sd)

# Compared to using a for loop, focus is on the operation being performed (i.e. mean(), median(), sd()),
# not the bookkeeping required to loop over every element and store the output.
# This is even more apparent if we use the pipe:
df %>% map_dbl(mean)
df %>% map_dbl(median)
df %>% map_dbl(sd)

# There are a few different between map_*() and col_summary():
# 1. All purrr functions are implemented in C. This makes them a little faster at the expense of readability.
# 2. The second argument, .f, the function to apply, can be a formula, a character vector, or an integer vector.
#    You'll learn about those handy shortcuts in the next seciton.
# 3. map_*() uses ... ([dot dot dot]) to pass along additional arguments to .f each time it's called:
map_dbl(df, mean, trim = 0.5) ## trimed mean in R:(http://f.dataguru.cn/thread-56414-1-1.html)
# 4. The map functions also preserve names:
z <- list(x = 1:3, y = 4:5)
map_int(z, length)

# 21.5.1 Shortcuts

# There are a few shortcuts that you can use with .f in order to save a little typing.
# Imagine you want to fit a linear model to each group in a dataset.
# The following toy example splits the up the mtcars dataset into three pieces
# (one for each value of cylinder) and fits the same linear model to each piece:
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(function(df) lm(mpg ~ wt, data = df))

# The syntax for creating an anonymous function in R is quite verbose so purrr provides a convenient shortcut: a one-side formula.
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(~lm(mpg ~ wt, data = .))

# Here I've used . as a pronoun: it refers to the current list element(in the same way that I referred to the current index in the for loop).

# When you're looking at many models, you might want to extract a summary statistic like the R^2 (R Squared).
# To do that we need to first run summary() and then extract the component called r.squared.
# We could do that using the shorthand for anonymous functions:
models %>% 
  map(summary) %>% 
  map_dbl(~.$r.squared)

# But extracting named components is a common operation, so purrr provides an even shorter shortcut:
# you can use a string.
models %>% 
  map(summary) %>% 
  map_dbl("r.squared")

# You can also use an integer to select elements by position:
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))
x %>% map_dbl(2)

# 21.5.2 Base R

# If you're familiar with the apply family of functions in base R, you might have noticed some similarities with the purrr functions:
# 1. lapply() is basically identical to map(), except map() is consistent with all the other functions in purrr,
#    and you can use the shortcuts for .f.
# 2. Base sapply() is a wrapper around lapply() that automatically simplifies the output.
#    This is useful for interacive work but is problematic in a function because you never know what sort of output you'll get:
x1 <- list(
  c(0.27, 0.37, 0.57, 0.91, 0.20),
  c(0.90, 0.94, 0.66, 0.63, 0.06), 
  c(0.21, 0.18, 0.69, 0.38, 0.77)
)
x2 <- list(
  c(0.50, 0.72, 0.99, 0.38, 0.78), 
  c(0.93, 0.21, 0.65, 0.13, 0.27), 
  c(0.39, 0.01, 0.38, 0.87, 0.34)
)

threshold <- function(x, cutoff = 0.8) x[x > cutoff]
x1 %>% sapply(threshold) %>% str()
x2 %>% sapply(threshold) %>% str()

# 3. vapply() is a safe alternative to sapply() because you supply an additional argument that defines the type.
#    The only problem with vapply() is that it's a lot of typing: vapply(df, is.numeric, logical(1)) is equivalent to map_lgl(df, is.numeric).
#    One advantage of vapply() over purrr's map functions is that it can also produce matrices - the map functions only ever produce vectors.

# I focus on purrr functions here because they have more consistent names and arguments, helpful shortcuts, 
# and in the future will provide easy parallelism and progress bars.

# 21.5.3 Exercises

# 1. Write code that uses one of the map functions to:
#    (1) Compute the mean of every column in mtcars.
#    (2) Determine the type of each column in nycflights13::flights.
#    (3) Compute the number of unique values in each column of iris.
#    (4) Generate 10 random normals for each of µ = -10, 0, 10, and 100.
mtcars %>% str()

## (1) Compute the mean of every column in mtcars.
mtcars %>% 
  map_dbl(mean, na.rm = TRUE)
apply(mtcars, 2, mean)
lapply(mtcars, mean) %>% unlist()

## (2) Determine the type of each column in nycflights13::flights.
nycflights13::flights %>% 
  map(typeof)

lapply(nycflights13::flights, typeof)

df_summary <- function(df, fun) {
  out <- vector("character", length(df))
  names(out) <- names(df)
  for(i in seq_along(out)) {
    out[[i]] <- fun(df[[i]])
  }
  out
}
df_summary(nycflights13::flights, typeof)

microbenchmark::microbenchmark(
  map_test <- nycflights13::flights %>% map_chr(typeof),
  lapply_test <- lapply(nycflights13::flights, typeof),
  for_loop_test <- df_summary(nycflights13::flights, typeof),
  times = 3
)

## (3) Compute the number of unique values in each column of iris.
iris %>% map_int(n_distinct)

iris %>% apply(2, n_distinct)

df_summary(iris, n_distinct)

## (4) Generate 10 random normals for each of µ = -10, 0, 10, and 100.
c(-10, 0, 10, 100) %>% map(~ rnorm(n = 10, mean = .))

# 2. How can you create a single vector that for each column in a data frame indicates whether or not it's a factor?
diamonds %>% map_lgl(is.factor)

# 3. What happens when you use the map functions on vectors that aren't lists?
#    What does map(1:5, runif) do? Why?
map(1:5, runif)

## The result looks like the code below, map(1:5, runif) will run runif(1) to runif(5), and the output is a list.
list(
  runif(1),
  runif(2),
  runif(3),
  runif(4),
  runif(5)
)

# 4. What does map(-2:2, rnorm, n = 5) do? Why? What does map_dbl(-2:2, rnorm, n = 5) do? Why?
map(-2:2, rnorm, n = 5)
## This code will create the vector of mean = -2, -1, 0, 1, 2, and 5 observations each vector.

map_dbl(-2:2, rnorm, n = 5)
## The return value of .f must be of length one for each element of .x.

# 5. Rewrite map(x, function(df) lm(mpg ~ wt, data = df)) to eliminate the anonymous funciton.
x <- split(mtcars, mtcars$cyl)
map(x, function(df) lm(mpg ~ wt, data = df))

map(x, ~lm(mpg ~ wt, data = .))

# 21.6 Dealing with failure 

# When you use the map functions to repeat many operations, the chances are much higher that one of those operations will fail.
# When this happens, you'll get an error message, and no output.
# This is annoying: why does one failure prevent you from accessing all the other successes?
# How do you ensure that one bad apple doesn't ruin the whole barrel?

# In this section you'll learn how to deal this situation with a new function: safely().
# safely() is an adverb: it takes a funciton(a verb) and returns a modified version. 
# In this case, the modified funciton will never throw an error. Instead, it always returns a list with two elements:
# 1. result is the original result. If there was an error, this will be NULL.
# 2. error is an error object. If the operation was successful, this will be NULL.

# (You might be familiar with the try() function in base R. It's similar, 
# but because it sometimes returns the original result and it sometimes returns an error object it's more difficult to work with.)

# Let's illustrate this a simple example: log():
safe_log <- safely(log)
str(safe_log(10))
safe_log("a")

# When the function succeeds, the result element contains the result and the error element is NULL.
# When the function fails, the result element is NULL and the error element contains an error object.
# safely() is designed to work with map:
x <- list(1, 10, "a")
y <- x %>% map(safely(log))
str(y)

# This would be easier to work with if we had two lists: one of all the errors and one of all the output.
# That's easy to get with purrr::transpose():
y <- y %>% transpose()
str(y)

# It's up to you how to deal with the errors, but typically you'll either look at the values of x where y is an error, 
# or work with the values of y that are ok:
is_ok <- y$error %>% map_lgl(is_null)
x[!is_ok]

y$result[is_ok] %>% flatten_dbl()

# Purrr provides two other useful adverbs:
# 1. Like safely(), possibly() always succeeds. 
#    It's simpler than safely(), because you give it a default value to return when there is an error.
x <- list(1, 10, "a")
x %>% map_dbl(possibly(log, NA_real_))

# 2. quietly() performs a similar role to safely(), but instead of capturing errors, 
#    it captures printed output, messages, and warnings:
x <- list(1, -1)
x %>% map(quietly(log)) %>% str()

# 21.7 Mapping over multiple arguments

# So far we've mapped along a single input. But often you have multiple related inputs that you need iterate along in parallel.
# That's the job of the map2() and pmap() functions.
# For example, imagine you want to simulate some random normals with different means.
# You know how to do that with map():
mu <- list(5, 10, -3)
mu %>% 
  map(rnorm, n = 5) %>% 
  str()

# What if you also want to vary the standard deviation? 
# One way to do that would be to iterate over the indices and index into vectors of means and sds:
sigma <- list(1, 5, 10)
seq_along(mu) %>% 
  map(~rnorm(5, mu[[.]], sigma[[.]])) %>% 
  str()

# But that obfuscates the intent of the code. Instead we could use map2() which iterates over two vectors in parallel:
map2(mu, sigma, rnorm, n = 5) %>% str()

# map2() generates this series of function calls:
#     mu        sigma     map2(mu, sigma, rnorm, n = 5)
# /-------\   /-------\   /--------------------------\
# | |---| |   | |---| |   | |----------------------| |
# | | 5 | |   | | 1 | |   | | rnorm(5, 1, n = 5)   | |
# | |---| |   | |---| |   | |----------------------| |
# |       |   |       |   |                          |
# | |---| |   | |---| |   | |----------------------| |
# | |10 | |   | | 5 | |   | | rnorm(10, 5, n = 5)  | |
# | |---| |   | |---| |   | |----------------------| |
# |       |   |       |   |                          |
# | |---| |   | |---| |   | |----------------------| |
# | |-3 | |   | |10 | |   | | rnorm(-3, 10, n = 5) | |
# | |---| |   | |---| |   | |----------------------| |
# \-------/   \-------/   \--------------------------/

# Note that the arguments that vary for each call come before the function; arguments that are the same for every call come after.

# Like map(), map2() is just a wrapper ardound a for loop:
map2 <- function(x, y, f, ...) {
  out <- vector("list", length(x))
  for (i in seq_along(x)) {
    out[[i]] <- f(x[[i]], y[[i]])
  }
  out
}
map2

# You can also imagine map3(), map4(), map5(), map6() etc, but that would get tedious quickly.
map3 <- function(x, y, z, f, ...) {
  out <- vector("list", length(x))
  for (i in seq_along(x)) {
    out[[i]] <- f(x[[i]], y[[i]], z[[i]])
  }
  out
}
map3(n, mu, sigma, rnorm)

# Instead, purrr provides pmap() which takes a list of argumnts.
# You might use that if you wanted to vary the mean, starndard deviation, and number of samples:
n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>% 
  pmap(rnorm) %>% 
  str()

# That looks like:
#                 args1                        pmap(args1)
# /---------------------------------\  
# | /-------\  /-------\  /-------\ |   /----------------------\
# | | |---| |  | |---| |  | |---| | |   | |------------------| |
# | | | 1 | |  | | 5 | |  | | 1 | | |   | | rnorm(1, 5, 1)   | |
# | | |---| |  | |---| |  | |---| | |   | |------------------| |
# | |       |  |       |  |       | |   |                      |
# | | |---| |  | |---| |  | |---| | |   | |------------------| |
# | | | 3 | |  | |10 | |  | | 5 | | |   | | rnorm(3, 10, 5)  | |
# | | |---| |  | |---| |  | |---| | |   | |------------------| |
# | |       |  |       |  |       | |   |                      |
# | | |---| |  | |---| |  | |---| | |   | |------------------| |
# | | | 5 | |  | |-3 | |  | |10 | | |   | | rnorm(5, -3, 10) | |
# | | |---| |  | |---| |  | |---| | |   | |------------------| |
# | \-------/  \-------/  \-------/ |   \----------------------/
# \---------------------------------/

# If you don't name the elements of list, pmap() will use postional matching when calling the function.
# That's a little fragile, and makes the code harder to read, so it's better to name the arguments:
args2 <- list(mean = mu, sd = sigma, n = n)
args2 %>% 
  pmap(rnorm) %>% 
  str()

# That's generates longer, but safer, calls:
#                 args2                                pmap(args2)
# /---------------------------------\  
# | /-------\  /-------\  /-------\ | 
# | |  mu   |  | sigma |  |   n   | |   /-----------------------------------------\
# | | |---| |  | |---| |  | |---| | |   | |-------------------------------------| |
# | | | 1 | |  | | 5 | |  | | 1 | | |   | | rnorm(mean = 5, sigma = 1, n = 1)   | |
# | | |---| |  | |---| |  | |---| | |   | |-------------------------------------| |
# | |       |  |       |  |       | |   |                                         |
# | | |---| |  | |---| |  | |---| | |   | |-------------------------------------| |
# | | | 3 | |  | |10 | |  | | 5 | | |   | | rnorm(mean = 10, sigma = 5, n = 3)  | |
# | | |---| |  | |---| |  | |---| | |   | |-------------------------------------| |
# | |       |  |       |  |       | |   |                                         |
# | | |---| |  | |---| |  | |---| | |   | |-------------------------------------| |
# | | | 5 | |  | |-3 | |  | |10 | | |   | | rnorm(mean = -3, sigma = 10, n = 5) | |
# | | |---| |  | |---| |  | |---| | |   | |-------------------------------------| |
# | \-------/  \-------/  \-------/ |   \-----------------------------------------/
# \---------------------------------/

# Since the arguments are all the same length, it makes sense to srore them in a data frame:
params <- tribble(
  ~mean, ~sd, ~n,
  5,   1,   1,
  10,   5,   3,
  -3,  10,   5
)

params %>% 
  pmap(rnorm)
# As soon as your code gets complicated, I think a data frame is a good approach 
# because it ensures that each column has a name and is the same length as all the other columns.

# 21.7.1 Invoking different functions

# There's one more step up in complecity - as well as varying the arguments to the function you might also vary the function itself:
f <- c("runif", "rnorm", "rpois")
params <- list(
  list(min = -1, max = 1), 
  list(sd = 5), 
  list(lambda = 10)
)

# To handle this case, you can use invoke_map():
invoke_map(f, params, n = 5) %>% str()

#        f                params              invoke_map(f, params, n = 5)
# /-------------\  /-----------------\   /------------------------------------\
# |             |  | /-------------\ |  |                                     |
# |             |  | |  min   max  | |  |                                     |
# | |---------| |  | | |---| |---| | |  | |---------------------------------| |
# | | "runif" | |  | | |-1 | | 1 | | |  | | runif(min = -1, max = 1, n = 5) | |
# | |---------| |  | | |---| |---| | |  | |---------------------------------| |
# |             |  | \-------------/ |  |                                     |
# |             |  |                 |  |                                     |
# |             |  |   /---------\   |  |                                     |
# |             |  |   |    sd   |   |  |                                     |
# | |---------| |  |   |  |---|  |   |  | |---------------------------------| |
# | | "rnorm" | |  |   |  | 5 |  |   |  | | rnorm(sd = 5, n = 5)            | |
# | |---------| |  |   |  |---|  |   |  | |---------------------------------| |
# |             |  |   \---------/   |  |                                     |
# |             |  |                 |  |                                     |
# |             |  |   /---------\   |  |                                     |
# |             |  |   |  lambda |   |  |                                     |
# | |---------| |  |   |  |---|  |   |  | |---------------------------------| |
# | | "rpois" | |  |   |  |10 |  |   |  | | rpois(lambda = 10, n = 5)       | |
# | |---------| |  |   |  |---|  |   |  | |---------------------------------| |
# \-------------/  |   \---------/   |  |                                     |
#                  \-----------------/  \-------------------------------------/

# The first argument is a list of functions or character vector of function names.
# The second argument is a list of lists giving the arguments that vary for each function.
# The subsequent arguments are passed on to every function.

# And again, you can use tribble() to make creating these matching pairs a little easier:
sim <- tribble(
  ~f,      ~params,
  "runif", list(min = -1, max = 1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10)
)
sim %>% 
  mutate(sim = invoke_map(f, params, n = 10))

# 21.8 Walk

# Walk is an alternative to map that use when you want to call a function for its side effects, rather than for its return value. 
# You typically do this because you want to render output to the screen or save files to disk - 
# the important thing is the action, not the return value. Here's a very simple example:
x <- list(1, "a", 3)
x %>% 
  walk(print)

# Walk() is generally not that useful compared to walk2() or pwalk().
# For example, if you had a list of plots and a vector of file names, 
# you could use pwalk() to save each file to the corresponding location on disk:
library(ggplot2)
plots <- mtcars %>% 
  split(.$cyl) %>% 
  map(~ggplot(., aes(mpg, wt)) + geom_point())
paths <- stringr::str_c(names(plots), ".pdf")

pwalk(list(paths, plots), ggsave, path = tempdir())

# walk(), walk2(), pwalk() all invisibly return .x, the first argument.
# This makes them suitable for use in the middle of pipelines.

# 21.9 Other 

# Purrr provides a number of other funcitons that abstract over types of for loops.
# You'll use them less frequently than the map functions, but they're useful to know about.
# The goal here is to briefly illustrate each function, so hopefully it will come to mind if you see a similar problem in the future.
# Then you can go look up the documentation for more details.

# 21.9.1 Predicate functions

# A number of funtions work with predicate functions that return either a single TRUE or FALSE.

# keep() and discard() keep elements of the input where the predicate is TRUE or FALSE respectively:
iris %>% 
  keep(is.factor) %>% 
  str()

iris %>% 
  discard(is.factor) %>% 
  str()

# some() and every() determine if the predicate is true for any or for all of the elements.
x <- list(1:5, letters, list(10))

x %>% some(is_character)

x %>% every(is_vector)

# detect() finds the first element where the predicate is true; detect_index() returns its position.
x <- sample(10)
x

x %>% detect(~ . > 5)
x %>% detect_index(~ . > 5)

# head_while() and tail_while() take elements from the start or end of a vector while a predicate is true:
x %>% head_while(~ . > 5)
x %>% tail_while(~ . > 5)

# 21.9.2 Reduce and accumulate

# Sometimes you have a complex list that you want to reduce to a simple list by repeatedly applying a funciton that reduces a pair to a singleton.
# This is useful if you want to apply a two-table dplyr verb to multiple tables.
# For example, you might have a list of data frames, and you want to reduce to a single data frame by joining the elements together:
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)
dfs %>% reduce(full_join)

# Or maybe you have a list of vectors, and want to find to intersection:
vs <- list(
  c(1, 3, 5, 6 ,10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10)
)

vs %>% reduce(intersect)

# The reduce function takes a "binary" function (i.e. a function with two primary inputs),
# and applies it repeatedly to list until there is only a single element left.

# Accumulate is similar but it keeps all the interim results. You could use it to implement a cumulative sum:
x <- sample(10)
x

x %>% accumulate(`+`)

# 21.9.3 Exercises
# 1. Implement your own version of every() using a for loop. Compare it with purrr::every().
#    What does purrr's version do that your version doesn't?
every_test <- function(x, f, ...) {
  out <- vector("double", length(x))
  for (i in seq_along(x)) {
    out[[i]] <- f(x[[i]])
  }
  all(out == TRUE)
}
every_test(x, is.vector)
every_test(1:3, function(x) x > 0)

?purrr::every()

# 2. Create an enhanced col_summary() that applies a summary function to every numeric column in a data frame.
nycflights13::flights %>% str()

col_summary3 <- function(df, f, ...) {
  output <- map(keep(df, is.numeric), f)
  output
}
col_summary3(iris, mean)

# 3. A possible base R equivalent of col_summary() is:
col_sum3 <- function(df, f) {
  is_num <- sapply(df, is.numeric)
  df_num <- df[, is_num]
  
  sapply(df_num, f)
}
#    But it has a number of bugs as illustrated with the following inputs:
df <- tibble(
  x = 1:3, 
  y = 3:1,
  z = c("a", "b", "c")
)
# ok
col_sum3(df, mean)
# Has problems: don't always return numeric vector
col_sum3(df[1:2], mean)
col_sum3(df[1], mean)
col_sum3(df[0], mean)

# What causes the bugs?
?sapply()
## sapply is a user-friendly version and wrapper of lapply by default returning a vector, matrix or,
## if simplify = "array", an array if appropriate, by applying simplify2array(). sapply(x, f, simplify = FALSE, 
## USE.NAMES = FALSE) is the same as lapply(x, f).
